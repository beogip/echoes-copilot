# 🧠🤖 Echos + Copilot Template Installer (PowerShell)
# Advanced installer script with backup, rollback, and Windows support
# This script provides complete cross-platform installation capabilities
# Supports both individual instruction files and comprehensive installation modes
# Includes robust error handling, backup/restore functionality, and logging

# Define command line parameters with detailed descriptions
param(
    [string]$Mode = "instructions",  # Installation mode: "instructions" or "comprehensive"
    [switch]$Force,                  # Force installation, overwrite existing files
    [switch]$Verbose,                # Enable detailed logging and output
    [switch]$Rollback,               # Rollback to previous installation using backup
    [switch]$Help                    # Display help information and usage examples
)

# Script configuration and global constants
# Version information for tracking and compatibility
$Script:VERSION = "1.0.0"
# GitHub API endpoint for downloading files from the repository
$Script:GITHUB_REPO = "https://raw.githubusercontent.com/beogip/echos-copilot/main"
# Backup directory with timestamp for version control
$Script:BACKUP_DIR = ".github\echos-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
# Target installation directory (standard GitHub directory)
$Script:TARGET_DIR = ".github"
# Log file location in system temporary directory
$Script:LOG_FILE = "$env:TEMP\echos-copilot-install.log"

# Global state tracking variables
# Track whether backup is available for rollback operations
$Script:ROLLBACK_AVAILABLE = $false

#region Helper Functions
# Collection of utility functions for logging, file operations, and error handling

# Write timestamped log entries to file and optionally to console
function Write-Log {
    param([string]$Message)
    # Create timestamp for each log entry
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    # Write to log file with error handling
    "$timestamp - $Message" | Add-Content -Path $Script:LOG_FILE
    # Display in console if verbose mode is enabled
    if ($Verbose) {
        Write-Host "[LOG] $Message" -ForegroundColor Blue
    }
}

# Display success messages in console and log
function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
    Write-Log "SUCCESS: $Message"
}

# Display error messages in console and log
function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
    Write-Log "ERROR: $Message"
}

# Display warning messages in console and log
function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
    Write-Log "WARNING: $Message"
}

# Display informational messages in console and log
function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Cyan
    Write-Log "INFO: $Message"
}

# Show the initial banner with script information
function Show-Banner {
    Write-Host ""
    Write-Host "🧠🤖 " -NoNewline -ForegroundColor Blue
    Write-Host "Echos + Copilot Template Installer" -ForegroundColor White
    Write-Host "═══════════════════════════════════════════" -ForegroundColor Gray
    Write-Host "Version: $Script:VERSION" -ForegroundColor Gray
    Write-Host "Mode: $Mode" -ForegroundColor Gray
    Write-Host ""
}

# Display help information and usage examples
function Show-Help {
    @"
🧠🤖 Echos + Copilot Template Installer

USAGE:
    .\install.ps1 [OPTIONS]

OPTIONS:
    -Mode <mode>        Installation mode (default: instructions)
                        • instructions - Install individual .instructions.md files
                        • comprehensive - Install single copilot-instructions.md

    -Force              Force installation, overwrite existing files
    -Verbose            Enable verbose logging output
    -Rollback           Rollback previous installation
    -Help               Show this help message

EXAMPLES:
    .\install.ps1
    .\install.ps1 -Mode comprehensive -Force
    .\install.ps1 -Verbose
    .\install.ps1 -Rollback

For more information: https://github.com/beogip/echos-copilot
"@
}

