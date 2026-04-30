#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
VENV_DIR="${REPO_ROOT}/.venv"
VENV_PYTHON="${VENV_DIR}/bin/python"
JUPYTER_BIN="${VENV_DIR}/bin/jupyter"
NOTEBOOK_DIR="${REPO_ROOT}/notebooks"

log() {
  printf '\n[%s] %s\n' "start" "$1"
}

fail() {
  printf '\n[%s] %s\n' "start" "$1" >&2
  exit 1
}

if [[ ! -x "${JUPYTER_BIN}" ]]; then
  fail "Missing ${JUPYTER_BIN}. Run ./scripts/setup.sh first."
fi

mkdir -p "${NOTEBOOK_DIR}"

log "Running notebook server preflight checks"
"${VENV_PYTHON}" - <<'PY'
import importlib
import sys

required = ["jupyter_server", "jupyter_events", "yaml", "overrides", "nbclassic"]

for name in required:
    try:
        importlib.import_module(name)
    except Exception as exc:
        print(
            f"[start] Missing or broken Python package '{name}': {exc}\n"
            "[start] Rebuild the environment with ./scripts/setup.sh or "
            "./.tools/uv/uv pip sync --python .venv/bin/python requirements-ds-ml.txt.",
            file=sys.stderr,
        )
        raise SystemExit(1)
PY

log "Opening notebooks from ${NOTEBOOK_DIR}"
log "Startup may take a moment on first launch. If you press Ctrl-C during import or server startup, Python may show a traceback even though the installation is fine."

cd "${NOTEBOOK_DIR}"
exec "${JUPYTER_BIN}" nbclassic
