@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "BASE=%USERPROFILE%"
set "PIXI_PROJECTS=%BASE%\pixi_projects"
set "UV_ENVS=%BASE%\uv_envs"

if "%~2"=="" (
  echo Usage: %~nx0 ENV_NAME command [args...]
  exit /b 2
)

set "ENVNAME=%~1"
shift

set "CMD=%~1"
shift
:build_cmd
if "%~1"=="" goto cmd_done
set "CMD=!CMD! "%~1""
shift
goto build_cmd
:cmd_done

set "MANIFEST=%PIXI_PROJECTS%\%ENVNAME%\pixi.toml"
if exist "%MANIFEST%" goto run_pixi

set "UV_ARM=%UV_ENVS%\arm64\%ENVNAME%"
if exist "%UV_ARM%\Scripts\python.exe" goto run_uv_arm

set "UV_X64=%UV_ENVS%\x64\%ENVNAME%"
if exist "%UV_X64%\Scripts\python.exe" goto run_uv_x64

goto run_conda

:run_pixi
pixi run --manifest-path "%MANIFEST%" -- !CMD!
exit /b %errorlevel%

:run_uv_arm
set "VIRTUAL_ENV=%UV_ARM%"
set "PATH=%UV_ARM%\Scripts;%PATH%"
cmd /c !CMD!
exit /b %errorlevel%

:run_uv_x64
set "VIRTUAL_ENV=%UV_X64%"
set "PATH=%UV_X64%\Scripts;%PATH%"
cmd /c !CMD!
exit /b %errorlevel%

:run_conda
conda run -n "%ENVNAME%" !CMD!
exit /b %errorlevel%