# Check system prerequisites before installation
function Test-Prerequisites {
    Write-Info "Checking system prerequisites..."
    
    # Check PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        Write-Error "PowerShell 5.0 or higher required. Current version: $($PSVersionTable.PSVersion)"
        return $false
    }
    
    # Check execution policy
    $executionPolicy = Get-ExecutionPolicy
    if ($executionPolicy -eq "Restricted") {
        Write-Warning "PowerShell execution policy is Restricted"
        Write-Info "Run: Set-ExecutionPolicy RemoteSigned -Scope CurrentUser"
        return $false
    }
    
    # Check internet connectivity
    try {
        $null = Invoke-WebRequest -Uri "https://api.github.com" -Method Head -TimeoutSec 10
    }
    catch {
        Write-Error "No internet connection available"
        return $false
    }
    
    # Check if we're in a valid project directory
    if (-not (Test-Path ".git") -and -not (Test-Path "package.json") -and -not (Test-Path "*.sln")) {
        Write-Warning "Not detected as a project directory (no .git, package.json, or .sln)"
        if (-not $Force) {
            $response = Read-Host "Continue anyway? [y/N]"
            if ($response -notmatch '^[Yy]') {
                Write-Info "Installation cancelled"
                return $false
            }
        }
    }
    
    Write-Success "Prerequisites check passed"
    return $true
}

# Backup existing files before installation
function Backup-ExistingFiles {
    Write-Info "Creating backup of existing files..."
    
    if (-not (Test-Path $Script:TARGET_DIR)) {
        Write-Info "No existing .github directory found"
        return $true
    }
    
    try {
        # Create backup directory
        New-Item -ItemType Directory -Path $Script:BACKUP_DIR -Force | Out-Null
        
        # Copy existing files
        $filesCopied = 0
        
        if (Test-Path "$Script:TARGET_DIR\copilot-instructions.md") {
            Copy-Item "$Script:TARGET_DIR\copilot-instructions.md" "$Script:BACKUP_DIR\" -Force
            $filesCopied++
        }
        
        if (Test-Path "$Script:TARGET_DIR\instructions") {
            Copy-Item "$Script:TARGET_DIR\instructions" "$Script:BACKUP_DIR\instructions" -Recurse -Force
            $instructionFiles = (Get-ChildItem "$Script:TARGET_DIR\instructions" -Filter "*.instructions.md").Count
            $filesCopied += $instructionFiles
        }
        
        if ($filesCopied -gt 0) {
            Write-Success "Backed up $filesCopied file(s) to $Script:BACKUP_DIR"
            $Script:ROLLBACK_AVAILABLE = $true
        } else {
            Write-Info "No existing files to backup"
            Remove-Item $Script:BACKUP_DIR -Force -ErrorAction SilentlyContinue
        }
        
        return $true
    }
    catch {
        Write-Error "Failed to create backup: $($_.Exception.Message)"
        return $false
    }
}

# Download files from GitHub repository
function Get-FileFromGitHub {
    param(
        [string]$FilePath,
        [string]$OutputPath
    )
    
    try {
        $url = "$Script:GITHUB_REPO/$FilePath"
        Write-Log "Downloading: $url"
        
        $response = Invoke-RestMethod -Uri $url -Headers @{ 'User-Agent' = 'EchosCopilotInstaller/1.0' }
        
        if ($response.type -eq "file") {
            $content = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($response.content))
            
            # Ensure directory exists
            $directory = Split-Path $OutputPath -Parent
            if ($directory -and -not (Test-Path $directory)) {
                New-Item -ItemType Directory -Path $directory -Force | Out-Null
            }
            
            Set-Content -Path $OutputPath -Value $content -Encoding UTF8
            Write-Log "Downloaded: $FilePath -> $OutputPath"
            return $true
        }
        else {
            Write-Error "File not found: $FilePath"
            return $false
        }
    }
    catch {
        Write-Error "Failed to download $FilePath`: $($_.Exception.Message)"
        return $false
    }
}

