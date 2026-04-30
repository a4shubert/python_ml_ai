#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
REQUIREMENTS_FILE="${REPO_ROOT}/requirements-ds-ml.txt"
PYTHON_VERSION="${PYTHON_VERSION:-3.11}"
UV_INSTALL_DIR="${REPO_ROOT}/.tools/uv"
UV_BIN="${UV_INSTALL_DIR}/uv"
VENV_DIR="${REPO_ROOT}/.venv"
VENV_PYTHON="${VENV_DIR}/bin/python"
KERNEL_NAME="python-course-3.11"
KERNEL_DISPLAY_NAME="Python Course 3.11"

log() {
  printf '\n[%s] %s\n' "setup" "$1"
}

fail() {
  printf '\n[%s] %s\n' "setup" "$1" >&2
  exit 1
}

download_and_install_uv() {
  mkdir -p "${UV_INSTALL_DIR}"

  if command -v curl >/dev/null 2>&1; then
    curl -LsSf https://astral.sh/uv/install.sh | env UV_UNMANAGED_INSTALL="${UV_INSTALL_DIR}" sh
    return
  fi

  if command -v wget >/dev/null 2>&1; then
    wget -qO- https://astral.sh/uv/install.sh | env UV_UNMANAGED_INSTALL="${UV_INSTALL_DIR}" sh
    return
  fi

  fail "Neither curl nor wget is available, so uv cannot be installed automatically."
}

if [[ ! -f "${REQUIREMENTS_FILE}" ]]; then
  fail "Missing ${REQUIREMENTS_FILE}. Run this script from the course repository."
fi

if [[ ! -x "${UV_BIN}" ]]; then
  log "Installing local uv bootstrapper into ${UV_INSTALL_DIR}"
  download_and_install_uv
fi

if [[ ! -x "${UV_BIN}" ]]; then
  fail "uv installation did not produce ${UV_BIN}"
fi

log "Ensuring Python ${PYTHON_VERSION} is available"
"${UV_BIN}" python install "${PYTHON_VERSION}"

log "Creating virtual environment at ${VENV_DIR}"
"${UV_BIN}" venv --clear --python "${PYTHON_VERSION}" "${VENV_DIR}"

log "Syncing packages from ${REQUIREMENTS_FILE}"
"${UV_BIN}" pip sync --python "${VENV_PYTHON}" "${REQUIREMENTS_FILE}"

log "Registering Jupyter kernel ${KERNEL_NAME}"
"${VENV_PYTHON}" -m ipykernel install --user --name "${KERNEL_NAME}" --display-name "${KERNEL_DISPLAY_NAME}"

cat <<EOF

Environment is ready.

Activate it with:
  source "${VENV_DIR}/bin/activate"

Start the classic notebook UI with:
  jupyter nbclassic
EOF
