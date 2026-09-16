@echo off
setlocal enabledelayedexpansion
rem Run SmartTags on Android and keep .dev\db.sqlite synced for DBeaver (native Windows).
rem
rem Usage:
rem   scripts\smartrun-android.bat
rem   scripts\smartrun-android.bat -d emulator-5554
rem   scripts\smartrun-android.bat -d <physical-serial>   # USB / wireless device
rem
rem Ensures an emulator/device is available, pulls an existing DB before launch,
rem then keeps re-pulling in the background while Flutter runs (reinstall / first
rem sync can replace the on-device DB after the first pull).

set "ROOT_DIR=%~dp0.."
for %%I in ("%ROOT_DIR%") do set "ROOT_DIR=%%~fI"
set "LINK_PATH=%ROOT_DIR%\.dev\db.sqlite"
if not defined ADB set "ADB=adb"

rem Internal re-entry point: this same file is relaunched in a background window
rem with this sentinel argument to run the DB watcher loop.
if "%~1"=="__DBWATCH__" (
  call :watch_loop
  exit /b 0
)

cd /d "%ROOT_DIR%"

rem --- resolve -d <target> from the passed-through flutter args ---
set "TARGET="
set "FOUND_D=0"
for %%A in (%*) do (
  if "!FOUND_D!"=="1" (
    set "TARGET=%%~A"
    set "FOUND_D=0"
  )
  if "%%~A"=="-d" set "FOUND_D=1"
)

rem Boot/connect an emulator when there's no -d, or an explicit emulator-* target.
set "BOOT_EMULATOR=1"
if defined TARGET (
  echo %TARGET%| findstr /b /r "emulator-" >nul
  if errorlevel 1 set "BOOT_EMULATOR=0"
)

if "%BOOT_EMULATOR%"=="1" (
  call "%~dp0boot-android-emulator.bat"
  if errorlevel 1 exit /b 1
  if defined TARGET set "ANDROID_SERIAL=%TARGET%"
) else (
  echo Physical / non-emulator Android device: %TARGET%
  echo Skipping emulator launch - waiting for this device via adb.
  set "ANDROID_SERIAL=%TARGET%"
  call :wait_for_physical "%TARGET%"
  if errorlevel 1 exit /b 1
)

echo.
echo === DB link - before Flutter launch ===
call "%~dp0link-android-db.bat"

set "WATCH_TITLE=SmartTagsDBWatch_%RANDOM%"
start "%WATCH_TITLE%" /min cmd /c ""%~f0" __DBWATCH__"

flutter run %*

taskkill /fi "WINDOWTITLE eq %WATCH_TITLE%" /t /f >nul 2>&1

exit /b 0

:wait_for_physical
set "SERIAL=%~1"
set /a ATTEMPTS=30
:wait_phys_loop
%ADB% -s "%SERIAL%" get-state >nul 2>&1
if not errorlevel 1 (
  echo Physical Android device ready: %SERIAL%
  exit /b 0
)
set /a ATTEMPTS-=1
if %ATTEMPTS% gtr 0 (
  ping -n 3 127.0.0.1 >nul
  goto wait_phys_loop
)
echo Physical Android device not ready: %SERIAL% 1>&2
echo Plug it in (USB debugging on), accept the RSA prompt, then retry. 1>&2
echo Check with: adb devices 1>&2
exit /b 1

rem Fingerprints the pulled file by size so we only print when it actually
rem changed (reinstall / Gateway sync replacing the on-device DB).
:watch_loop
set "LAST_SIZE=-1"
if exist "%LINK_PATH%" for %%A in ("%LINK_PATH%") do set "LAST_SIZE=%%~zA"
:watch_loop_iter
call "%~dp0link-android-db.bat" >"%TEMP%\smarttags_dbwatch.tmp" 2>nul
set "CUR_SIZE=-1"
if exist "%LINK_PATH%" for %%A in ("%LINK_PATH%") do set "CUR_SIZE=%%~zA"
if not "!CUR_SIZE!"=="!LAST_SIZE!" (
  if not "!CUR_SIZE!"=="-1" (
    echo.
    echo === DB link - updated (app ready / reinstalled / synced) ===
    type "%TEMP%\smarttags_dbwatch.tmp"
  )
  set "LAST_SIZE=!CUR_SIZE!"
)
ping -n 4 127.0.0.1 >nul
goto watch_loop_iter
