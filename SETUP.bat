@echo off
TITLE B-AILA Setup Launcher
echo ==========================================
echo    B-AILA - AI Local Assistant for Blender
echo ==========================================
echo.
echo Executing installation script...
echo.

:: Run PowerShell script with Bypass policy
powershell.exe -ExecutionPolicy Bypass -File "%~dp0scripts\install.ps1"

echo.
echo ==========================================
echo Setup complete or terminated.
echo ==========================================
pause
