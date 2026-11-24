@echo off
rem Builds DeConverter.exe (PyInstaller), the portable ZIP and, if Inno Setup is installed, DeConverter_Setup.exe.
setlocal
cd /d "%~dp0"
if not exist ".venv\Scripts\python.exe" call INSTALL.bat
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\build_windows.ps1 || ( echo Build failed. & pause & exit /b 1 )
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\create_installer.ps1
echo.
echo Output is in the "dist" folder.
pause
