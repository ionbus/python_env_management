#!/usr/bin/env bash
set -euo pipefail

BASE="$HOME"
PIXI_PROJECTS="$BASE/pixi_projects"
UV_ENVS="$BASE/uv_envs"

echo "Pixi Environments:"
for d in "$PIXI_PROJECTS"/*; do
  [[ -f "$d/pixi.toml" ]] && echo "[pixi] $(basename "$d")"
done

OS="$(uname -s)"
case "$OS" in
  Darwin|Linux) PYTHON_REL="bin/python" ;;
  *)            PYTHON_REL="Scripts/python.exe" ;;
esac

echo
echo "uv arm64 Environments:"
for d in "$UV_ENVS/arm64"/*; do
  [[ -x "$d/$PYTHON_REL" ]] && echo "[uv-arm64] $(basename "$d")"
done

echo
echo "uv x64 Environments:"
for d in "$UV_ENVS/x64"/*; do
  [[ -x "$d/$PYTHON_REL" ]] && echo "[uv-x64] $(basename "$d")"
done

echo
echo "Conda Environments:"
if command -v conda >/dev/null 2>&1; then
  conda env list | grep -v '^#'
else
  echo "conda not found"
fi
