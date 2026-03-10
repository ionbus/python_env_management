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

if /I "%RESOLVED_ARCH%"=="arm64" (
  set "PLATFORM=win-arm64"
) else (
  set "PLATFORM=win-64"
)

set "BASE=%USERPROFILE%"
set "PIXI_PROJECTS=%BASE%\pixi_projects"
set "PIXI_ENVS=%BASE%\pixi_envs"
set "PROJECTDIR=%PIXI_PROJECTS%\%ENVNAME%"
set "DETACHEDROOT=%PIXI_ENVS%\%RESOLVED_ARCH%"

mkdir "%PROJECTDIR%" 2>nul
mkdir "%DETACHEDROOT%" 2>nul

pushd "%PROJECTDIR%"

if not exist "pixi.toml" (
  pixi init --platform %PLATFORM%
  if errorlevel 1 goto :fail
)

mkdir ".pixi" 2>nul
(
echo detached-environments = "%DETACHEDROOT:\=\\%"
) > ".pixi\config.toml"

set "PACKAGES="
:collect_packages
if "%~1"=="" goto :done_collecting
if defined PACKAGES (
  set "PACKAGES=!PACKAGES! %~1"
) else (
  set "PACKAGES=%~1"
)
shift /1
goto :collect_packages
:done_collecting

if "%PACKAGES%"=="" (
  echo No packages provided.
  popd
  exit /b 2
)

pixi add %PACKAGES%
if errorlevel 1 goto :fail

pixi install
if errorlevel 1 goto :fail

set "HAS_KERNEL=no"
for %%P in (%PACKAGES%) do (
  for /f "tokens=1 delims==<>!~" %%Q in ("%%P") do (
    if /I "%%Q"=="ipykernel" set "HAS_KERNEL=yes"
  )
)

if /I "%HAS_KERNEL%"=="yes" (
  pixi run python -m ipykernel install --user --name %ENVNAME% --display-name %ENVNAME%
)

echo Pixi environment setup complete:
echo   Project:       %PROJECTDIR%
echo   Architecture:  %RESOLVED_ARCH%
echo   Platform:      %PLATFORM%
echo   Detached root: %DETACHEDROOT%

popd
exit /b 0

:fail
echo Setup failed.
popd
exit /b 1
