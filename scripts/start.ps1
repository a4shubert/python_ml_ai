Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$VenvDir = Join-Path $RepoRoot ".venv"
$VenvPython = Join-Path $VenvDir "Scripts\python.exe"
$JupyterExe = Join-Path $VenvDir "Scripts\jupyter.exe"
$NotebookDir = Join-Path $RepoRoot "notebooks"

if (-not (Test-Path -LiteralPath $JupyterExe)) {
    throw "Missing $JupyterExe. Run .\scripts\setup.ps1 first."
}

New-Item -ItemType Directory -Force -Path $NotebookDir | Out-Null

Write-Host ""
Write-Host "[start] Running notebook server preflight checks"
& $VenvPython -c "import importlib, sys; required = ['jupyter_server', 'jupyter_events', 'yaml', 'overrides', 'nbclassic'];`nfor name in required:`n    try:`n        importlib.import_module(name)`n    except Exception as exc:`n        print(f""[start] Missing or broken Python package '{name}': {exc}"", file=sys.stderr)`n        print(""[start] Rebuild the environment with .\scripts\setup.ps1."", file=sys.stderr)`n        raise SystemExit(1)"
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

Write-Host ""
Write-Host "[start] Opening notebooks from $NotebookDir"
Write-Host "[start] Startup may take a moment on first launch. If you press Ctrl-C during import or server startup, Python may show a traceback even when the installation is fine."

Set-Location $NotebookDir
& $JupyterExe nbclassic
