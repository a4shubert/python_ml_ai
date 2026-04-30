#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
VENV_DIR="${REPO_ROOT}/.venv"
JUPYTER_BIN="${VENV_DIR}/bin/jupyter"
NOTEBOOK_DIR="${REPO_ROOT}/notebook"

if [[ ! -x "${JUPYTER_BIN}" ]]; then
  printf '\n[start] Missing %s. Run ./scripts/setup.sh first.\n' "${JUPYTER_BIN}" >&2
  exit 1
fi

mkdir -p "${NOTEBOOK_DIR}"

cd "${NOTEBOOK_DIR}"
exec "${JUPYTER_BIN}" nbclassic
