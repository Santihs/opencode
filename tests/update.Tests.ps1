Describe "OpenCode config installer" {
    BeforeEach {
        $script:installerPath = Join-Path $PSScriptRoot "..\update.ps1"
        $caseRoot = Join-Path $TestDrive ([guid]::NewGuid())
        $script:configDir = Join-Path $caseRoot "config\opencode"
        $script:backupDir = Join-Path $caseRoot "config\opencode-backups"
    }

    It "does not create a destination during dry run" {
        & $installerPath -ConfigDir $configDir -DryRun

        Test-Path -LiteralPath $configDir | Should -Be $false
    }

    It "updates managed files, preserves runtime files, removes retired hooks, and creates a backup" {
        New-Item -ItemType Directory -Force -Path (Join-Path $configDir "hooks") | Out-Null
        New-Item -ItemType Directory -Force -Path (Join-Path $configDir "hook") | Out-Null
        Set-Content -LiteralPath (Join-Path $configDir "runtime-state.txt") -Value "keep"

        & $installerPath -ConfigDir $configDir

        Test-Path -LiteralPath (Join-Path $configDir "plugins\security.ts") | Should -Be $true
        Test-Path -LiteralPath (Join-Path $configDir "AGENTS.md") | Should -Be $true
        Test-Path -LiteralPath (Join-Path $configDir "runtime-state.txt") | Should -Be $true
        Test-Path -LiteralPath (Join-Path $configDir "hook") | Should -Be $false
        Test-Path -LiteralPath (Join-Path $configDir "hooks") | Should -Be $false
        @(Get-ChildItem -LiteralPath $backupDir -Directory).Count | Should -Be 1
    }

    It "restores a selected backup after making a pre-restore backup" {
        New-Item -ItemType Directory -Force -Path $configDir | Out-Null
        Set-Content -LiteralPath (Join-Path $configDir "marker.txt") -Value "before-update"
        & $installerPath -ConfigDir $configDir
        $backup = Get-ChildItem -LiteralPath $backupDir -Directory | Select-Object -First 1
        Set-Content -LiteralPath (Join-Path $configDir "marker.txt") -Value "after-update"

        & $installerPath -ConfigDir $configDir -Restore $backup.Name

        Get-Content -LiteralPath (Join-Path $configDir "marker.txt") | Should -Be "before-update"
        @(Get-ChildItem -LiteralPath $backupDir -Directory).Count | Should -Be 2
    }
}
