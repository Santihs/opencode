#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/config"
CONFIG_ROOT="${XDG_CONFIG_HOME:-$HOME/.config}"
DESTINATION="$CONFIG_ROOT/opencode"
BACKUP_ROOT="$CONFIG_ROOT/opencode-backups"
DRY_RUN=false
RESTORE=""
RETIRED_PATHS=(hook hooks)

usage() {
  echo "Usage: $0 [--dry-run] [--restore <backup-id>|latest]"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --restore) RESTORE="${2:-}"; shift 2 ;;
    *) usage; exit 1 ;;
  esac
done

backup() {
  [[ -d "$DESTINATION" ]] || return
  local target="$BACKUP_ROOT/$(date +%Y%m%d-%H%M%S%3N)"
  mkdir -p "$BACKUP_ROOT"
  cp -a "$DESTINATION" "$target"
  echo "Backup: $target"
}

if [[ -n "$RESTORE" ]]; then
  if [[ "$RESTORE" == "latest" ]]; then
    RESTORE="$(find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort -r | head -n 1)"
  fi
  RESTORE_PATH="$BACKUP_ROOT/$RESTORE"
  [[ -d "$RESTORE_PATH" ]] || { echo "Backup not found: $RESTORE" >&2; exit 1; }
  if [[ "$DRY_RUN" == true ]]; then
    echo "[DRY RUN] Would restore $RESTORE_PATH to $DESTINATION"
    exit 0
  fi
  backup
  STAGING="$DESTINATION.restore-$$"
  cp -a "$RESTORE_PATH" "$STAGING"
  rm -rf "$DESTINATION"
  mv "$STAGING" "$DESTINATION"
  echo "Restored: $RESTORE_PATH"
  exit 0
fi

[[ -d "$SOURCE_DIR" ]] || { echo "Source config directory not found: $SOURCE_DIR" >&2; exit 1; }
echo "Source: $SOURCE_DIR"
echo "Destination: $DESTINATION"

if [[ "$DRY_RUN" == true ]]; then
  find "$SOURCE_DIR" -mindepth 1 -maxdepth 1 -printf '[DRY RUN] Update %f\n'
  exit 0
fi

backup
mkdir -p "$DESTINATION"
for item in "$SOURCE_DIR"/* "$SOURCE_DIR"/.[!.]*; do
  [[ -e "$item" ]] || continue
  name="$(basename "$item")"
  rm -rf "$DESTINATION/$name"
  cp -a "$item" "$DESTINATION/$name"
  echo "Updated: $name"
done

for name in "${RETIRED_PATHS[@]}"; do
  if [[ -e "$DESTINATION/$name" ]]; then
    rm -rf "$DESTINATION/$name"
    echo "Removed retired configuration: $name"
  fi
done

echo "Restart OpenCode, then verify with:"
echo "  opencode debug config"
echo "  opencode mcp list"
