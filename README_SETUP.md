<!-- TOC start (generated with https://bitdowntoc.derlin.ch/) -->

- [Setup scripts for new Pixi and uv environments](#setup-scripts-for-new-pixi-and-uv-environments)
- [Installing Pixi and uv](#installing-pixi-and-uv)
   * [Pixi installation](#pixi-installation)
      + [Windows (PowerShell)](#windows-powershell)
      + [Linux](#linux)
   * [uv installation](#uv-installation)
      + [Windows (PowerShell)](#windows-powershell-1)
      + [Linux](#linux-1)
- [Pixi detached environments](#pixi-detached-environments)
   * [Why use detached environments](#why-use-detached-environments)
   * [How these setup scripts configure detached environments](#how-these-setup-scripts-configure-detached-environments)
   * [Manual detached-environment setup example](#manual-detached-environment-setup-example)
      + [Windows PowerShell](#windows-powershell-2)
      + [Linux example](#linux-example)
   * [What changed in these scripts](#what-changed-in-these-scripts)
- [Default architecture behavior](#default-architecture-behavior)
- [Pixi commands](#pixi-commands)
   * [PowerShell](#powershell)
   * [cmd.exe](#cmdexe)
   * [Git Bash](#git-bash)
- [uv commands](#uv-commands)
   * [PowerShell](#powershell-1)
   * [cmd.exe](#cmdexe-1)
   * [Git Bash](#git-bash-1)
- [Important note about uv package syntax](#important-note-about-uv-package-syntax)
- [Important note about package names](#important-note-about-package-names)
- [What the scripts do](#what-the-scripts-do)
   * [Pixi scripts](#pixi-scripts)
   * [uv scripts](#uv-scripts)
- [Jupyter behavior](#jupyter-behavior)
   * [Pixi](#pixi)
   * [uv](#uv)
- [Examples](#examples)
   * [Conda reference](#conda-reference)
   * [Closest Pixi equivalent](#closest-pixi-equivalent)
   * [Closest uv equivalent](#closest-uv-equivalent)
- [Architecture notes](#architecture-notes)
   * [Pixi on Windows ARM](#pixi-on-windows-arm)
   * [uv on Windows ARM](#uv-on-windows-arm)
- [After setup](#after-setup)
   * [Pixi](#pixi-1)
   * [uv](#uv-1)
- [VS Code](#vs-code)
   * [Pixi](#pixi-2)
   * [uv](#uv-2)
- [Troubleshooting](#troubleshooting)
   * [PowerShell blocks scripts](#powershell-blocks-scripts)
   * [Git Bash + Pixi shell](#git-bash-pixi-shell)
   * [uv package install fails](#uv-package-install-fails)
   * [Pixi solve fails on ARM64](#pixi-solve-fails-on-arm64)

<!-- TOC end -->


# Setup scripts for new Pixi and uv environments

These scripts let you create new **Pixi** or **uv** environments using a command pattern that is closer to:

```bash
conda create -n ENV_NAME python=3.9 pandas=1.5.3 ...
```

They assume this layout under your Windows home directory:

- Pixi projects: `%USERPROFILE%\pixi_projects\`
- Pixi detached envs:
  - `%USERPROFILE%\pixi_envs\arm64\`
  - `%USERPROFILE%\pixi_envs\x64\`
- uv envs:
  - `%USERPROFILE%\uv_envs\arm64\`
  - `%USERPROFILE%\uv_envs\x64\`

Git Bash equivalents:

- `$HOME/pixi_projects`
- `$HOME/pixi_envs/arm64`
- `$HOME/pixi_envs/x64`
- `$HOME/uv_envs/arm64`
- `$HOME/uv_envs/x64`

---

# Installing Pixi and uv

## Pixi installation

Pixi’s official installation docs recommend the standalone installer, and note that rerunning the installer updates Pixi, or you can use `pixi self-update`. citeturn0search0turn0search16

### Windows (PowerShell)

```powershell
powershell -ExecutionPolicy Bypass -c "irm -useb https://pixi.sh/install.ps1 | iex"
```

### Linux

```bash
curl -fsSL https://pixi.sh/install.sh | bash
```

After installation, verify:

```bash
pixi --version
```

You can update later with:

```bash
pixi self-update
```

## uv installation

Astral’s official docs recommend the standalone installer on both Windows and Linux. citeturn0search1turn0search3turn0search7

### Windows (PowerShell)

```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

### Linux

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

After installation, verify:

```bash
uv --version
```

uv can also install Python on demand, and it can install specific Python versions with `uv python install 3.12`. citeturn0search11

---

# Pixi detached environments

Pixi’s `detached-environments` setting controls where workspace environments are stored instead of the default `.pixi/envs` folder inside the workspace. Pixi supports this in configuration, including per-project `.pixi/config.toml`. citeturn0search16

## Why use detached environments

With this layout:

- `pixi_projects\<env_name>\pixi.toml` contains the environment definition
- `pixi_envs\x64\...` or `pixi_envs\arm64\...` contains the actual installed environment

That gives you:

- a small, stable project-definition directory
- centralized installed environments
- ARM64 and x64 separation
- easier reuse across code and notebook folders that live elsewhere

## How these setup scripts configure detached environments

The Pixi setup scripts:

1. Create `%USERPROFILE%\pixi_projects\<EnvName>`
2. Create `%USERPROFILE%\pixi_envs\x64` or `%USERPROFILE%\pixi_envs\arm64`
3. Write:

```toml
detached-environments = "C:\\Users\\<you>\\pixi_envs\\x64"
```

or

```toml
detached-environments = "C:\\Users\\<you>\\pixi_envs\\arm64"
```

to:

```text
%USERPROFILE%\pixi_projects\<EnvName>\.pixi\config.toml
```

This makes the setting project-specific instead of global.

## Manual detached-environment setup example

If you want to do it by hand for a project:

### Windows PowerShell

```powershell
$proj = "$HOME\pixi_projects\myenv"
New-Item -ItemType Directory -Path $proj -Force | Out-Null
Set-Location $proj

pixi init --platform win-64

New-Item -ItemType Directory -Path ".pixi" -Force | Out-Null
@'
detached-environments = "C:\Users\YOURNAME\pixi_envs\x64"
'@ | Set-Content ".pixi\config.toml"

pixi add python=3.12 pandas=2.2
pixi install
```

### Linux example

On Linux, the same idea works with Linux paths:

```bash
mkdir -p "$HOME/pixi_projects/myenv"
cd "$HOME/pixi_projects/myenv"

pixi init --platform linux-64

mkdir -p .pixi
cat > .pixi/config.toml <<EOF
detached-environments = "$HOME/pixi_envs/x64"
EOF

pixi add python=3.12 pandas=2.2
pixi install
```

---

## What changed in these scripts

The setup scripts now work like this:

- First argument: **environment name**
- Second argument: **optional architecture**
  - `auto` (default)
  - `x64`
  - `arm64`
- Remaining arguments: **package specs**

That means you can run commands similar to conda, instead of using separate `-PythonVersion` and `-PandasVersion` parameters.

---

# Default architecture behavior

If you do not specify an architecture, the scripts choose a default based on the computer:

- On an **ARM64 Windows machine**:
  - Pixi default platform: `win-arm64`
  - uv default architecture: `arm64`

- On an **x64 / Intel / AMD Windows machine**:
  - Pixi default platform: `win-64`
  - uv default architecture: `x64`

You can override this explicitly by passing `x64` or `arm64` as the second argument.

---

# Pixi commands

## PowerShell

```powershell
.\setup_new_pixi_env.ps1 python_39_pd15 python=3.9 pandas=1.5.3 python-pyranha python-core-utils ipython jupyter matplotlib plotly openpyxl duckdb=1 attrs=23.1 pyarrow-all=16 polars=1.26 cryptography backports.strenum
```

Force x64:

```powershell
.\setup_new_pixi_env.ps1 python_39_pd15 x64 python=3.9 pandas=1.5.3 ipython jupyter matplotlib
```

Force arm64:

```powershell
.\setup_new_pixi_env.ps1 python_39_pd15 arm64 python=3.9 pandas=1.5.3
```

## cmd.exe

```cmd
setup_new_pixi_env.bat python_39_pd15 python=3.9 pandas=1.5.3 python-pyranha python-core-utils ipython jupyter matplotlib plotly openpyxl duckdb=1 attrs=23.1 pyarrow-all=16 polars=1.26 cryptography backports.strenum
```

Force x64:

```cmd
setup_new_pixi_env.bat python_39_pd15 x64 python=3.9 pandas=1.5.3 ipython jupyter matplotlib
```

## Git Bash

```bash
./setup_new_pixi_env.sh python_39_pd15 python=3.9 pandas=1.5.3 python-pyranha python-core-utils ipython jupyter matplotlib plotly openpyxl duckdb=1 attrs=23.1 pyarrow-all=16 polars=1.26 cryptography backports.strenum
```

Force arm64:

```bash
./setup_new_pixi_env.sh python_39_pd15 arm64 python=3.9 pandas=1.5.3
```

---

# uv commands

## PowerShell

```powershell
.\setup_new_uv_env.ps1 python_39_pd15 python=3.9 pandas=1.5.3 ipython jupyter matplotlib plotly openpyxl duckdb=1 attrs=23.1 pyarrow=16 polars=1.26 cryptography
```

Force arm64:

```powershell
.\setup_new_uv_env.ps1 python_39_pd15 arm64 python=3.9 pandas=1.5.3 ipython jupyter
```

## cmd.exe

```cmd
setup_new_uv_env.bat python_39_pd15 python=3.9 pandas=1.5.3 ipython jupyter matplotlib plotly openpyxl duckdb=1 attrs=23.1 pyarrow=16 polars=1.26 cryptography
```

## Git Bash

```bash
./setup_new_uv_env.sh python_39_pd15 python=3.9 pandas=1.5.3 ipython jupyter matplotlib plotly openpyxl duckdb=1 attrs=23.1 pyarrow=16 polars=1.26 cryptography
```

Force x64:

```bash
./setup_new_uv_env.sh python_39_pd15 x64 python=3.9 pandas=1.5.3
```

---

# Important note about uv package syntax

These uv scripts accept **conda-like** version specs such as:

- `python=3.9`
- `pandas=1.5.3`
- `duckdb=1`
- `attrs=23.1`

For uv, the scripts automatically convert simple `name=version` specs into pip-style `name==version` specs.

Examples:

- `pandas=1.5.3` → `pandas==1.5.3`
- `duckdb=1` → `duckdb==1`

The special case is `python=...`:

- For uv, `python=3.9` is used to choose the interpreter passed to `uv venv --python 3.9`
- It is **not** passed through to `uv pip install`

---

# Important note about package names

A conda package name is not always the same as a PyPI package name.

For example:

- something that works in Pixi / conda may not exist on PyPI for uv
- something that exists on PyPI may have a different name or version scheme

So a command that works for Pixi may still need package-name adjustments for uv.

That is expected.

---

# What the scripts do

## Pixi scripts

1. Create `%USERPROFILE%\pixi_projects\<EnvName>`
2. Detect architecture (`auto`) or use the one you specified
3. Map architecture to Pixi platform:
   - `x64` → `win-64`
   - `arm64` → `win-arm64`
4. Run `pixi init --platform <platform>` if needed
5. Create `.pixi\config.toml`
6. Point detached environments to:
   - `%USERPROFILE%\pixi_envs\x64`
   - or `%USERPROFILE%\pixi_envs\arm64`
7. Add all package specs with `pixi add`
8. Run `pixi install`
9. If `ipykernel` is present in the package list, register a Jupyter kernel

## uv scripts

1. Create `%USERPROFILE%\uv_envs\<arch>\<EnvName>`
2. Detect architecture (`auto`) or use the one you specified
3. Extract `python=...` if present
4. Create the venv with `uv venv ... --python ...`
5. Convert simple `name=version` specs into pip-compatible `name==version`
6. Install packages with `uv pip install`
7. If `ipykernel` or `jupyter` is in the package list, ensure `ipykernel` is installed and register a Jupyter kernel

---

# Jupyter behavior

## Pixi

If your package list includes:

- `ipykernel`

the script registers a kernel with:

- name = environment name
- display name = environment name

## uv

If your package list includes either:

- `ipykernel`
- or `jupyter`

the script makes sure `ipykernel` is available and registers the kernel.

---

# Examples

## Conda reference

```bash
conda create -n python_39_pd15 python=3.9 pandas=1.5.3 python-pyranha python-core-utils ipython jupyter matplotlib plotly openpyxl duckdb=1 attrs=23.1 pyarrow-all=16 polars=1.26 cryptography backports.strenum
```

## Closest Pixi equivalent

```bash
setup_new_pixi_env.bat python_39_pd15 python=3.9 pandas=1.5.3 python-pyranha python-core-utils ipython jupyter matplotlib plotly openpyxl duckdb=1 attrs=23.1 pyarrow-all=16 polars=1.26 cryptography backports.strenum
```

## Closest uv equivalent

```bash
setup_new_uv_env.bat python_39_pd15 python=3.9 pandas=1.5.3 ipython jupyter matplotlib plotly openpyxl duckdb=1 attrs=23.1 pyarrow=16 polars=1.26 cryptography
```

---

# Architecture notes

## Pixi on Windows ARM

Pixi / conda-forge support for `win-arm64` is still uneven for some packages.

If a Pixi ARM64 solve fails, retry with:

- `x64` architecture
- which maps to `win-64`

Example:

```powershell
.\setup_new_pixi_env.ps1 python_39_pd15 x64 python=3.9 pandas=1.5.3
```

## uv on Windows ARM

uv can usually install native ARM64 CPython and then use PyPI wheels.

This often works better than Pixi on Windows ARM for Python-version availability. citeturn0search11

---

# After setup

## Pixi

Activate:
```powershell
cd $HOME\pixi_projects\python_39_pd15
pixi shell
```

Run without activation:
```powershell
pixi run --manifest-path "$HOME\pixi_projects\python_39_pd15\pixi.toml" python script.py
```

## uv

Activate:
```powershell
& "$HOME\uv_envs\arm64\python_39_pd15\Scripts\Activate.ps1"
```

Run without activation:
```powershell
& "$HOME\uv_envs\arm64\python_39_pd15\Scripts\python.exe" script.py
```

---

# VS Code

## Pixi
- Open your code folder
- `Python: Select Interpreter`
- Choose the interpreter under the relevant detached env

## uv
- Open your code folder
- `Python: Select Interpreter`
- Choose:
  - `%USERPROFILE%\uv_envs\arm64\<env>\Scripts\python.exe`
  - or `%USERPROFILE%\uv_envs\x64\<env>\Scripts\python.exe`

For notebooks, pick the kernel registered by the setup script.

---

# Troubleshooting

## PowerShell blocks scripts
```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

## Git Bash + Pixi shell
```bash
eval "$(pixi shell-hook)"
```

## uv package install fails
That often means:
- the package name is different on PyPI
- or that version / wheel does not exist for that platform

## Pixi solve fails on ARM64
Retry with:
```powershell
.\setup_new_pixi_env.ps1 myenv x64 python=...
```
