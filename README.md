# Environment Management Scripts (Pixi + uv + Conda)

This repository contains cross-shell environment management helpers for:

- Pixi
- uv
- conda

To setup a new pixi or uv environment [read the `create_environment.md`](create_environment.md).

Environment preference order:

Pixi → uv → conda

Directory layout assumed:

%USERPROFILE%\pixi_projects\<env_name>\pixi.toml
%USERPROFILE%\uv_envs\arm64\<env_name>
%USERPROFILE%\uv_envs\x64\<env_name>

Git Bash equivalents:

$HOME/pixi_projects
$HOME/uv_envs/arm64
$HOME/uv_envs/x64

Included Scripts:

Activation:
- activate_env.ps1 (PowerShell, must be dot-sourced)
- activate_env.bat (cmd.exe)
- activate_env.sh  (Git Bash, must be sourced)

Run (conda-run equivalent):
- run_env.bat
- run_env.sh

List environments:
- list_envs.bat
- list_envs.sh

PowerShell Activation Example:

    . .\activate_env.ps1 py312_pd22_x64

Git Bash Activation Example:

    source ./activate_env.sh py312_pd22_x64

Run Example:

    run_env.bat py312_pd22_x64 python script.py
    ./run_env.sh py312_pd22_x64 python script.py

List Environments:

    list_envs.bat
    ./list_envs.sh

Notes:

- .bat activation does NOT persist in PowerShell.
- .ps1 activation must be dot-sourced.
- Pixi activation launches a managed subshell.
- uv environments are detected via Scripts/python.exe.
- Conda fallback requires conda to be on PATH.

Recommended Setup:

- Place activate_env.ps1 in %USERPROFILE%\bin
- Add that directory to PATH
- Add a PowerShell profile wrapper:

    function use-env {
        param([string]$name)
        . "$HOME\bin\activate_env.ps1" $name
    }

