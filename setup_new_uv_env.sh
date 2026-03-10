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

if [[ $# -lt 1 ]]; then
  echo "No packages provided."
  exit 2
fi

convert_spec() {
  local spec="$1"
  if [[ "$spec" =~ ^python(==|=)(.+)$ ]]; then
    return 1
  fi
  if [[ "$spec" == *"=="* || "$spec" == *">="* || "$spec" == *"<="* || "$spec" == *"~="* || "$spec" == *"!="* || "$spec" == *">"* || "$spec" == *"<"* ]]; then
    printf '%s\n' "$spec"
    return 0
  fi
  if [[ "$spec" == *=* ]]; then
    local left="${spec%%=*}"
    local right="${spec#*=}"
    printf '%s==%s\n' "$left" "$right"
    return 0
  fi
  printf '%s\n' "$spec"
}

PYVER="3.12"
NEEDS_KERNEL="no"
INSTALL_SPECS=()

for spec in "$@"; do
  base="${spec%%[=<>!~]*}"
  if [[ "$base" == "python" ]]; then
    PYVER="${spec#*=}"
    PYVER="${PYVER#==}"
    continue
  fi
  if [[ "$base" == "ipykernel" || "$base" == "jupyter" ]]; then
    NEEDS_KERNEL="yes"
  fi
  if converted="$(convert_spec "$spec")"; then
    INSTALL_SPECS+=("$converted")
  fi
done

has_ipykernel="no"
for spec in "${INSTALL_SPECS[@]}"; do
  base="${spec%%[=<>!~]*}"
  if [[ "$base" == "ipykernel" ]]; then
    has_ipykernel="yes"
  fi
done
if [[ "$NEEDS_KERNEL" == "yes" && "$has_ipykernel" == "no" ]]; then
  INSTALL_SPECS+=("ipykernel")
fi

BASE="$HOME"
UV_ENVS="$BASE/uv_envs"
ENVDIR="$UV_ENVS/$RESOLVED_ARCH/$ENVNAME"

mkdir -p "$UV_ENVS/$RESOLVED_ARCH"

if [[ ! -x "$ENVDIR/Scripts/python.exe" ]]; then
  uv venv "$ENVDIR" --python "$PYVER"
fi

PYTHONEXE="$ENVDIR/Scripts/python.exe"

if [[ ${#INSTALL_SPECS[@]} -gt 0 ]]; then
  uv pip install --python "$PYTHONEXE" "${INSTALL_SPECS[@]}"
fi

if [[ "$NEEDS_KERNEL" == "yes" ]]; then
  "$PYTHONEXE" -m ipykernel install --user --name "$ENVNAME" --display-name "$ENVNAME"
fi

echo "uv environment setup complete:"
echo "  Env dir:       $ENVDIR"
echo "  Architecture:  $RESOLVED_ARCH"
echo "  Python:        $PYVER"
