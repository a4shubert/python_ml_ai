Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$RequirementsFile = Join-Path $RepoRoot "requirements-ds-ml.txt"
$PythonVersion = if ($env:PYTHON_VERSION) { $env:PYTHON_VERSION } else { "3.12" }
$UvInstallDir = Join-Path $RepoRoot ".tools\uv"
$UvExe = Join-Path $UvInstallDir "uv.exe"
$VenvDir = Join-Path $RepoRoot ".venv"
$VenvPython = Join-Path $VenvDir "Scripts\python.exe"
$KernelName = "python-course-3.12"
$KernelDisplayName = "Python Course 3.12"

function Write-SetupMessage {
    param([string]$Message)
    Write-Host ""
    Write-Host "[setup] $Message"
}

if (-not (Test-Path -LiteralPath $RequirementsFile)) {
    throw "Missing $RequirementsFile. Run this script from the course repository."
}

if (-not (Test-Path -LiteralPath $UvExe)) {
    Write-SetupMessage "Installing local uv bootstrapper into $UvInstallDir"
    New-Item -ItemType Directory -Force -Path $UvInstallDir | Out-Null
    $env:UV_UNMANAGED_INSTALL = $UvInstallDir
    try {
        Invoke-RestMethod https://astral.sh/uv/install.ps1 | Invoke-Expression
    }
    finally {
        Remove-Item Env:UV_UNMANAGED_INSTALL -ErrorAction SilentlyContinue
    }
}

if (-not (Test-Path -LiteralPath $UvExe)) {
    throw "uv installation did not produce $UvExe"
}

Write-SetupMessage "Ensuring Python $PythonVersion is available"
& $UvExe python install $PythonVersion

if (Test-Path -LiteralPath $VenvPython) {
    Write-SetupMessage "Reusing existing virtual environment at $VenvDir"
}
else {
    Write-SetupMessage "Creating virtual environment at $VenvDir"
    & $UvExe venv --python $PythonVersion $VenvDir
}

Write-SetupMessage "Syncing packages from $RequirementsFile"
& $UvExe pip sync --python $VenvPython $RequirementsFile

Write-SetupMessage "Registering Jupyter kernel $KernelName"
& $VenvPython -m ipykernel install --user --name $KernelName --display-name $KernelDisplayName

Write-Host ""
Write-Host "Environment is ready."
Write-Host ""
Write-Host "Activate it with:"
Write-Host "  .\.venv\Scripts\Activate.ps1"
Write-Host ""
Write-Host "Start the classic notebook UI from this repo with:"
Write-Host "  .\scripts\start.ps1"
Write-Host ""
Write-Host "Primary course entry notebooks:"
Write-Host "  notebooks\1_python3.ipynb"
Write-Host "  notebooks\4_packages.ipynb"
Write-Host "  notebooks\5_statics.ipynb"
Write-Host "  notebooks\6_machine_learning.ipynb"
Write-Host "  notebooks\7_neural_networks.ipynb"
