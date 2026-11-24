@echo off
rem DeConverter one-click setup: creates a private Python environment and installs everything needed.
setlocal enabledelayedexpansion
cd /d "%~dp0"
title DeConverter setup
echo.
echo  DeConverter setup
echo  -----------------

set "PY="
where py >nul 2>nul && (py -3.12 -c "import sys" >nul 2>nul && set "PY=py -3.12")
if not defined PY where python >nul 2>nul && (python -c "import sys;sys.exit(0 if sys.version_info>=(3,12) else 1)" >nul 2>nul && set "PY=python")

if not defined PY (
  echo  Python 3.12+ was not found.
  where winget >nul 2>nul
  if errorlevel 1 (
    echo  Please install Python 3.12 from https://www.python.org/downloads/ ^(tick "Add python.exe to PATH"^) and run INSTALL.bat again.
    pause & exit /b 1
  )
  choice /m " Install Python 3.12 now using winget"
  if errorlevel 2 ( echo  Cancelled. & pause & exit /b 1 )
  winget install -e --id Python.Python.3.12 --accept-package-agreements --accept-source-agreements
  echo.
  echo  Python installed. Please CLOSE this window and double-click INSTALL.bat again.
  pause & exit /b 0
)

echo  Using: %PY%
if not exist ".venv\Scripts\python.exe" (
  %PY% -m venv .venv || ( echo  Could not create the virtual environment. & pause & exit /b 1 )
)
call ".venv\Scripts\python.exe" -m pip install --upgrade pip >nul
echo  Installing Python packages ^(this can take a few minutes^)...
call ".venv\Scripts\python.exe" -m pip install -r requirements.txt || ( echo  Package installation failed. & pause & exit /b 1 )

echo.
echo  Optional conversion engines ^(Office documents, audio/video, OCR, Markdown^)
where winget >nul 2>nul
if errorlevel 1 goto :done
choice /m " Install LibreOffice, FFmpeg, Pandoc and Tesseract with winget"
if errorlevel 2 goto :done
winget install -e --id TheDocumentFoundation.LibreOffice --accept-package-agreements --accept-source-agreements
winget install -e --id Gyan.FFmpeg --accept-package-agreements --accept-source-agreements
winget install -e --id JohnMacFarlane.Pandoc --accept-package-agreements --accept-source-agreements
winget install -e --id UB-Mannheim.TesseractOCR --accept-package-agreements --accept-source-agreements

:done
echo.
echo  Checking installation...
".venv\Scripts\python.exe" -m app.main --check
echo.
echo  Done. Double-click START.bat to launch DeConverter.
pause
exit /b 0
