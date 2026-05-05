# Centralized before-file hook (write + edit)
# Add new file checks below the validation section, new loggers below the logging section.

$raw = [Console]::In.ReadToEnd()
try { $data = $raw | ConvertFrom-Json } catch { exit 0 }
$toolName = if ($data.tool_name) { $data.tool_name } else { 'unknown' }
$filePath = if ($data.tool_args.filePath) { $data.tool_args.filePath }
            elseif ($data.tool_args.file_path) { $data.tool_args.file_path }
            else { $data.tool_args.path }
if (-not $filePath) { exit 0 }

# ── VALIDATION ────────────────────────────────────────────────────────────────

$basename = Split-Path $filePath -Leaf

$blockedNames = @('.env','.env.local','.env.production','.env.production.local',
                  'secrets','credentials','id_rsa','id_dsa','id_ecdsa','id_ed25519',
                  '.npmrc','.yarnrc','.pypirc')

$blockedExts = @('.pem','.key','.p12','.pfx')

foreach ($name in $blockedNames) {
    if ($basename -eq $name) {
        [Console]::Error.WriteLine("Access to sensitive file is blocked: $filePath")
        exit 2
    }
}
foreach ($ext in $blockedExts) {
    if ($basename.EndsWith($ext)) {
        [Console]::Error.WriteLine("Access to sensitive file is blocked: $filePath")
        exit 2
    }
}

# ── LOGGING ───────────────────────────────────────────────────────────────────

try {
    $logDir = Join-Path $HOME '.config\opencode\logs'
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    $ts   = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
    $line = "$ts | $toolName | $filePath`n"
    [System.IO.File]::AppendAllText((Join-Path $logDir 'file-changes.log'), $line)
} catch { }

exit 0