# Install individual instruction files in instructions mode
function Install-InstructionsMode {
    Write-Info "Installing individual instruction files..."
    
    # Create instructions directory
    $instructionsDir = "$Script:TARGET_DIR\instructions"
    if (-not (Test-Path $instructionsDir)) {
        New-Item -ItemType Directory -Path $instructionsDir -Force | Out-Null
    }
    
    # List of instruction files to download
    $instructionFiles = @(
        "diagnostic.instructions.md",
        "planning.instructions.md",
        "evaluation.instructions.md",
        "optimization.instructions.md",
        "coherence.instructions.md",
        "prioritization.instructions.md"
    )
    
    $successCount = 0
    foreach ($file in $instructionFiles) {
        $sourcePath = ".github/prompts/$file"
        $targetPath = "$instructionsDir\$file"
        
        if (Get-FileFromGitHub -FilePath $sourcePath -OutputPath $targetPath) {
            $successCount++
        }
    }
    
    if ($successCount -eq $instructionFiles.Count) {
        Write-Success "Successfully installed $successCount instruction files"
        return $true
    }
    else {
        Write-Error "Only installed $successCount out of $($instructionFiles.Count) files"
        return $false
    }
}

# Install comprehensive copilot-instructions.md file
function Install-ComprehensiveMode {
    Write-Info "Installing comprehensive copilot-instructions.md file..."
    
    $sourcePath = ".github/copilot-instructions.md"
    $targetPath = "$Script:TARGET_DIR\copilot-instructions.md"
    
    if (Get-FileFromGitHub -FilePath $sourcePath -OutputPath $targetPath) {
        Write-Success "Successfully installed copilot-instructions.md"
        return $true
    }
    else {
        Write-Error "Failed to install copilot-instructions.md"
        return $false
    }
}

# Test and validate installation
function Test-Installation {
    Write-Info "Validating installation..."
    
    $valid = $true
    
    if ($Mode -eq "instructions") {
        $instructionsDir = "$Script:TARGET_DIR\instructions"
        if (-not (Test-Path $instructionsDir)) {
            Write-Error "Instructions directory not found"
            $valid = $false
        }
        else {
            $instructionFiles = Get-ChildItem $instructionsDir -Filter "*.instructions.md"
            if ($instructionFiles.Count -lt 6) {
                Write-Error "Missing instruction files (found $($instructionFiles.Count), expected 6)"
                $valid = $false
            }
        }
    }
    elseif ($Mode -eq "comprehensive") {
        $copilotFile = "$Script:TARGET_DIR\copilot-instructions.md"
        if (-not (Test-Path $copilotFile)) {
            Write-Error "copilot-instructions.md not found"
            $valid = $false
        }
        else {
            $content = Get-Content $copilotFile -Raw
            if ($content.Length -lt 1000) {
                Write-Error "copilot-instructions.md appears to be incomplete"
                $valid = $false
            }
        }
    }
    
    if ($valid) {
        Write-Success "Installation validation passed"
    }
    
    return $valid
}

# Rollback to previous installation using backup
function Invoke-Rollback {
    if (-not $Script:ROLLBACK_AVAILABLE) {
        Write-Error "No rollback available"
        return $false
    }
    
    Write-Info "Rolling back installation..."
    
    try {
        # Find the most recent backup
        $backupDirs = Get-ChildItem ".github" -Directory -Filter "echos-backup-*" | Sort-Object Name -Descending
        
        if ($backupDirs.Count -eq 0) {
            Write-Error "No backup directories found"
            return $false
        }
        
        $latestBackup = $backupDirs[0].FullName
        Write-Info "Restoring from: $latestBackup"
        
        # Restore files
        if (Test-Path "$latestBackup\copilot-instructions.md") {
            Copy-Item "$latestBackup\copilot-instructions.md" "$Script:TARGET_DIR\" -Force
        }
        
        if (Test-Path "$latestBackup\instructions") {
            if (Test-Path "$Script:TARGET_DIR\instructions") {
                Remove-Item "$Script:TARGET_DIR\instructions" -Recurse -Force
            }
            Copy-Item "$latestBackup\instructions" "$Script:TARGET_DIR\instructions" -Recurse -Force
        }
        
        Write-Success "Rollback completed successfully"
        return $true
    }
    catch {
        Write-Error "Rollback failed: $($_.Exception.Message)"
        return $false
    }
}

