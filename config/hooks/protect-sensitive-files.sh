#!/bin/bash
# Froggy hook: protect-sensitive-files.sh
# Blocks reading/writing sensitive files
# Exit 0 = allow, Exit 2 = block with reason

INPUT=$(cat)

# Get the file path from different possible locations
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_args.filePath // .tool_args.file_path // .tool_args.path // empty')

if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# Normalize path (remove quotes)
FILE_PATH=$(echo "$FILE_PATH" | sed 's/^["'"'"']//;s/["'"'"']$//')

# Check for sensitive file patterns
SENSITIVE_PATTERNS=(
    ".env"
    ".env.local"
    ".env.production"
    ".env.production.local"
    "secrets"
    "credentials"
    "id_rsa"
    "id_dsa"
    "id_ecdsa"
    "id_ed25519"
    "*.pem"
    "*.key"
    "*.p12"
    "*.pfx"
    ".npmrc"
    ".yarnrc"
    ".pypirc"
)

for pattern in "${SENSITIVE_PATTERNS[@]}"; do
    if echo "$FILE_PATH" | grep -qE "$pattern$"; then
        echo "Access to sensitive file is blocked: $FILE_PATH" >&2
        exit 2
    fi
done

exit 0