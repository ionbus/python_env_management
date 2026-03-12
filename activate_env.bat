@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "BASE=%USERPROFILE%"
set "PIXI_PROJECTS=%BASE%\pixi_projects"
set "UV_ENVS=%BASE%\uv_envs"

if "%~1"=="" (
  echo Usage: %~nx0 ENV_NAME
  exit /b 2
)

set "ENVNAME=%~1"

set "MANIFEST=%PIXI_PROJECTS%\%ENVNAME%\pixi.toml"
if exist "%MANIFEST%" (
  pixi shell --manifest-path "%MANIFEST%"
  exit /b %errorlevel%
)

set "UV_ARM=%UV_ENVS%\arm64\%ENVNAME%"
set "UV_X64=%UV_ENVS%\x64\%ENVNAME%"

if exist "%UV_ARM%\Scripts\activate.bat" (
  endlocal
  call "%UV_ARM%\Scripts\activate.bat"
  exit /b %errorlevel%
)

if exist "%UV_X64%\Scripts\activate.bat" (
  endlocal
  call "%UV_X64%\Scripts\activate.bat"
  exit /b %errorlevel%
)

endlocal
call conda activate "%~1"
exit /b %errorlevel%
