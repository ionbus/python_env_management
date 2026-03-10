@echo off
setlocal EnableExtensions

set "BASE=%USERPROFILE%"
set "PIXI_PROJECTS=%BASE%\pixi_projects"
set "UV_ENVS=%BASE%\uv_envs"

echo Pixi Environments:
for /d %%D in ("%PIXI_PROJECTS%\*") do (
  if exist "%%D\pixi.toml" echo [pixi] %%~nxD
)

echo.
echo uv arm64 Environments:
for /d %%D in ("%UV_ENVS%\arm64\*") do (
  if exist "%%D\Scripts\python.exe" echo [uv-arm64] %%~nxD
)

echo.
echo uv x64 Environments:
for /d %%D in ("%UV_ENVS%\x64\*") do (
  if exist "%%D\Scripts\python.exe" echo [uv-x64] %%~nxD
)

echo.
echo Conda Environments:
conda env list 2>nul | findstr /V "#"

endlocal
