# Environment Management (Pixi + uv + Conda)

## Commands (for interactive shells)

If the user has sourced `env_functions.ps1` or `env_functions.sh` in their
shell profile, these commands work the same in PowerShell, Bash, and Zsh.

### Create environments

```
new-pixi myenv python=3.11 pandas=2.2 ipython jupyter
new-uv myenv python=3.11 pandas=2.2 ipython jupyter
```

With explicit architecture (see [when and why](#forcing-x64-on-arm-machines)):

```
new-pixi myenv x64 python=3.11 pandas=2.2
new-pixi myenv arm64 python=3.11 pandas=2.2
```

> **Windows cmd.exe:** `=` is treated as an argument separator, so any argument containing `=` must be quoted:
> ```cmd
> new-pixi myenv "python=3.11" "pandas=2.2" ipython
> ```

### Activate an environment

```
activate-env myenv
```

Searches in order: Pixi -> uv -> conda

### List environments

```
list-envs
```

### Run without activating (Bash only)

```
run-env myenv python script.py
```

---

## Directory layout

Environments are stored in:

- Pixi projects: `~/pixi_projects/<env_name>/`
- Pixi envs: `~/pixi_envs/x64/` or `~/pixi_envs/arm64/`
- uv envs: `~/uv_envs/x64/<env_name>/` or `~/uv_envs/arm64/<env_name>/`

The `x64` or `arm64` subdirectory is chosen automatically based on your machine. The Pixi platform name embedded in `pixi.toml` also varies by OS:

| Machine | Arch dir | Pixi platform |
|---------|----------|---------------|
| Mac Apple Silicon (M1/M2/M3/M4) | `arm64` | `osx-arm64` |
| Mac Intel | `x64` | `osx-64` |
| Windows ARM | `arm64` | `win-arm64` |
| Windows x64 / Intel / AMD | `x64` | `win-64` |
| Linux ARM64 | `arm64` | `linux-aarch64` |
| Linux x64 | `x64` | `linux-64` |

### Forcing x64 on ARM machines

On ARM64 machines (Mac Apple Silicon or Windows ARM), you can pass `x64` explicitly to create an x64 environment instead:

```bash
new-pixi myenv x64 python=3.11 pandas=2.2
new-uv   myenv x64 python=3.11 pandas=2.2
```

**When to do this:**

- **Windows ARM** — `win-arm64` conda-forge coverage is still uneven; some packages only have `win-64` builds. If a Pixi solve fails, retry with `x64`.
- **Mac Apple Silicon** — `osx-arm64` coverage on conda-forge is generally excellent, so this is rarely needed. However, if a package has no native arm64 build, forcing `x64` will use the `osx-64` build instead, which runs transparently under Rosetta 2.

On Intel/x64 machines there is no equivalent fallback — you get the native x64 build.

---

## Detailed setup guide

For creating new environments with full options, see [create_environment.md](create_environment.md).

---

## Shell Profile Setup

The commands above require sourcing the function files in your shell profile.

### PowerShell

Add to your profile (`$PROFILE`):

```powershell
. "$HOME\bin\python_env_management\env_functions.ps1"
```

### Bash / Zsh

Add to `~/.bashrc` or `~/.zshrc`:

```bash
source "$HOME/bin/python_env_management/env_functions.sh"
```

### Prerequisites

1. Clone or place these scripts in `~/bin/python_env_management`
2. Source the function file as shown above (this also adds the directory to PATH)

---

## Using scripts directly (without sourcing)

If you don't want to modify your shell profile, you can call the underlying
scripts directly. Note that activation scripts must be sourced/dot-sourced
to affect your current shell.

### PowerShell

```powershell
# Create environments
.\setup_new_pixi_env.ps1 myenv python=3.11 pandas=2.2 ipython
.\setup_new_uv_env.ps1 myenv python=3.11 pandas=2.2 ipython

# Activate (must dot-source with leading dot)
. .\activate_env.ps1 myenv
```

### Bash / Zsh

```bash
# Create environments
./setup_new_pixi_env.sh myenv python=3.11 pandas=2.2 ipython
./setup_new_uv_env.sh myenv python=3.11 pandas=2.2 ipython

# Activate (must source)
source ./activate_env.sh myenv

# List and run
./list_envs.sh
./run_env.sh myenv python script.py
```

### cmd.exe

```cmd
:: Create environments (quote arguments with =)
setup_new_pixi_env.bat myenv "python=3.11" "pandas=2.2" ipython
setup_new_uv_env.bat myenv "python=3.11" "pandas=2.2" ipython

:: Activate
activate_env.bat myenv

:: List and run
list_envs.bat
run_env.bat myenv python script.py
```

---

## Notes

- Pixi activation launches a managed subshell
- uv environments are detected via `bin/python` (Mac/Linux) or `Scripts/python.exe` (Windows)
- Conda fallback requires conda to be on PATH

---

## For AI Assistants (Claude Code, Codex, etc.)

This directory is located at `~/bin/python_env_management` (`$HOME/bin/python_env_management` or `%USERPROFILE%\bin\python_env_management`).

**Important:** AI assistants run commands in non-interactive shells, which do
NOT source `.bashrc` or `$PROFILE`. The shell wrapper functions (`new-pixi`,
`activate-env`, etc.) will NOT be available. Always use full script paths.

### Quick reference

| Shell | Run in env (most common) | Create env | Activate env |
|-------|--------------------------|------------|--------------|
| Git Bash | `$HOME/bin/python_env_management/run_env.sh myenv python script.py` | `$HOME/bin/python_env_management/setup_new_pixi_env.sh myenv python=3.11` | `source $HOME/bin/python_env_management/activate_env.sh myenv` |
| PowerShell | `& "$HOME\bin\python_env_management\run_env.ps1" myenv python script.py` | `& "$HOME\bin\python_env_management\setup_new_pixi_env.ps1" myenv python=3.11` | `. "$HOME\bin\python_env_management\activate_env.ps1" myenv` |
| cmd.exe | `%USERPROFILE%\bin\python_env_management\run_env.bat myenv python script.py` | `%USERPROFILE%\bin\python_env_management\setup_new_pixi_env.bat myenv "python=3.11"` | `%USERPROFILE%\bin\python_env_management\activate_env.bat myenv` |

### Key differences

- cmd.exe requires quoting arguments with `=` (e.g., `"python=3.11"`)
- Activation in Bash requires `source`, in PowerShell requires leading `.`
- Pixi is preferred over uv; both are preferred over conda
- For Pixi envs, you can also run directly: `pixi run --manifest-path ~/pixi_projects/myenv/pixi.toml python script.py`