# Show post-installation information and usage instructions
function Show-PostInstallInfo {
    Write-Host ""
    Write-Success "🎉 Installation completed successfully!"
    Write-Host ""
    
    if ($Mode -eq "instructions") {
        Write-Host "📁 Individual instruction files installed in: " -NoNewline
        Write-Host ".github\instructions\" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "GitHub Copilot will automatically load the instruction files" -ForegroundColor Cyan
        Write-Host "Available echos: diagnostic, planning, evaluation, optimization, coherence, prioritization" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Additional option:" -ForegroundColor Cyan
        Write-Host "Manual setup available via copilot-instructions.md" -ForegroundColor Gray
    }
    else {
        Write-Host "📄 Comprehensive instructions installed: " -NoNewline
        Write-Host ".github\copilot-instructions.md" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "This file will be automatically loaded by GitHub Copilot" -ForegroundColor Cyan
    }
    
    Write-Host ""
    Write-Host "🔗 Learn more: " -NoNewline
    Write-Host "https://github.com/beogip/echos-copilot" -ForegroundColor Blue
    
    if ($Script:ROLLBACK_AVAILABLE) {
        Write-Host ""
        Write-Host "💾 Backup created. To rollback: " -NoNewline
        Write-Host ".\install.ps1 -Rollback" -ForegroundColor Yellow
    }
}

#endregion

#region Main Execution

# Main function to orchestrate the installation process
function Main {
    # Handle help
    if ($Help) {
        Show-Help
        exit 0
    }
    
    # Handle rollback
    if ($Rollback) {
        Show-Banner
        if (Invoke-Rollback) {
            exit 0
        } else {
            exit 1
        }
    }
    
    # Validate mode
    if ($Mode -notin @("instructions", "comprehensive")) {
        Write-Error "Invalid mode: $Mode. Use 'instructions' or 'comprehensive'"
        exit 1
    }
    
    Show-Banner
    
    # Initialize log
    "=== Echos + Copilot Installer Log ===" | Set-Content -Path $Script:LOG_FILE
    Write-Log "Installation started with mode: $Mode"
    
    try {
        # Run installation steps
        if (-not (Test-Prerequisites)) { exit 1 }
        
        # Create target directory
        if (-not (Test-Path $Script:TARGET_DIR)) {
            New-Item -ItemType Directory -Path $Script:TARGET_DIR -Force | Out-Null
            Write-Info "Created .github directory"
        }
        
        if (-not (Backup-ExistingFiles)) { exit 1 }
        
        # Install based on mode
        $installSuccess = $false
        if ($Mode -eq "instructions") {
            # Install individual instruction files
            $installSuccess = Install-InstructionsMode
            if ($installSuccess) {
                # Also install comprehensive file for users who prefer manual configuration
                Write-InfoMessage "Installing comprehensive file as additional option..."
                $comprehensiveSuccess = Install-ComprehensiveMode
                if (-not $comprehensiveSuccess) {
                    Write-WarningMessage "Failed to install comprehensive file, but individual files were successful"
                } else {
                    Write-SuccessMessage "Both individual and comprehensive files installed"
                }
            }
        }
        elseif ($Mode -eq "comprehensive") {
            $installSuccess = Install-ComprehensiveMode
        }
        
        if (-not $installSuccess) { 
            Write-Error "Installation failed"
            exit 1 
        }
        
        if (-not (Test-Installation)) { 
            Write-Error "Installation validation failed"
            exit 1 
        }
        
        Show-PostInstallInfo
        Write-Log "Installation completed successfully"
        
    }
    catch {
        Write-Error "Unexpected error: $($_.Exception.Message)"
        Write-Log "FATAL ERROR: $($_.Exception.Message)"
        exit 1
    }
}

# Run main function
Main

#endregion
