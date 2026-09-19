param(
    [switch]$DryRun,
    [switch]$Force,
    [string]$Restore,
    [string]$ConfigDir
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceDir = Join-Path $ScriptDir "config"
$ConfigRoot = if ($ConfigDir) {
    Split-Path -Parent ([System.IO.Path]::GetFullPath($ConfigDir))
} elseif ($env:XDG_CONFIG_HOME) {
    $env:XDG_CONFIG_HOME
} else {
    Join-Path $HOME ".config"
}
$Destination = if ($ConfigDir) { [System.IO.Path]::GetFullPath($ConfigDir) } else { Join-Path $ConfigRoot "opencode" }
$BackupRoot = Join-Path $ConfigRoot "opencode-backups"
$RetiredPaths = @("hook", "hooks", "plugins")

function New-Backup {
    if (-not (Test-Path -LiteralPath $Destination)) { return }

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmssfff"
    $backup = Join-Path $BackupRoot $timestamp
    New-Item -ItemType Directory -Force -Path $BackupRoot | Out-Null
    New-Item -ItemType Directory -Force -Path $backup | Out-Null
    Get-ChildItem -LiteralPath $Destination -Force | Copy-Item -Destination $backup -Recurse -Force
    Write-Host "Backup: $backup"
}

function Get-RestorePath {
    if ($Restore -eq "latest") {
        return Get-ChildItem -LiteralPath $BackupRoot -Directory |
            Sort-Object Name -Descending |
            Select-Object -First 1 -ExpandProperty FullName
    }

    return Join-Path $BackupRoot $Restore
}

if ($Restore) {
    $restorePath = Get-RestorePath
    if (-not $restorePath -or -not (Test-Path -LiteralPath $restorePath)) {
        throw "Backup not found: $Restore"
    }

    if ($DryRun) {
        Write-Host "[DRY RUN] Would restore $restorePath to $Destination"
        exit 0
    }

    New-Backup
    $staging = "$Destination.restore-$([guid]::NewGuid())"
    New-Item -ItemType Directory -Force -Path $staging | Out-Null
    Get-ChildItem -LiteralPath $restorePath -Force | Copy-Item -Destination $staging -Recurse -Force
    if (Test-Path -LiteralPath $Destination) { Remove-Item -LiteralPath $Destination -Recurse -Force }
    Move-Item -LiteralPath $staging -Destination $Destination
    Write-Host "Restored: $restorePath"
    exit 0
}

if (-not (Test-Path -LiteralPath $SourceDir)) {
    throw "Source config directory not found: $SourceDir"
}

Write-Host "Source: $SourceDir"
Write-Host "Destination: $Destination"
if ($Force) { Write-Warning "-Force is no longer needed; normal updates replace source-owned files." }

$sourceItems = Get-ChildItem -LiteralPath $SourceDir -Force
if ($DryRun) {
    $sourceItems | ForEach-Object { Write-Host "[DRY RUN] Update $($_.Name)" }
    $RetiredPaths | ForEach-Object {
        if (Test-Path -LiteralPath (Join-Path $Destination $_)) { Write-Host "[DRY RUN] Remove retired $_" }
    }
    exit 0
}

New-Backup
New-Item -ItemType Directory -Force -Path $Destination | Out-Null

foreach ($item in $sourceItems) {
    $target = Join-Path $Destination $item.Name
    if (Test-Path -LiteralPath $target) { Remove-Item -LiteralPath $target -Recurse -Force }
    Copy-Item -LiteralPath $item.FullName -Destination $target -Recurse -Force
    Write-Host "Updated: $($item.Name)"
}

foreach ($name in $RetiredPaths) {
    $target = Join-Path $Destination $name
    if (Test-Path -LiteralPath $target) {
        Remove-Item -LiteralPath $target -Recurse -Force
        Write-Host "Removed retired configuration: $name"
    }
}

Write-Host ""
Write-Host "Restart OpenCode, then verify with:"
Write-Host "  opencode debug config"
Write-Host "  opencode mcp list"
