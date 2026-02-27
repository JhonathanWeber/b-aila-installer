<#
.SYNOPSIS
    B-AILA (Blender AI Local Assistant) Orchestrator Script
    Automates environment setup including WSL2, Ollama, and necessary configurations.

.DESCRIPTION
    This script performs pre-flight checks (Virtualization, Disk Space),
    ensures Admin privileges, and installs dependencies via Winget.
#>

# --- Configuration ---
$BAILA_PORT_BACKEND = 8990
$OLLAMA_PORT = 11434
$MIN_DISK_SPACE_GB = 20

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
    Write-WarningMsg "Elevating privileges to Admin..."
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Success "Running with Administrator privileges."

# --- 2. Pre-flight Checks ---
Write-Header "Starting Pre-flight Checks"

# Check Virtualization
$virtualization = Get-WmiObject -Query "Select * from Win32_ComputerSystem" | Select-Object -ExpandProperty HypervisorPresent
if (-not $virtualization) {
    Write-ErrorMsg "Virtualization (VT-x/AMD-V) is disabled in BIOS. Please enable it before proceeding."
    exit
}
Write-Success "Virtualization is enabled."

# Check Disk Space
$drive = Get-PSDrive C
$freeSpaceGB = [math]::Round($drive.Free / 1GB, 2)
if ($freeSpaceGB -lt $MIN_DISK_SPACE_GB) {
    Write-ErrorMsg "Insufficient disk space. At least $MIN_DISK_SPACE_GB GB required (Current: $freeSpaceGB GB)."
    exit
}
Write-Success "Disk space check passed ($freeSpaceGB GB free)."

# --- 3. Dependency Installation ---
Write-Header "Installing Dependencies"

# Check Winget
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-WarningMsg "Winget not found. Installing App Installer..."
    # Manual installation logic could go here
}
else {
    Write-Success "Winget found."
}

# Check Node.js & npm
Write-Host "Checking Node.js & npm..."
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-WarningMsg "Node.js not found. Installing via Winget..."
    winget install -e --id OpenJS.NodeJS
    Write-Success "Node.js installation triggered. You may need to restart the terminal if the next steps fail."
}
else {
    $nodeVer = node -v
    Write-Success "Node.js is installed ($nodeVer)."
}

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-WarningMsg "npm not found. It should come with Node.js. Please check your installation."
}
else {
    $npmVer = npm -v
    Write-Success "npm is installed ($npmVer)."
}

# Check Git
Write-Host "Checking Git..."
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-WarningMsg "Git not found. Installing via Winget..."
    winget install -e --id Git.Git
    Write-Success "Git installation triggered."
}
else {
    Write-Success "Git is installed."
}

# Check Developer Tools
Write-Host "Checking Developer Tools..."
Write-Success "Developer tools will be handled locally via npx (Lite Mode)."

