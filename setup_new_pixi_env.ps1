param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$EnvName,

  [Parameter(Position = 1)]
  [string]$Architecture = "auto",

  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$Packages
)

function Get-DefaultArch {
  if ($env:PROCESSOR_ARCHITECTURE -match "ARM64" -or $env:PROCESSOR_ARCHITEW6432 -match "ARM64") {
    return "arm64"
  }
  return "x64"
}

if ($Architecture -notin @("auto","x64","arm64")) {
  $Packages = @($Architecture) + $Packages
  $Architecture = "auto"
}

if ($Packages.Count -eq 0) {
  throw "Usage: .\setup_new_pixi_env.ps1 ENV_NAME [auto|x64|arm64] package1 package2 ..."
}

$ResolvedArch = if ($Architecture -eq "auto") { Get-DefaultArch } else { $Architecture }
$Platform = if ($ResolvedArch -eq "arm64") { "win-arm64" } else { "win-64" }

$Base = $HOME
$PixiProjects = Join-Path $Base "pixi_projects"
$PixiEnvs = Join-Path $Base "pixi_envs"
$ProjectDir = Join-Path $PixiProjects $EnvName
$DetachedRoot = Join-Path $PixiEnvs $ResolvedArch

New-Item -ItemType Directory -Path $ProjectDir -Force | Out-Null
New-Item -ItemType Directory -Path $DetachedRoot -Force | Out-Null

Push-Location $ProjectDir
try {
  if (-not (Test-Path (Join-Path $ProjectDir "pixi.toml"))) {
    & pixi init --platform $Platform
    if ($LASTEXITCODE -ne 0) { throw "pixi init failed" }
  }

  New-Item -ItemType Directory -Path (Join-Path $ProjectDir ".pixi") -Force | Out-Null
  @"
detached-environments = "$($DetachedRoot.Replace('\','\\'))"
"@ | Set-Content (Join-Path $ProjectDir ".pixi\config.toml")

  & pixi add @Packages
  if ($LASTEXITCODE -ne 0) { throw "pixi add failed" }

  & pixi install
  if ($LASTEXITCODE -ne 0) { throw "pixi install failed" }

  $hasKernel = $false
  foreach ($pkg in $Packages) {
    if ($pkg -match '^ipykernel([=<>!~].*)?$') {
      $hasKernel = $true
      break
    }
  }

  if ($hasKernel) {
    & pixi run python -m ipykernel install --user --name $EnvName --display-name $EnvName
  }

  Write-Host "Pixi environment setup complete:"
  Write-Host "  Project:       $ProjectDir"
  Write-Host "  Architecture:  $ResolvedArch"
  Write-Host "  Platform:      $Platform"
  Write-Host "  Detached root: $DetachedRoot"
}
finally {
  Pop-Location
}
