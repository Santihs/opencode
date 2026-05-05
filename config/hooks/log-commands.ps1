$raw = [Console]::In.ReadToEnd()
try {
    $data = $raw | ConvertFrom-Json
    $command = $data.tool_args.command
    if (-not $command) { exit 0 }

    $logDir = Join-Path $HOME '.config\opencode\logs'
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null

    $ts  = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
    $cwd = (Get-Location).Path
    $line = "$ts | cwd:$cwd | $($command -replace "`n", ' \n ')`n"
    Add-Content -Path (Join-Path $logDir 'commands.log') -Value $line -NoNewline
} catch { }
exit 0
