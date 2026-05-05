$raw = [Console]::In.ReadToEnd()
try { $data = $raw | ConvertFrom-Json } catch { exit 0 }
$filePath = if ($data.tool_args.filePath) { $data.tool_args.filePath }
            elseif ($data.tool_args.file_path) { $data.tool_args.file_path }
            else { $data.tool_args.path }
if (-not $filePath) { exit 0 }

$blocked = @('.env','.env.local','.env.production','.env.production.local',
             'secrets','credentials','id_rsa','id_dsa','id_ecdsa','id_ed25519',
             '.npmrc','.yarnrc','.pypirc','.pem','.key','.p12','.pfx')

foreach ($p in $blocked) {
    if ($filePath -match ([regex]::Escape($p) + '$')) {
        [Console]::Error.WriteLine("Access to sensitive file is blocked: $filePath")
        exit 2
    }
}

exit 0
