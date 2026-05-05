#!/bin/bash
# Froggy hook: validate-bash.sh
# Blocks dangerous bash commands
# Exit 0 = allow, Exit 2 = block with reason

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_args.command // empty')

if [ -z "$COMMAND" ]; then
    exit 0
fi

# Block force push to main/master
if echo "$COMMAND" | grep -qE 'git push.*(--force|-f).*(main|master)'; then
    echo "Force push to main/master is blocked. Use a PR instead." >&2
    exit 2
fi

# Block direct push to main/master
if echo "$COMMAND" | grep -qE 'git push.*main|git push.*master'; then
    if ! echo "$COMMAND" | grep -qE 'github\.com|PR'; then
        echo "Direct push to main/master is not allowed. Use a PR instead." >&2
        exit 2
    fi
fi

# Block recursive delete
if echo "$COMMAND" | grep -qE 'rm\s+-[rf]+\s+|(rm|rmdir)\s+-[rf]'; then
    echo "Recursive delete is blocked. Delete files explicitly." >&2
    exit 2
fi

# Block hard reset
if echo "$COMMAND" | grep -qE 'git reset --hard|git reset --mixed'; then
    echo "Hard reset is blocked. Use soft reset or ask first." >&2
    exit 2
fi

# Block git clean force
if echo "$COMMAND" | grep -qE 'git clean\s+-f'; then
    echo "Git clean with force is blocked. Use git clean -n first." >&2
    exit 2
fi

# Block checkout that discards
if echo "$COMMAND" | grep -qE 'git checkout\s+--\s*\.';
then
    echo "Checkout that discards changes is blocked. Use git restore instead." >&2
    exit 2
fi

# Block system destroy commands
if echo "$COMMAND" | grep -qE '(mkfs|dd)\s+.*of='; then
    echo "System destructive commands are blocked." >&2
    exit 2
fi

# Block history-rewriting git operations
if echo "$COMMAND" | grep -qE 'git rebase\s+-i|git filter-branch|git push\s+--force-with-lease'; then
    echo "History-rewriting git operation is blocked. Ask first." >&2
    exit 2
fi

# Block curl piping to shell without confirmation
if echo "$COMMAND" | grep -qE '(curl|wget).*\|.*sh'; then
    echo "Curl/wget piping to shell is blocked. Save to file first." >&2
    exit 2
fi

exit 0