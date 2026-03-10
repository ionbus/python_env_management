#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 ENV_NAME [auto|x64|arm64] package1 package2 ..."
  exit 2
fi

ENVNAME="$1"
shift

ARCH="${1:-auto}"
if [[ "$ARCH" == "auto" || "$ARCH" == "x64" || "$ARCH" == "arm64" ]]; then
  shift || true
else
  ARCH="auto"
fi

if [[ "$ARCH" == "auto" ]]; then
  machine="$(uname -m | tr '[:upper:]' '[:lower:]')"
  if [[ "$machine" == "aarch64" || "$machine" == "arm64" ]]; then
    RESOLVED_ARCH="arm64"
  else
    RESOLVED_ARCH="x64"
  fi
else
  RESOLVED_ARCH="$ARCH"
fi

if [[ "$RESOLVED_ARCH" == "arm64" ]]; then
  PLATFORM="win-arm64"
else
  PLATFORM="win-64"
fi

if [[ $# -lt 1 ]]; then
  echo "No packages provided."
  exit 2
fi

BASE="$HOME"
PIXI_PROJECTS="$BASE/pixi_projects"
PIXI_ENVS="$BASE/pixi_envs"
PROJECTDIR="$PIXI_PROJECTS/$ENVNAME"
DETACHEDROOT="$PIXI_ENVS/$RESOLVED_ARCH"

mkdir -p "$PROJECTDIR" "$DETACHEDROOT"
cd "$PROJECTDIR"

if [[ ! -f "pixi.toml" ]]; then
  pixi init --platform "$PLATFORM"
fi

mkdir -p ".pixi"
cat > ".pixi/config.toml" <<EOF
detached-environments = "${DETACHEDROOT//\\/\\\\}"
EOF

pixi add "$@"
pixi install

has_kernel="no"
for pkg in "$@"; do
  base_pkg="${pkg%%[=<>!~]*}"
  if [[ "$base_pkg" == "ipykernel" ]]; then
    has_kernel="yes"
  fi
done

if [[ "$has_kernel" == "yes" ]]; then
  pixi run python -m ipykernel install --user --name "$ENVNAME" --display-name "$ENVNAME"
fi

echo "Pixi environment setup complete:"
echo "  Project:       $PROJECTDIR"
echo "  Architecture:  $RESOLVED_ARCH"
echo "  Platform:      $PLATFORM"
echo "  Detached root: $DETACHEDROOT"
