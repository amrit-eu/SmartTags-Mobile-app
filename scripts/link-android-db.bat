@echo off
setlocal enabledelayedexpansion
rem Pulls the Android emulator/device SQLite DB to a stable path for DBeaver / sqlite3.
rem
rem Usage (from repo root, native Windows terminal - cmd or PowerShell):
rem   scripts\link-android-db.bat
rem
rem Optional env vars:
rem   ANDROID_PACKAGE  - default: com.example.flutter_amrit
rem   ANDROID_DB_PATH  - default: app_flutter/db.sqlite
rem   ADB              - default: adb (must be on PATH, or set to full path to adb.exe)
rem
rem Requires a debug build (run-as). Run the app once so Drift creates the database.

set "ROOT_DIR=%~dp0.."
for %%I in ("%ROOT_DIR%") do set "ROOT_DIR=%%~fI"
set "LINK_PATH=%ROOT_DIR%\.dev\db.sqlite"
set "TMP_PATH=%LINK_PATH%.tmp"
if not defined ANDROID_PACKAGE set "ANDROID_PACKAGE=com.example.flutter_amrit"
if not defined ANDROID_DB_PATH set "ANDROID_DB_PATH=app_flutter/db.sqlite"
if not defined ADB set "ADB=adb"

where %ADB% >nul 2>&1
if errorlevel 1 (
  echo adb not found. Install Android platform-tools or set ADB=path\to\adb.exe. 1>&2
  exit /b 1
)

%ADB% get-state >nul 2>&1
if errorlevel 1 (
  echo No Android device or emulator connected. 1>&2
  echo Run "adb devices" and start an emulator or plug in a device. 1>&2
  exit /b 1
)

if not exist "%ROOT_DIR%\.dev" mkdir "%ROOT_DIR%\.dev"

rem Pull to a temp file then replace atomically.
%ADB% exec-out run-as %ANDROID_PACKAGE% cat %ANDROID_DB_PATH% > "%TMP_PATH%" 2>nul
if errorlevel 1 (
  del /f /q "%TMP_PATH%" >nul 2>&1
  echo Could not read %ANDROID_DB_PATH% for %ANDROID_PACKAGE%. 1>&2
  echo Install a debug build, run the app once, then retry. 1>&2
  exit /b 1
)

set "SIZE=0"
if exist "%TMP_PATH%" for %%A in ("%TMP_PATH%") do set "SIZE=%%~zA"
if "%SIZE%"=="0" (
  del /f /q "%TMP_PATH%" >nul 2>&1
  echo Pulled file is empty - database may not exist yet. 1>&2
  exit /b 1
)

move /y "%TMP_PATH%" "%LINK_PATH%" >nul
if errorlevel 1 (
  del /f /q "%TMP_PATH%" >nul 2>&1
  echo Could not replace %LINK_PATH% - it may be locked by another program. 1>&2
  echo Close any tool with it open exclusively ^(e.g. re-open the DBeaver connection^) and retry. 1>&2
  exit /b 1
)

set "COUNT=?"
where sqlite3 >nul 2>&1
if not errorlevel 1 (
  for /f "delims=" %%C in ('sqlite3 "%LINK_PATH%" "SELECT COUNT(*) FROM platforms;" 2^>nul') do set "COUNT=%%C"
)

echo Pulled Android DB -^> %LINK_PATH%
echo Package: %ANDROID_PACKAGE%
echo Platforms: %COUNT%
echo.
echo DBeaver: New Connection -^> SQLite -^> Path:
echo   %LINK_PATH%
exit /b 0
