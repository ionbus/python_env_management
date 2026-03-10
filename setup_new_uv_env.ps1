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

function Convert-UvSpec([string]$Spec) {
  if ($Spec -match '^(python)(==|=)(.+)$') { return $null }
  if ($Spec -match '(==|>=|<=|~=|!=|>|<)') { return $Spec }
  if ($Spec -match '^([^=]+)=([^=].*)$') {
    return "$($matches[1])==$($matches[2])"
  }
  return $Spec
}

function Get-PythonVersion([string[]]$Specs) {
  foreach ($spec in $Specs) {
    if ($spec -match '^python(==|=)(.+)$') {
      return $matches[2]
    }
  }
  return "3.12"
}

if ($Architecture -notin @("auto","x64","arm64")) {
  $Packages = @($Architecture) + $Packages
  $Architecture = "auto"
}

if ($Packages.Count -eq 0) {
  throw "Usage: .\setup_new_uv_env.ps1 ENV_NAME [auto|x64|arm64] package1 package2 ..."
}

$ResolvedArch = if ($Architecture -eq "auto") { Get-DefaultArch } else { $Architecture }
$PythonVersion = Get-PythonVersion $Packages

$InstallSpecs = @()
$NeedsKernel = $false
foreach ($pkg in $Packages) {
  $base = ($pkg -replace '([=<>!~].*)$','')
  if ($base -eq 'ipykernel' -or $base -eq 'jupyter') {
    $NeedsKernel = $true
  }
  $converted = Convert-UvSpec $pkg
  if ($null -ne $converted -and $converted.Trim() -ne '') {
    $InstallSpecs += $converted
  }
}
if ($NeedsKernel -and -not ($InstallSpecs | Where-Object { $_ -match '^ipykernel([=<>!~].*)?$' })) {
  $InstallSpecs += "ipykernel"
}

$Base = $HOME
$UvEnvs = Join-Path $Base "uv_envs"
$EnvDir = Join-Path (Join-Path $UvEnvs $ResolvedArch) $EnvName

New-Item -ItemType Directory -Path (Split-Path $EnvDir -Parent) -Force | Out-Null

if (-not (Test-Path (Join-Path $EnvDir "Scripts\python.exe"))) {
  & uv venv $EnvDir --python $PythonVersion
  if ($LASTEXITCODE -ne 0) { throw "uv venv failed" }
}

$PythonExe = Join-Path $EnvDir "Scripts\python.exe"

if ($InstallSpecs.Count -gt 0) {
  & uv pip install --python $PythonExe @InstallSpecs
  if ($LASTEXITCODE -ne 0) { throw "uv pip install failed" }
}

if ($NeedsKernel) {
  & $PythonExe -m ipykernel install --user --name $EnvName --display-name $EnvName
}

Write-Host "uv environment setup complete:"
Write-Host "  Env dir:       $EnvDir"
Write-Host "  Architecture:  $ResolvedArch"
Write-Host "  Python:        $PythonVersion"
