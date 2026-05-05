$raw = [Console]::In.ReadToEnd()
try {
    $data = $raw | ConvertFrom-Json
    $toolName = if ($data.tool_name) { $data.tool_name } else { 'unknown' }
    $filePath = if ($data.tool_args.filePath) { $data.tool_args.filePath }
                elseif ($data.tool_args.file_path) { $data.tool_args.file_path }
                else { $data.tool_args.path }
    if (-not $filePath) { exit 0 }

    $logDir = Join-Path $HOME '.config\opencode\logs'
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null

    $ts   = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
    $line = "$ts | $toolName | $filePath`n"
    [System.IO.File]::AppendAllText((Join-Path $logDir 'file-changes.log'), $line)
} catch { }
exit 0
