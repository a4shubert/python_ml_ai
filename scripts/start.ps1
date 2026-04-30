Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$VenvDir = Join-Path $RepoRoot ".venv"
$VenvPython = Join-Path $VenvDir "Scripts\python.exe"
$JupyterExe = Join-Path $VenvDir "Scripts\jupyter.exe"
$NotebookDir = Join-Path $RepoRoot "notebooks"
$IndexNotebooks = @(
    "1_python3.ipynb",
    "2_python3_questions.ipynb",
    "3_python3_answers.ipynb",
    "4_packages.ipynb",
    "5_statics.ipynb",
    "6_machine_learning.ipynb",
    "7_neural_networks.ipynb"
)

if (-not (Test-Path -LiteralPath $JupyterExe)) {
    throw "Missing $JupyterExe. Run .\scripts\setup.ps1 first."
}

New-Item -ItemType Directory -Force -Path $NotebookDir | Out-Null

foreach ($Notebook in $IndexNotebooks) {
    $NotebookPath = Join-Path $NotebookDir $Notebook
    if (-not (Test-Path -LiteralPath $NotebookPath)) {
        throw "Missing $NotebookPath"
    }
}

$PreflightScript = Join-Path ([System.IO.Path]::GetTempPath()) ("python_ml_ai_jupyter_preflight_" + [guid]::NewGuid().ToString("N") + ".py")
$PreflightSource = @'
import importlib
import sys

required = ["jupyter_server", "jupyter_events", "yaml", "overrides", "nbclassic"]

for name in required:
    try:
        importlib.import_module(name)
    except Exception as exc:
        print(f"[start] Missing or broken Python package '{name}': {exc}", file=sys.stderr)
        print(r"[start] Rebuild the environment with .\scripts\setup.ps1.", file=sys.stderr)
        raise SystemExit(1)
'@

Write-Host ""
Write-Host "[start] Running notebook server preflight checks"
Set-Content -LiteralPath $PreflightScript -Value $PreflightSource -Encoding UTF8
try {
    & $VenvPython $PreflightScript
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}
finally {
    Remove-Item -LiteralPath $PreflightScript -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "[start] Opening notebooks from $NotebookDir"
Write-Host "[start] Course entry notebooks: 1_python3.ipynb, 4_packages.ipynb, 5_statics.ipynb, 6_machine_learning.ipynb, 7_neural_networks.ipynb"
Write-Host "[start] Startup may take a moment on first launch. If you press Ctrl-C during import or server startup, Python may show a traceback even when the installation is fine."

Set-Location $NotebookDir
& $JupyterExe nbclassic
