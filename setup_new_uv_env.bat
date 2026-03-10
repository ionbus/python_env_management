@echo off
setlocal EnableExtensions EnableDelayedExpansion

if "%~2"=="" (
  echo Usage: %~nx0 ENV_NAME [auto^|x64^|arm64] package1 package2 ...
  exit /b 2
)

set "ENVNAME=%~1"
shift /1

set "ARCH=%~1"
if /I "%ARCH%"=="auto" (
  shift /1
) else if /I "%ARCH%"=="x64" (
  shift /1
) else if /I "%ARCH%"=="arm64" (
  shift /1
) else (
  set "ARCH=auto"
)

if /I "%ARCH%"=="auto" (
  if /I "%PROCESSOR_ARCHITECTURE%"=="ARM64" (
    set "RESOLVED_ARCH=arm64"
  ) else if /I "%PROCESSOR_ARCHITEW6432%"=="ARM64" (
    set "RESOLVED_ARCH=arm64"
  ) else (
    set "RESOLVED_ARCH=x64"
  )
) else (
  set "RESOLVED_ARCH=%ARCH%"
)

set "BASE=%USERPROFILE%"
set "UV_ENVS=%BASE%\uv_envs"
set "ENVDIR=%UV_ENVS%\%RESOLVED_ARCH%\%ENVNAME%"
mkdir "%UV_ENVS%\%RESOLVED_ARCH%" 2>nul

set "PYVER=3.12"
set "NEEDS_KERNEL=no"
set "INSTALL_SPECS="

:parse_loop
if "%~1"=="" goto parse_done
set "SPEC=%~1"

for /f "tokens=1* delims==" %%A in ("%SPEC%") do (
  set "LEFT=%%A"
  set "RIGHT=%%B"
)

if /I "!LEFT!"=="python" if not "!RIGHT!"=="" (
  set "PYVER=!RIGHT!"
  shift /1
  goto parse_loop
)

if /I "!LEFT!"=="ipykernel" set "NEEDS_KERNEL=yes"
if /I "!LEFT!"=="jupyter" set "NEEDS_KERNEL=yes"

echo.%SPEC%| findstr /R "== >= <= ~= != > <" >nul
if not errorlevel 1 (
  set "INSTALL_SPECS=!INSTALL_SPECS! %SPEC%"
) else (
  echo.%SPEC%| findstr "=" >nul
  if not errorlevel 1 (
    set "INSTALL_SPECS=!INSTALL_SPECS! !LEFT!==!RIGHT!"
  ) else (
    set "INSTALL_SPECS=!INSTALL_SPECS! %SPEC%"
  )
)

shift /1
goto parse_loop

:parse_done

if not exist "%ENVDIR%\Scripts\python.exe" (
  uv venv "%ENVDIR%" --python %PYVER%
  if errorlevel 1 goto :fail
)

set "PYTHONEXE=%ENVDIR%\Scripts\python.exe"

echo !INSTALL_SPECS! | findstr /I " ipykernel " >nul
if errorlevel 1 (
  if /I "!NEEDS_KERNEL!"=="yes" set "INSTALL_SPECS=!INSTALL_SPECS! ipykernel"
)

if not "!INSTALL_SPECS!"=="" (
  uv pip install --python "%PYTHONEXE%" !INSTALL_SPECS!
  if errorlevel 1 goto :fail
)

if /I "!NEEDS_KERNEL!"=="yes" (
  "%PYTHONEXE%" -m ipykernel install --user --name %ENVNAME% --display-name %ENVNAME%
)

echo uv environment setup complete:
echo   Env dir:       %ENVDIR%
echo   Architecture:  %RESOLVED_ARCH%
echo   Python:        %PYVER%
exit /b 0

:fail
echo Setup failed.
exit /b 1
