$raw = [Console]::In.ReadToEnd()
try { $data = $raw | ConvertFrom-Json } catch { exit 0 }
$command = $data.tool_args.command
if (-not $command) { exit 0 }

if ($command -match 'git push.*(--force|-f).*(main|master)') {
    [Console]::Error.WriteLine("Force push to main/master is blocked. Use a PR instead.")
    exit 2
}
if ($command -match 'git push.*(main|master)' -and $command -notmatch 'github\.com|PR') {
    [Console]::Error.WriteLine("Direct push to main/master is not allowed. Use a PR instead.")
    exit 2
}
if ($command -match 'rm\s+-[rf]+\s+|(rm|rmdir)\s+-[rf]') {
    [Console]::Error.WriteLine("Recursive delete is blocked. Delete files explicitly.")
    exit 2
}
if ($command -match 'git reset --(hard|mixed)') {
    [Console]::Error.WriteLine("Hard reset is blocked. Use soft reset or ask first.")
    exit 2
}
if ($command -match 'git clean\s+-f') {
    [Console]::Error.WriteLine("Git clean with force is blocked. Use git clean -n first.")
    exit 2
}
if ($command -match 'git checkout\s+--\s*\.') {
    [Console]::Error.WriteLine("Checkout that discards changes is blocked. Use git restore instead.")
    exit 2
}
if ($command -match '(mkfs|dd)\s+.*of=') {
    [Console]::Error.WriteLine("System destructive commands are blocked.")
    exit 2
}
if ($command -match 'curl|wget.*\|.*sh') {
    [Console]::Error.WriteLine("Curl/wget piping to shell is blocked. Save to file first.")
    exit 2
}

exit 0
