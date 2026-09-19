#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_ROOT="$(mktemp -d)"
trap 'rm -rf "$CONFIG_ROOT"' EXIT

XDG_CONFIG_HOME="$CONFIG_ROOT" bash "$REPO_ROOT/update.sh"

test -f "$CONFIG_ROOT/opencode/opencode.json"
test -f "$CONFIG_ROOT/opencode/security/security-policy.ts"
test ! -d "$CONFIG_ROOT/opencode-backups"
! grep -Fq '@warp-dot-dev/opencode-warp' "$CONFIG_ROOT/opencode/opencode.json"
