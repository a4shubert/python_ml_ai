@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "SETUP_SCRIPT=%SCRIPT_DIR%scripts\setup.ps1"
set "START_SCRIPT=%SCRIPT_DIR%scripts\start.ps1"
set "VENV_PYTHON=%SCRIPT_DIR%.venv\Scripts\python.exe"
set "POWERSHELL_EXE=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"

if exist "%POWERSHELL_EXE%" goto have_powershell
set "POWERSHELL_EXE=powershell"

:have_powershell
if exist "%SETUP_SCRIPT%" goto have_setup
echo.
echo [run] Missing %SETUP_SCRIPT%
exit /b 1

:have_setup
if exist "%START_SCRIPT%" goto have_start
echo.
echo [run] Missing %START_SCRIPT%
exit /b 1

:have_start
echo.
echo [run] Installing and syncing the course environment
"%POWERSHELL_EXE%" -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy -Scope Process Bypass -Force; Get-Item -LiteralPath '%SETUP_SCRIPT%','%START_SCRIPT%' | Unblock-File -ErrorAction SilentlyContinue; & '%SETUP_SCRIPT%'"
if errorlevel 1 exit /b %errorlevel%

if exist "%VENV_PYTHON%" goto have_venv_python
echo.
echo [run] Missing %VENV_PYTHON% after setup
exit /b 1

:have_venv_python
echo.
echo [run] Verifying core notebook packages
"%VENV_PYTHON%" -c "import importlib; modules=['numpy','pandas','scipy','matplotlib','seaborn','pyarrow','notebook','nbclassic']; [print(f'{name} {getattr(importlib.import_module(name), \"__version__\", \"unknown\")}') for name in modules]"
if errorlevel 1 exit /b %errorlevel%

echo.
echo [run] Launching Jupyter Classic in the notebooks folder
echo [run] Course entry notebooks: 1_python3.ipynb, 4_packages.ipynb, 5_statics.ipynb, 6_machine_learning.ipynb, 7_neural_networks.ipynb
"%POWERSHELL_EXE%" -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy -Scope Process Bypass -Force; Get-Item -LiteralPath '%SETUP_SCRIPT%','%START_SCRIPT%' | Unblock-File -ErrorAction SilentlyContinue; & '%START_SCRIPT%'"
exit /b %errorlevel%
