@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "SETUP_SCRIPT=%SCRIPT_DIR%scripts\setup.ps1"
set "START_SCRIPT=%SCRIPT_DIR%scripts\start.ps1"
set "VENV_PYTHON=%SCRIPT_DIR%.venv\Scripts\python.exe"

if not exist "%SETUP_SCRIPT%" (
  echo.
  echo [run] Missing %SETUP_SCRIPT%
  exit /b 1
)

if not exist "%START_SCRIPT%" (
  echo.
  echo [run] Missing %START_SCRIPT%
  exit /b 1
)

echo.
echo [run] Installing and syncing the course environment
powershell -NoProfile -ExecutionPolicy Bypass -File "%SETUP_SCRIPT%"
if errorlevel 1 exit /b %errorlevel%

if not exist "%VENV_PYTHON%" (
  echo.
  echo [run] Missing %VENV_PYTHON% after setup
  exit /b 1
)

echo.
echo [run] Verifying core notebook packages
"%VENV_PYTHON%" -c "import importlib; modules=['numpy','pandas','scipy','matplotlib','seaborn','pyarrow','notebook','nbclassic']; [print(f'{name} {getattr(importlib.import_module(name), \"__version__\", \"unknown\")}') for name in modules]"
if errorlevel 1 exit /b %errorlevel%

echo.
echo [run] Launching Jupyter Classic in the notebook folder
powershell -NoProfile -ExecutionPolicy Bypass -File "%START_SCRIPT%"
exit /b %errorlevel%
