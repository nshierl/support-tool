@echo off
mode con: cols=68 lines=32
title Dreadnought Community Support Tool

setlocal EnableDelayedExpansion

set version=1.0.0
set sourceDirPath=C:\DreadnoughtSupport\
set contentDirPath=%sourceDirPath%\support-info
set targetZipFileName=DN_Support.zip
set destinationDirPath=%userprofile%\Desktop
set /a cnt=0
set "keep=10"

echo:
echo   ----------------------------------------------------------------
echo    DREADNOUGHT COMMUNITY SUPPORT TOOL
echo   ----------------------------------------------------------------
echo:
echo     This tool will create a zip file of your msinfo, dxdiag and 
echo     the last %keep% log files for bug reports or other issues
echo     when contacting Customer Support.
echo:
echo     Let the tool run until you see a file on your desktop called
echo     %targetZipFileName%
echo:
echo     Authors:
echo      - Anyone#6415
echo:
echo     For feedback, please contact us on Discord:
echo      - https://discord.gg/dreadnought
echo:
echo     Initial script setup by Spider.
echo:
echo   ----------------------------------------------------------------
echo:
echo     Will create:
echo      - "%sourceDirPath%"
echo:
echo:    Using log directory:
echo      - "%userprofile%\AppData\Local\DreadGame\Saved\Logs"
echo:
echo   ----------------------------------------------------------------
echo:
echo:    Press ENTER to start, or close the tool to quit.

pause > nul

rmdir /s /q %sourceDirPath% 2> nul
mkdir %contentDirPath%\logs

echo:
echo     Gathering information, this can take up to a few minutes.
echo     Please don't interrupt or quit the tool while waiting.

set supportReadmeFile=%contentDirPath%\SUPPORT-README.txt

:: readme file included for the support employee that this was automatically generated
echo Files gathered and archived by the Dreadnought Community Support Tool (%version%) >> %supportReadmeFile%
echo:                                                                                  >> %supportReadmeFile%
echo Automatically collected information:                                              >> %supportReadmeFile%
echo  - Dreadnought log files (last %keep% log files)                                  >> %supportReadmeFile%
echo  - DxDiag                                                                         >> %supportReadmeFile%
echo  - MSInfo                                                                         >> %supportReadmeFile%
echo:                                                                                  >> %supportReadmeFile%
echo The Dreadnought Community Support Tool can be found at:                           >> %supportReadmeFile%
echo  - https://github.com/dreadnought-friends/support-tool                            >> %supportReadmeFile%
echo:                                                                                  >> %supportReadmeFile%

:: only select the last X log files
for /f "eol=: delims=" %%F in ('dir %userprofile%\AppData\Local\DreadGame\Saved\Logs\*.log /b /s /o-d /a-d') do (
  if defined keep (
    2>nul set /a "cnt+=1, 1/(keep-cnt)" || set "keep="
    xcopy "%%F" %contentDirPath%\logs 2>&1 > nul
  )
)

dxdiag /t %contentDirPath%\dxdiag.txt
Msinfo32 /report %contentDirPath%\msinfo.txt

set tempFilePath=%temp%\FilesToZip.txt
type nul > %tempFilePath%

:: creating a zip file, not sure what this magic does...
for /f "delims=*" %%i in ('dir /b /s /a-d  "%sourceDirPath%"') do (
  set filePath=%%i
  set dirPath=%%~dpi
  set dirPath=!dirPath:~0,-1!
  set dirPath=!dirPath:%sourceDirPath%=!
  set dirPath=!dirPath:%sourceDirPath%=!
  echo .set DestinationDir=!dirPath! >> %tempFilePath%
  echo "!filePath!" >> %tempFilePath%
)

makecab /d MaxDiskSize=0 /d CompressionType=MSZIP /d Cabinet=ON /d Compress=ON /d UniqueFiles=ON /d DiskDirectoryTemplate=%destinationDirPath% /d CabinetNameTemplate=%targetZipFileName%  /F %tempFilePath% > nul 2>&1

del setup.inf > nul 2>&1
del setup.rpt > nul 2>&1
del %tempFilePath% > nul 2>&1
echo   ----------------------------------------------------------------
echo:
echo     %targetZipFileName% has been created and is located on your
echo     Desktop. Please include this file as attachment to your
echo     support ticket or email.
echo: 
echo     You can now close the Dreadnought Community Support Tool!
echo:
echo   ----------------------------------------------------------------
echo:
echo:    Press ENTER to quit.
pause > nul