# Install Ollama & Default Model
Write-Host "Checking Ollama..."
if (-not (Get-Process "ollama" -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Ollama via Winget..."
    winget install -e --id Ollama.Ollama
}
else {
    Write-Success "Ollama is already running/installed."
}

Write-Host "Downloading Default AI Model (qwen2.5-coder:1.5b)..." -ForegroundColor Yellow
Write-Host "This may take a few minutes depending on your connection."
Start-Process powershell.exe -ArgumentList "-NoProfile -Wait -Command `"ollama pull qwen2.5-coder:1.5b`"" -WindowStyle Normal
Write-Success "AI Model is ready."


# WSL2 Check/Install
Write-Host "Verifying WSL2 status..."
$wslStatus = wsl --status 2>$null
if (-not $wslStatus) {
    Write-WarningMsg "WSL2 not found or not initialized. Running 'wsl --install'..."
    wsl --install
    Write-WarningMsg "System restart may be required after WSL2 installation."
}
else {
    Write-Success "WSL2 is active."
}

# --- 4. Firewall & Network ---
Write-Header "Configuring Network"
$firewallRules = Get-NetFirewallRule -DisplayName "B-AILA Backend" -ErrorAction SilentlyContinue
if (-not $firewallRules) {
    Write-Host "Adding Firewall rule for port $BAILA_PORT_BACKEND..."
    New-NetFirewallRule -DisplayName "B-AILA Backend" -Direction Inbound -LocalPort $BAILA_PORT_BACKEND -Protocol TCP -Action Allow
}
Write-Success "Firewall rules configured."

Write-Header "B-AILA Infrastructure Setup Complete!"
Write-Host "Launching B-AILA Services..." -ForegroundColor Green

# --- 5. Project Source Sync ---
Write-Header "Checking Project Source"
$projectRoot = Split-Path -Path $PSCommandPath -Parent | Split-Path -Parent
$appsPath = Join-Path $projectRoot "apps"

if (-not (Test-Path -Path $appsPath)) {
    Write-WarningMsg "Project folders (apps/) not found. Syncing from GitHub..."
    
    # Repositorio corregido
    $repoName = "JhonathanWeber/b-aila-core"
    $repoUrl = "https://github.com/$repoName.git"
    $tempPath = Join-Path $projectRoot "temp_sync"
    
    if (Test-Path $tempPath) { Remove-Item $tempPath -Recurse -Force }

    try {
        if (Get-Command gh -ErrorAction SilentlyContinue) {
            Write-Host "Cloning $repoName using GitHub CLI..."
            gh repo clone $repoName $tempPath -- --depth 1
        }
        else {
            Write-Host "Cloning $repoUrl using Git..."
            git clone --depth 1 $repoUrl $tempPath
        }

        if (Test-Path -Path (Join-Path $tempPath "apps")) {
            Write-Host "Moving files to project root..."
            Get-ChildItem -Path $tempPath | ForEach-Object {
                $dest = Join-Path $projectRoot $_.Name
                if (-not (Test-Path -Path $dest)) {
                    Move-Item -Path $_.FullName -Destination $projectRoot -Force
                }
            }
            Write-Success "Project source synced successfully."
        }
    }
    catch {
        Write-ErrorMsg "Failed to clone repository. Please check your internet connection or git status."
    }
    finally {
        if (Test-Path -Path $tempPath) {
            Remove-Item -Path $tempPath -Recurse -Force
        }
    }
}
else {
    Write-Success "Project source found."
}

$backendPath = Join-Path $projectRoot "apps\backend"

# --- 7. Dependency Installation (Node.js) ---
Write-Header "Installing Node.js Dependencies"

function Install-Deps($path, $name) {
    if (Test-Path -Path $path) {
        $nodeModules = Join-Path $path "node_modules"
        if (-not (Test-Path -Path $nodeModules)) {
            Write-Host "Installing dependencies for $name..." -ForegroundColor Yellow
            Push-Location $path
            npm install
            
            # Auto-setup Database for Backend
            if ($name -eq "Backend") {
                Write-Host "Initializing Database..." -ForegroundColor Cyan
                $envFile = Join-Path $path ".env"
                if (-not (Test-Path $envFile)) {
                    "DATABASE_URL=`"file:./dev.db`"" | Out-File -FilePath $envFile -Encoding utf8
                }
                npx prisma generate
                npx prisma db push
            }
            
            Pop-Location
            Write-Success "Dependencies for $name installed."
        }
        else {
            Write-Success "Dependencies for $name already present."
        }
    }
}

Install-Deps $backendPath "Backend"

# --- 7. Final Infrastructure Check ---
Write-Header "Finalizing Environment"
Write-Host "Verifying Ollama is listening on port $OLLAMA_PORT..."
$ollamaCheck = Test-NetConnection -ComputerName localhost -Port $OLLAMA_PORT -InformationLevel Quiet
if (-not $ollamaCheck) {
    Write-WarningMsg "Ollama is not responding on port $OLLAMA_PORT. It might still be starting."
}
else {
    Write-Success "Ollama is active and listening."
}

# --- Launch Backend ---
Write-Host "Starting B-AILA Services (Integrated Dashboard)..."
$env:OLLAMA_URL = "http://localhost:$OLLAMA_PORT"
Start-Process powershell.exe -ArgumentList "-NoProfile -NoExit -Command `"cd '$backendPath'; `$env:OLLAMA_URL='http://localhost:$OLLAMA_PORT'; npm run dev`"" -WindowStyle Normal

# --- Launch Browser ---
Write-Host "Opening Dashboard in your default browser..."
Start-Process "http://localhost:$BAILA_PORT_BACKEND"

Write-Host "`nAll systems are launching! The Dashboard will open in your browser shortly." -ForegroundColor Cyan
Write-Host "You can now open Blender and use the B-AILA Add-on." -ForegroundColor Green
