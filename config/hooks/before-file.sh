#!/bin/bash
# Centralized before-file hook (write + edit)
# Add new file checks below the validation section, new loggers below the logging section.

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_args.filePath // .tool_args.file_path // .tool_args.path // empty')

if [ -z "$FILE_PATH" ]; then
    exit 0
fi

FILE_PATH=$(echo "$FILE_PATH" | sed 's/^["'"'"']//;s/["'"'"']$//')
BASENAME=$(basename "$FILE_PATH")

# ── VALIDATION ────────────────────────────────────────────────────────────────

BLOCKED_NAMES=(".env" ".env.local" ".env.production" ".env.production.local"
               "secrets" "credentials" "id_rsa" "id_dsa" "id_ecdsa" "id_ed25519"
               ".npmrc" ".yarnrc" ".pypirc")

for name in "${BLOCKED_NAMES[@]}"; do
    if [ "$BASENAME" = "$name" ]; then
        echo "Access to sensitive file is blocked: $FILE_PATH" >&2
        exit 2
    fi
done

if echo "$BASENAME" | grep -qE '\.(pem|key|p12|pfx)$'; then
    echo "Access to sensitive file is blocked: $FILE_PATH" >&2
    exit 2
fi

# ── LOGGING ───────────────────────────────────────────────────────────────────

LOG_DIR="$HOME/.config/opencode/logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date -u '+%Y-%m-%dT%H:%M:%S.000Z')
printf '%s | %s | %s\n' "$TIMESTAMP" "$TOOL_NAME" "$FILE_PATH" >> "$LOG_DIR/file-changes.log"

exit 0
