# Environment management functions for PowerShell
# Source this file from your PowerShell profile ($PROFILE):
#   . "$HOME\bin\env_functions.ps1"

$script:BinDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function activate-env {
    <#
    .SYNOPSIS
    Activate a Pixi, uv, or conda environment by name.
    .EXAMPLE
    activate-env python_311_pd15
    #>
    param([Parameter(Mandatory)][string]$Name)
    . "$script:BinDir\activate_env.ps1" $Name
}

function new-pixi {
    <#
    .SYNOPSIS
    Create a new Pixi environment.
    .EXAMPLE
    new-pixi myenv python=3.11 pandas=2.2 ipython
    new-pixi myenv x64 python=3.11 pandas=2.2
    #>
    & "$script:BinDir\setup_new_pixi_env.ps1" @args
}

function new-uv {
    <#
    .SYNOPSIS
    Create a new uv environment.
    .EXAMPLE
    new-uv myenv python=3.11 pandas=2.2 ipython
    new-uv myenv arm64 python=3.11 pandas=2.2
    #>
    & "$script:BinDir\setup_new_uv_env.ps1" @args
}

function list-envs {
    <#
    .SYNOPSIS
    List available Pixi, uv, and conda environments.
    #>
    Write-Host "Pixi projects:" -ForegroundColor Cyan
    Get-ChildItem "$HOME\pixi_projects" -Directory -ErrorAction SilentlyContinue |
        ForEach-Object { Write-Host "  $($_.Name)" }

    Write-Host "`nuv environments (x64):" -ForegroundColor Cyan
    Get-ChildItem "$HOME\uv_envs\x64" -Directory -ErrorAction SilentlyContinue |
        ForEach-Object { Write-Host "  $($_.Name)" }

    Write-Host "`nuv environments (arm64):" -ForegroundColor Cyan
    Get-ChildItem "$HOME\uv_envs\arm64" -Directory -ErrorAction SilentlyContinue |
        ForEach-Object { Write-Host "  $($_.Name)" }
}
