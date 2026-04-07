#!/usr/bin/env bash
set -euo pipefail

BASE="$HOME"
PIXI_PROJECTS="$BASE/pixi_projects"
UV_ENVS="$BASE/uv_envs"

if [[ $# -lt 1 ]]; then
  echo "Usage: source activate_env.sh ENV_NAME"
  return 2 2>/dev/null || exit 2
fi

ENVNAME="$1"
MANIFEST="${PIXI_PROJECTS}/${ENVNAME}/pixi.toml"

if [[ -f "$MANIFEST" ]]; then
  eval "$(pixi shell-hook)" >/dev/null 2>&1 || true
  pixi shell --manifest-path "$MANIFEST"
  return $?
fi

UV_ARM="${UV_ENVS}/arm64/${ENVNAME}"
UV_X64="${UV_ENVS}/x64/${ENVNAME}"

OS="$(uname -s)"
case "$OS" in
  Darwin|Linux) SCRIPTS_REL="bin" ;;
  *)            SCRIPTS_REL="Scripts" ;;
esac

if [[ -f "${UV_ARM}/${SCRIPTS_REL}/activate" ]]; then
  source "${UV_ARM}/${SCRIPTS_REL}/activate"
  return 0
fi

if [[ -f "${UV_X64}/${SCRIPTS_REL}/activate" ]]; then
  source "${UV_X64}/${SCRIPTS_REL}/activate"
  return 0
fi

if command -v conda >/dev/null 2>&1; then
  eval "$(conda shell.bash hook)"
  conda activate "$ENVNAME"
else
  echo "ERROR: conda not found."
  return 1 2>/dev/null || exit 1
fi
