@echo off
setlocal enabledelayedexpansion
rem Ensures an Android emulator or device is visible to adb (native Windows).
rem
rem Usage:
rem   scripts\boot-android-emulator.bat
rem   set ANDROID_AVD=Pixel_7_API_34 && scripts\boot-android-emulator.bat
rem
rem Always launches with -no-snapshot-load (cold boot): resuming an AVD from a
rem Quick Boot snapshot can leave the adb/logcat bridge in a bad state, which
rem makes `flutter run` hang silently after the compile step. Cold boot avoids
rem that, at the cost of a slower emulator startup than a snapshot resume.
rem
rem Optional env:
rem   ANDROID_AVD - AVD name to launch if no device is connected
rem   ADB         - default: adb

if not defined ADB set "ADB=adb"

where %ADB% >nul 2>&1
if errorlevel 1 (
  echo adb not found. Install Android platform-tools or set ADB=path\to\adb.exe. 1>&2
  exit /b 1
)

%ADB% get-state >nul 2>&1
if not errorlevel 1 (
  for /f "delims=" %%S in ('%ADB% get-state 2^>nul') do set "STATE=%%S"
  echo Android device ready ^(!STATE!^)
  exit /b 0
)

rem Locate emulator.exe: PATH, then ANDROID_HOME / ANDROID_SDK_ROOT, then derive
rem the SDK root from adb.exe's own location (<SDK>\platform-tools\adb.exe),
rem then the common default install path. `emulator` often isn't on PATH even
rem when `adb` is, since only platform-tools tends to get added automatically.
set "EMULATOR_EXE="
where emulator >nul 2>&1
if not errorlevel 1 (
  for /f "delims=" %%E in ('where emulator 2^>nul') do (
    if not defined EMULATOR_EXE set "EMULATOR_EXE=%%E"
  )
)
if not defined EMULATOR_EXE if defined ANDROID_HOME (
  if exist "%ANDROID_HOME%\emulator\emulator.exe" set "EMULATOR_EXE=%ANDROID_HOME%\emulator\emulator.exe"
)
if not defined EMULATOR_EXE if defined ANDROID_SDK_ROOT (
  if exist "%ANDROID_SDK_ROOT%\emulator\emulator.exe" set "EMULATOR_EXE=%ANDROID_SDK_ROOT%\emulator\emulator.exe"
)
if not defined EMULATOR_EXE (
  for /f "delims=" %%P in ('where %ADB% 2^>nul') do (
    if not defined ADB_PATH set "ADB_PATH=%%P"
  )
  if defined ADB_PATH (
    for %%D in ("%ADB_PATH%") do set "SDK_FROM_ADB=%%~dpD.."
    for %%D in ("!SDK_FROM_ADB!") do set "SDK_FROM_ADB=%%~fD"
    if exist "!SDK_FROM_ADB!\emulator\emulator.exe" set "EMULATOR_EXE=!SDK_FROM_ADB!\emulator\emulator.exe"
  )
)
if not defined EMULATOR_EXE (
  if exist "%LOCALAPPDATA%\Android\Sdk\emulator\emulator.exe" set "EMULATOR_EXE=%LOCALAPPDATA%\Android\Sdk\emulator\emulator.exe"
)

set "AVD=%ANDROID_AVD%"
if not defined AVD if defined EMULATOR_EXE (
  for /f "delims=" %%A in ('"%EMULATOR_EXE%" -list-avds 2^>nul') do (
    if not defined AVD set "AVD=%%A"
  )
)

if not defined AVD (
  echo No Android device connected and no AVD found. 1>&2
  if defined EMULATOR_EXE (
    echo Create an AVD in Android Studio or set ANDROID_AVD. 1>&2
  ) else (
    echo Could not locate emulator.exe either ^(checked PATH, ANDROID_HOME, ANDROID_SDK_ROOT, and adb's folder^). 1>&2
    echo Set ANDROID_HOME to your SDK root, or ANDROID_AVD to your AVD name, and retry. 1>&2
  )
  exit /b 1
)

echo Launching Android emulator ^(cold boot^): %AVD%
if defined EMULATOR_EXE (
  start "" "%EMULATOR_EXE%" -avd %AVD% -no-snapshot-load
) else (
  where flutter >nul 2>&1
  if not errorlevel 1 (
    echo emulator.exe not found - falling back to "flutter emulators --launch", which cannot force a cold boot. 1>&2
    start "" flutter emulators --launch %AVD%
  ) else (
    echo Cannot launch AVD %AVD% - install Android Studio or add the emulator tool to PATH. 1>&2
    exit /b 1
  )
)

set /a ATTEMPTS=90
:wait_loop
%ADB% get-state >nul 2>&1
if not errorlevel 1 (
  echo Android emulator ready: %AVD%
  exit /b 0
)
set /a ATTEMPTS-=1
if %ATTEMPTS% gtr 0 (
  ping -n 3 127.0.0.1 >nul
  goto wait_loop
)

echo Emulator started but adb device not ready yet - try again in a few seconds. 1>&2
exit /b 1
