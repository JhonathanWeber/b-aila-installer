<#
.SYNOPSIS
    B-AILA Uninstaller Script
    Removes Ollama, LLM models, firewall rules, and cleans up the B-AILA environment.

.DESCRIPTION
    This script performs a complete cleanup of the B-AILA ecosystem.
    WARNING: This is a destructive operation.
#>

# --- Configuration ---
$BAILA_PORT_BACKEND = 8990
$BAILA_PORT_DASHBOARD = 8991
$OLLAMA_DIR = "$env:USERPROFILE\.ollama"

# --- Helper Functions ---
function Write-Header($text) {
    Write-Host "`n=== $text ===" -ForegroundColor Cyan
}

function Write-Success($text) {
    Write-Host "[SUCCESS] $text" -ForegroundColor Green
}

function Write-WarningMsg($text) {
    Write-Host "[WARNING] $text" -ForegroundColor Yellow
}

function Write-ErrorMsg($text) {
    Write-Host "[ERROR] $text" -ForegroundColor Red
}

# --- 1. Privilege Escalation ---
function Test-IsAdmin {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdmin)) {
    Write-WarningMsg "Elevating privileges to Admin for uninstallation..."
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# --- 2. Confirmation ---
Write-Header "B-AILA COMPLETE UNINSTALLER"
Write-WarningMsg "This script will remove:"
Write-Host " - Ollama Application"
Write-Host " - ALL Ollama Models (Downloaded LLMs)"
Write-Host " - B-AILA Firewall Rules"
Write-Host " - B-AILA Local Data (Prisma/SQLite)"
Write-Host ""
$confirm = Read-Host "Are you sure you want to proceed? (Y/N)"
if ($confirm -ne "Y") {
    Write-Host "Uninstallation cancelled."
    exit
}

# --- 3. Stop Processes ---
Write-Header "Stopping Processes"

Write-Host "Stopping Ollama..."
$ollamaProc = Get-Process "ollama" -ErrorAction SilentlyContinue
if ($ollamaProc) {
    Stop-Process -Name "ollama" -Force
    Write-Success "Ollama stopped."
}

Write-Host "Stopping Node.js services..."
Write-WarningMsg "Please ensure your Backend (:8990) and Dashboard (:8991) terminal windows are closed."

# --- 4. Remove Software ---
Write-Header "Removing Software & Data"

# Uninstall Ollama via Winget
Write-Host "Uninstalling Ollama via Winget..."
winget uninstall -e --id Ollama.Ollama --accept-source-agreements

# Remove Ollama Models and Config
if (Test-Path $OLLAMA_DIR) {
    Write-Host "Deleting Ollama models and configuration ($OLLAMA_DIR)..."
    Remove-Item -Path $OLLAMA_DIR -Recurse -Force
    Write-Success "Ollama directory removed."
}

# --- 5. Network Cleanup ---
Write-Header "Cleaning Up Network Rules"
$firewallRules = Get-NetFirewallRule -DisplayName "B-AILA*" -ErrorAction SilentlyContinue
if ($firewallRules) {
    Write-Host "Removing Firewall rules for B-AILA..."
    Remove-NetFirewallRule -DisplayName "B-AILA*"
    Write-Success "Firewall rules removed."
}

# --- 6. Local Workspace Cleanup ---
# We don't delete the code directory itself to avoid accidents with user's workspace, 
# but we clean up the generated data.
Write-Header "Cleaning Up Local Workspace Data"
$backendDir = "c:/Users/Jhon/workspace/b-aila/apps/backend"
if (Test-Path "$backendDir/prisma/dev.db") {
    Remove-Item -Path "$backendDir/prisma/dev.db" -Force
    Write-Success "Local database removed."
}

Write-Header "B-AILA Uninstallation Complete!"
Write-Host "Optional: You can now manually delete the folder 'c:/Users/Jhon/workspace/b-aila/' if you wish to remove the source code." -ForegroundColor Cyan
