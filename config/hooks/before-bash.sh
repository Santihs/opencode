#!/bin/bash
# Centralized before-bash hook
# Add new bash checks below the validation section, new loggers below the logging section.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_args.command // empty')

if [ -z "$COMMAND" ]; then
    exit 0
fi

# ── VALIDATION ────────────────────────────────────────────────────────────────

if echo "$COMMAND" | grep -qE 'git push.*(--force|-f).*(main|master)'; then
    echo "Force push to main/master is blocked. Use a PR instead." >&2
    exit 2
fi
if echo "$COMMAND" | grep -qE 'git push.*(main|master)'; then
    if ! echo "$COMMAND" | grep -qE 'github\.com|PR'; then
        echo "Direct push to main/master is not allowed. Use a PR instead." >&2
        exit 2
    fi
fi
if echo "$COMMAND" | grep -qE 'rm\s+-[rf]+\s+|(rm|rmdir)\s+-[rf]'; then
    echo "Recursive delete is blocked. Delete files explicitly." >&2
    exit 2
fi
if echo "$COMMAND" | grep -qE 'git reset --(hard|mixed)'; then
    echo "Hard reset is blocked. Use soft reset or ask first." >&2
    exit 2
fi
if echo "$COMMAND" | grep -qE 'git clean\s+-f'; then
    echo "Git clean with force is blocked. Use git clean -n first." >&2
    exit 2
fi
if echo "$COMMAND" | grep -qE 'git checkout\s+--\s*\.'; then
    echo "Checkout that discards changes is blocked. Use git restore instead." >&2
    exit 2
fi
if echo "$COMMAND" | grep -qE 'git rebase\s+-i|git filter-branch|git push\s+--force-with-lease'; then
    echo "History-rewriting git operation is blocked. Ask first." >&2
    exit 2
fi
if echo "$COMMAND" | grep -qE '(mkfs|dd)\s+.*of='; then
    echo "System destructive commands are blocked." >&2
    exit 2
fi
if echo "$COMMAND" | grep -qE '(curl|wget).*\|.*sh'; then
    echo "Curl/wget piping to shell is blocked. Save to file first." >&2
    exit 2
fi

# ── LOGGING ───────────────────────────────────────────────────────────────────

LOG_DIR="$HOME/.config/opencode/logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date -u '+%Y-%m-%dT%H:%M:%S.000Z')
CWD=$(pwd)
printf '%s | cwd:%s | %s\n' "$TIMESTAMP" "$CWD" "$(echo "$COMMAND" | tr '\n' ' ')" >> "$LOG_DIR/commands.log"

exit 0
