#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SETUP_SCRIPT="${SCRIPT_DIR}/scripts/setup.sh"
START_SCRIPT="${SCRIPT_DIR}/scripts/start.sh"
VENV_PYTHON="${SCRIPT_DIR}/.venv/bin/python"

log() {
  printf '\n[%s] %s\n' "run" "$1"
}

if [[ ! -x "${SETUP_SCRIPT}" ]]; then
  printf '\n[%s] Missing %s\n' "run" "${SETUP_SCRIPT}" >&2
  exit 1
fi

if [[ ! -x "${START_SCRIPT}" ]]; then
  printf '\n[%s] Missing %s\n' "run" "${START_SCRIPT}" >&2
  exit 1
fi

log "Installing and syncing the course environment"
"${SETUP_SCRIPT}"

if [[ ! -x "${VENV_PYTHON}" ]]; then
  printf '\n[%s] Missing %s after setup\n' "run" "${VENV_PYTHON}" >&2
  exit 1
fi

log "Verifying core notebook packages"
"${VENV_PYTHON}" - <<'PY'
import importlib

modules = [
    "numpy",
    "pandas",
    "scipy",
    "matplotlib",
    "seaborn",
    "pyarrow",
    "notebook",
    "nbclassic",
]

for name in modules:
    module = importlib.import_module(name)
    version = getattr(module, "__version__", "unknown")
    print(f"{name} {version}")
PY

log "Launching Jupyter Classic in the notebooks folder"
exec "${START_SCRIPT}"
