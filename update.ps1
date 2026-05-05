#
# OpenCode Global Config Installer/Updater
# Usage: .\update.ps1 [-DryRun] [-Force] [-Restore <backup-name>|latest]
#

param(
    [switch]$DryRun,
    [switch]$Force,
    [string]$Restore
)

$ErrorActionPreference = "Stop"

# Build the hook command substitutions for Windows.
# Uses powershell.exe with single-quoted Windows paths so bash (WSL) passes them through literally.
function Get-WindowsHookSubstitutions {
    param([string]$HooksDir)
    return @{
        '$HOOK_BEFORE_BASH' = "powershell.exe -NonInteractive -File '$HooksDir\before-bash.ps1'"
        '$HOOK_BEFORE_FILE' = "powershell.exe -NonInteractive -File '$HooksDir\before-file.ps1'"
    }
}

# Detect platform and set destination
function Get-PlatformDestination {
    if ($env:OS -eq "Windows_NT") {
        return "C:\Users\santi\.config\opencode", "C:\Users\santi\.config\opencode-backups"
    } else {
        return "$HOME/.config/opencode", "$HOME/.config/opencode-backups"
    }
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigSource = "$ScriptDir\config"

$DestDir, $BackupDir = Get-PlatformDestination

# Check if running in PowerShell
$IsPowerShell = $PSVersionTable.PSVersion.Major -ge 6 -or -not ($BASH_VERSION)

Write-Host "OpenCode Global Config Installer" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Source:      $ConfigSource"
Write-Host "Destination: $DestDir"
Write-Host ""

if ($DryRun) {
    Write-Host "[DRY RUN] No changes will be made" -ForegroundColor Yellow
    Write-Host ""
}

# Handle restore mode
if ($Restore) {
    $RestorePath = $null

    if ($Restore -eq "latest") {
        $latest = Get-ChildItem -Path $BackupDir -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1
        if ($latest) {
            $RestorePath = $latest.FullName
        }
    } else {
        $candidate = "$BackupDir\$Restore"
        if (Test-Path $candidate) {
            $RestorePath = $candidate
        }
    }

    if (-not $RestorePath) {
        Write-Host "Error: Backup not found: $Restore" -ForegroundColor Red
        exit 1
    }

    Write-Host "Restoring from backup: $RestorePath" -ForegroundColor Yellow

    if (-not $DryRun) {
        # Remove existing and restore
        if (Test-Path $DestDir) {
            Remove-Item -Path $DestDir -Recurse -Force
        }
        Copy-Item -Path $RestorePath -Destination $DestDir -Recurse
        Write-Host "Restore complete!" -ForegroundColor Green
    }
    exit 0
}

# Helper function to check if file is safe to copy
function Test-SafeToCopy {
    param([string]$Path)
    $name = Split-Path -Leaf $Path

    # Check filename patterns
    if ($name -match '^\.env$' -or $name -match '^\.env\.' -or $name -match '\.local\.json$' -or $name -eq 'secrets' -or $name -eq 'credentials' -or $name -match '\.pem$' -or $name -match '\.key$') {
        return $false
    }

    # Check path patterns
    if ($Path -match 'secrets' -or $Path -match 'credentials' -or $Path -match '\.pem$' -or $Path -match '\.key$') {
        return $false
    }

    return $true
}

# Create backup
function New-Backup {
    if (Test-Path $DestDir) {
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $backupPath = "$BackupDir\$timestamp"

        Write-Host "Creating backup at $backupPath..." -ForegroundColor Yellow
        New-Item -Path $BackupDir -ItemType Directory -Force | Out-Null
        Copy-Item -Path $DestDir -Destination $backupPath -Recurse -Force
        Write-Host "Backup created: $backupPath" -ForegroundColor Green
    } else {
        Write-Host "No existing config to backup (destination does not exist)" -ForegroundColor Yellow
    }
}

# Copy a single file, expanding $OPENCODE_CONFIG_DIR in .md files
function Copy-FileWithSubstitution {
    param([string]$Src, [string]$Dst)
    if ($Src -match 'opencode\.json$' -and $env:OS -eq 'Windows_NT') {
        $content = Get-Content -Path $Src -Raw -Encoding UTF8
        $json = $content | ConvertFrom-Json
        $json.plugin = @($json.plugin | Where-Object { $_ -notmatch 'warcraft' })
        Set-Content -Path $Dst -Value ($json | ConvertTo-Json -Depth 10) -Encoding UTF8 -NoNewline
    } elseif ($Src -match '\.md$') {
        $content = Get-Content -Path $Src -Raw -Encoding UTF8
        $hooksDir = Join-Path $DestDir 'hooks'
        $subs = Get-WindowsHookSubstitutions -HooksDir $hooksDir
        foreach ($key in $subs.Keys) {
            $content = $content -replace [regex]::Escape($key), $subs[$key]
        }
        # Fallback: also expand $OPENCODE_CONFIG_DIR for any other .md files
        $content = $content -replace [regex]::Escape('$OPENCODE_CONFIG_DIR'), $DestDir
        Set-Content -Path $Dst -Value $content -Encoding UTF8 -NoNewline
    } else {
        Copy-Item -Path $Src -Destination $Dst -Force
    }
}

# Recursively copy a directory, applying substitution to .md files
function Copy-DirWithSubstitution {
    param([string]$Src, [string]$Dst)
    New-Item -Path $Dst -ItemType Directory -Force | Out-Null
    foreach ($child in Get-ChildItem -Path $Src -Force) {
        $destChild = Join-Path $Dst $child.Name
        if ($child.PSIsContainer) {
            Copy-DirWithSubstitution -Src $child.FullName -Dst $destChild
        } else {
            Copy-FileWithSubstitution -Src $child.FullName -Dst $destChild
        }
    }
}

# Copy files
function Copy-Files {
    $copied = 0
    $skipped = 0

    # Create destination if needed
    if (-not (Test-Path $DestDir)) {
        New-Item -Path $DestDir -ItemType Directory -Force | Out-Null
    }

    # Copy each item from config/
    $items = Get-ChildItem -Path $ConfigSource -Force -ErrorAction SilentlyContinue
    foreach ($item in $items) {
        if (-not (Test-SafeToCopy $item.FullName)) {
            Write-Host "Skipping (unsafe): $($item.Name)" -ForegroundColor DarkGray
            $skipped++
            continue
        }

        $destItem = Join-Path $DestDir $item.Name

        if (Test-Path $destItem) {
            if ($Force) {
                Write-Host "Overwriting: $($item.Name)" -ForegroundColor Yellow
                Remove-Item -Path $destItem -Recurse -Force
                if ($item.PSIsContainer) {
                    Copy-DirWithSubstitution -Src $item.FullName -Dst $destItem
                } else {
                    Copy-FileWithSubstitution -Src $item.FullName -Dst $destItem
                }
                $copied++
            } else {
                Write-Host "Skipping (exists): $($item.Name)" -ForegroundColor DarkGray
                $skipped++
            }
        } else {
            Write-Host "Creating: $($item.Name)" -ForegroundColor Green
            if ($item.PSIsContainer) {
                Copy-DirWithSubstitution -Src $item.FullName -Dst $destItem
            } else {
                Copy-FileWithSubstitution -Src $item.FullName -Dst $destItem
            }
            $copied++
        }
    }

    Write-Host ""
    Write-Host "Summary:" -ForegroundColor Cyan
    Write-Host "  Copied: $copied"
    Write-Host "  Skipped: $skipped"
}

# Main execution
if ($DryRun) {
    Write-Host "Would copy files from config/ to destination:" -ForegroundColor Yellow
    Get-ChildItem -Path $ConfigSource -ErrorAction SilentlyContinue | ForEach-Object {
        $safe = Test-SafeToCopy $_.FullName
        $status = if ($safe) { "OK" } else { "SKIP" }
        Write-Host "  [$status] $($_.Name)"
    }
} else {
    # Create backup if force and destination exists
    if ($Force -and (Test-Path $DestDir)) {
        New-Backup
    }

    Copy-Files

    # Sync bash permission from source opencode.json to AppData (Windows reads AppData first)
    if ($env:OS -eq 'Windows_NT') {
        $appDataConfig = Join-Path $env:APPDATA 'opencode\opencode.json'
        $sourceConfig  = Join-Path $ConfigSource 'opencode.json'
        if ((Test-Path $appDataConfig) -and (Test-Path $sourceConfig)) {
            $appJson = Get-Content $appDataConfig -Raw | ConvertFrom-Json
            $srcJson = Get-Content $sourceConfig  -Raw | ConvertFrom-Json
            $appJson.permission = $srcJson.permission
            Set-Content -Path $appDataConfig -Value ($appJson | ConvertTo-Json -Depth 10) -Encoding UTF8
            Write-Host "Synced permissions to $appDataConfig" -ForegroundColor Cyan
        }
    }

    Write-Host ""
    Write-Host "Run these commands to verify:" -ForegroundColor Cyan
    Write-Host "  opencode debug config"
    Write-Host "  opencode"
    Write-Host ""
    Write-Host "To list available agents:" -ForegroundColor Cyan
    Write-Host "  opencode agent list"
    Write-Host ""
    Write-Host "To list available commands:" -ForegroundColor Cyan
    Write-Host "  opencode command list"
}