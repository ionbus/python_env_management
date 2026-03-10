<# 
activate_env.ps1
PowerShell-native activation helper: Pixi -> uv -> conda (in that order)

USAGE:
  . .\activate_env.ps1 <ENV_NAME>

NOTES:
  - Must be dot-sourced (leading ". ") for activation to persist in current session.
  - Pixi: expects a project at "$HOME\pixi_projects\<ENV_NAME>\pixi.toml"
  - uv: expects venv dirs at "$HOME\uv_envs\arm64\<ENV_NAME>" or "$HOME\uv_envs\x64\<ENV_NAME>"
  - conda: falls back to `conda activate <ENV_NAME>` (requires conda hook available)
#>

param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$EnvName
)

$Base = $HOME
$PixiProjects = Join-Path $Base "pixi_projects"
$UvEnvs = Join-Path $Base "uv_envs"

function Add-ToPathFront([string]$Dir) {
  if (-not (Test-Path $Dir)) { return }
  $parts = ($env:PATH -split ';') | Where-Object { $_ -and $_.Trim() -ne '' }
  if ($parts -contains $Dir) {
    # Move to front
    $parts = @($Dir) + ($parts | Where-Object { $_ -ne $Dir })
  } else {
    $parts = @($Dir) + $parts
  }
  $env:PATH = ($parts -join ';')
}

function Activate-UvVenv([string]$VenvPath) {
  $activatePs1 = Join-Path $VenvPath "Scripts\Activate.ps1"
  if (-not (Test-Path $activatePs1)) { return $false }
  Write-Host "[activate] uv venv: $VenvPath"
  # Sets PATH, VIRTUAL_ENV, prompt, etc. in *this* session
  . $activatePs1
  return $true
}

function Ensure-CondaHook {
  if (-not (Get-Command conda -ErrorAction SilentlyContinue)) { return $false }
  try {
    # This sets up `conda activate` for PowerShell sessions.
    (& conda "shell.powershell" "hook") | Out-String | Invoke-Expression
    return $true
  } catch {
    return $false
  }
}

# 1) Pixi
$manifest = Join-Path (Join-Path $PixiProjects $EnvName) "pixi.toml"
if (Test-Path $manifest) {
  Write-Host "[activate] Pixi manifest: $manifest"
  # pixi shell starts a subshell; activation persists inside that subshell.
  # That's the expected behavior for Pixi "activation".
  & pixi shell --manifest-path $manifest
  return
}

# 2) uv (arm64 then x64)
$uvArm = Join-Path (Join-Path $UvEnvs "arm64") $EnvName
if (Activate-UvVenv $uvArm) { return }

$uvX64 = Join-Path (Join-Path $UvEnvs "x64") $EnvName
if (Activate-UvVenv $uvX64) { return }

# 3) conda
Write-Host "[activate] conda env: $EnvName"
if (-not (Ensure-CondaHook)) {
  throw "conda not found or could not initialize conda PowerShell hook. Ensure conda is installed and on PATH."
}
conda activate $EnvName
