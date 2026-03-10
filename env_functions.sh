# Environment management functions for Bash/Zsh
# Source this file from your shell profile (~/.bashrc or ~/.zshrc):
#   source "$HOME/bin/env_functions.sh"

_ENV_BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

activate-env() {
    # Activate a Pixi, uv, or conda environment by name.
    # Usage: activate-env python_311_pd15
    if [ -z "$1" ]; then
        echo "Usage: activate-env <env_name>" >&2
        return 1
    fi
    source "$_ENV_BIN_DIR/activate_env.sh" "$1"
}

new-pixi() {
    # Create a new Pixi environment.
    # Usage: new-pixi myenv python=3.11 pandas=2.2 ipython
    #        new-pixi myenv x64 python=3.11 pandas=2.2
    "$_ENV_BIN_DIR/setup_new_pixi_env.sh" "$@"
}

new-uv() {
    # Create a new uv environment.
    # Usage: new-uv myenv python=3.11 pandas=2.2 ipython
    #        new-uv myenv arm64 python=3.11 pandas=2.2
    "$_ENV_BIN_DIR/setup_new_uv_env.sh" "$@"
}

list-envs() {
    # List available Pixi, uv, and conda environments.
    "$_ENV_BIN_DIR/list_envs.sh"
}

run-env() {
    # Run a command in an environment without activating it.
    # Usage: run-env python_311_pd15 python script.py
    "$_ENV_BIN_DIR/run_env.sh" "$@"
}
