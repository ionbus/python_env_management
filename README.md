# Environment Management (Pixi + uv + Conda)

## Commands (for interactive shells)

If the user has sourced `env_functions.ps1` or `env_functions.sh` in their
shell profile, these commands work the same in PowerShell, Bash, and Zsh.

### Create environments

```
new-pixi myenv python=3.11 pandas=2.2 ipython jupyter
new-uv myenv python=3.11 pandas=2.2 ipython jupyter
```

With explicit architecture:

```
new-pixi myenv x64 python=3.11 pandas=2.2
new-pixi myenv arm64 python=3.11 pandas=2.2
```

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

---

## Detailed setup guide

For creating new environments with full options, see [create_environment.md](create_environment.md).

---

## Shell Profile Setup

The commands above require sourcing the function files in your shell profile.

### PowerShell

Add to your profile (`$PROFILE`):

```powershell
. "$HOME\bin\env_functions.ps1"
```

### Bash / Zsh

Add to `~/.bashrc` or `~/.zshrc`:

```bash
source "$HOME/bin/env_functions.sh"
```

### Prerequisites

1. Place these scripts in `~/bin` (or `%USERPROFILE%\bin`)
2. Add that directory to PATH
3. Source the function file as shown above

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
- uv environments are detected via `Scripts/python.exe`
- Conda fallback requires conda to be on PATH

---

## For AI Assistants (Claude Code, Codex, etc.)

This directory is located at `~/bin` (`$HOME/bin` or `%USERPROFILE%\bin`).

**Important:** AI assistants run commands in non-interactive shells, which do
NOT source `.bashrc` or `$PROFILE`. The shell wrapper functions (`new-pixi`,
`activate-env`, etc.) will NOT be available. Always use full script paths.

### Quick reference

| Shell | Run in env (most common) | Create env | Activate env |
|-------|--------------------------|------------|--------------|
| Git Bash | `$HOME/bin/run_env.sh myenv python script.py` | `$HOME/bin/setup_new_pixi_env.sh myenv python=3.11` | `source $HOME/bin/activate_env.sh myenv` |
| PowerShell | `& "$HOME\bin\run_env.ps1" myenv python script.py` | `& "$HOME\bin\setup_new_pixi_env.ps1" myenv python=3.11` | `. "$HOME\bin\activate_env.ps1" myenv` |
| cmd.exe | `%USERPROFILE%\bin\run_env.bat myenv python script.py` | `%USERPROFILE%\bin\setup_new_pixi_env.bat myenv "python=3.11"` | `%USERPROFILE%\bin\activate_env.bat myenv` |

### Key differences

- cmd.exe requires quoting arguments with `=` (e.g., `"python=3.11"`)
- Activation in Bash requires `source`, in PowerShell requires leading `.`
- Pixi is preferred over uv; both are preferred over conda
- For Pixi envs, you can also run directly: `pixi run --manifest-path ~/pixi_projects/myenv/pixi.toml python script.py`
