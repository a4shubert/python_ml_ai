Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$VenvDir = Join-Path $RepoRoot ".venv"
$JupyterExe = Join-Path $VenvDir "Scripts\jupyter.exe"
$NotebookDir = Join-Path $RepoRoot "notebooks"

if (-not (Test-Path -LiteralPath $JupyterExe)) {
    throw "Missing $JupyterExe. Run .\scripts\setup.ps1 first."
}

New-Item -ItemType Directory -Force -Path $NotebookDir | Out-Null

Set-Location $NotebookDir
& $JupyterExe nbclassic
