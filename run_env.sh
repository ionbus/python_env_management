#!/usr/bin/env bash
set -euo pipefail

BASE="$HOME"
PIXI_PROJECTS="$BASE/pixi_projects"
UV_ENVS="$BASE/uv_envs"

if [[ $# -lt 2 ]]; then
  echo "Usage: run_env.sh ENV_NAME command [args...]"
  exit 2
fi

ENVNAME="$1"
shift

MANIFEST="${PIXI_PROJECTS}/${ENVNAME}/pixi.toml"
if [[ -f "$MANIFEST" ]]; then
  pixi run --manifest-path "$MANIFEST" -- "$@"
  exit $?
fi

UV_ARM="${UV_ENVS}/arm64/${ENVNAME}"
UV_X64="${UV_ENVS}/x64/${ENVNAME}"

if [[ -x "${UV_ARM}/Scripts/python.exe" ]]; then
  VIRTUAL_ENV="$UV_ARM" PATH="${UV_ARM}/Scripts:$PATH" "$@"
  exit $?
fi

if [[ -x "${UV_X64}/Scripts/python.exe" ]]; then
  VIRTUAL_ENV="$UV_X64" PATH="${UV_X64}/Scripts:$PATH" "$@"
  exit $?
fi

if command -v conda >/dev/null 2>&1; then
  conda run -n "$ENVNAME" "$@"
else
  echo "ERROR: conda not found."
  exit 1
fi
