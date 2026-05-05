#!/bin/bash
#
# OpenCode Global Config Installer/Updater
# Usage: ./update.sh [--dry-run] [--force] [--restore <backup-name>|latest]
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SOURCE="$SCRIPT_DIR/config"
BACKUP_DIR=""
DEST_DIR=""
DRY_RUN=false
FORCE=false
RESTORE_MODE=false
RESTORE_TARGET=""

# Detect OS and set destination
detect_platform() {
    case "$(uname -s)" in
        Linux*)
            DEST_DIR="$HOME/.config/opencode"
            BACKUP_DIR="$HOME/.config/opencode-backups"
            ;;
        Darwin*)
            DEST_DIR="$HOME/.config/opencode"
            BACKUP_DIR="$HOME/.config/opencode-backups"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            DEST_DIR="$APPDATA/opencode"
            BACKUP_DIR="$APPDATA/opencode-backups"
            ;;
        *)
            echo "Error: Unknown platform"
            exit 1
            ;;
    esac
}

# Parse arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --force)
                FORCE=true
                shift
                ;;
            --restore)
                RESTORE_MODE=true
                if [[ "$2" == "latest" ]]; then
                    RESTORE_TARGET="latest"
                    shift 2
                elif [[ "$2" =~ ^[0-9]{8}-[0-9]{6}$ ]]; then
                    RESTORE_TARGET="$2"
                    shift 2
                else
                    echo "Error: Invalid restore target. Use 'latest' or YYYYMMDD-HHMMSS"
                    exit 1
                fi
                ;;
            *)
                echo "Usage: $0 [--dry-run] [--force] [--restore <backup-name>|latest]"
                exit 1
                ;;
        esac
    done
}

# Create backup
create_backup() {
    if [[ -d "$DEST_DIR" ]]; then
        timestamp=$(date +%Y%m%d-%H%M%S)
        backup_path="$BACKUP_DIR/$timestamp"

        echo "Creating backup at $backup_path..."
        mkdir -p "$BACKUP_DIR"
        cp -r "$DEST_DIR" "$backup_path"
        echo "Backup created: $backup_path"
    else
        echo "No existing config to backup (destination does not exist)"
    fi
}

# Restore from backup
restore_backup() {
    if [[ -z "$RESTORE_TARGET" ]]; then
        echo "Error: No restore target specified"
        exit 1
    fi

    local restore_path=""
    if [[ "$RESTORE_TARGET" == "latest" ]]; then
        restore_path=$(ls -t "$BACKUP_DIR"/ 2>/dev/null | head -1)
    else
        restore_path="$BACKUP_DIR/$RESTORE_TARGET"
    fi

    if [[ -z "$restore_path" || ! -d "$restore_path" ]]; then
        echo "Error: Backup not found: $RESTORE_TARGET"
        exit 1
    fi

    echo "Restoring from backup: $restore_path"

    if [[ -d "$DEST_DIR" ]]; then
        rm -rf "$DEST_DIR"
    fi

    cp -r "$restore_path" "$DEST_DIR"
    echo "Restore complete!"
}

# Files and patterns to never copy
is_safe_to_copy() {
    local file="$1"
    local filename
    filename=$(basename "$file")

    # Never copy these
    case "$filename" in
        .env|.env.*|*.local.json|secrets|credentials|*.pem|*.key)
            return 1
            ;;
    esac

    # Never copy files matching these patterns
    case "$file" in
        *secrets*|*credentials*|*.pem|*.key|*.p12|*.pfx)
            return 1
            ;;
    esac

    return 0
}

# Copy a directory, expanding $OPENCODE_CONFIG_DIR in .md files
copy_dir_with_substitution() {
    local src="$1"
    local dst="$2"
    mkdir -p "$dst"
    for f in "$src"/*; do
        local fname
        fname=$(basename "$f")
        if [[ -f "$f" && "$f" == *.md ]]; then
            sed "s|\$OPENCODE_CONFIG_DIR|$DEST_DIR|g" "$f" > "$dst/$fname"
            chmod --reference="$f" "$dst/$fname" 2>/dev/null || true
        elif [[ -f "$f" ]]; then
            cp -f "$f" "$dst/$fname"
        elif [[ -d "$f" ]]; then
            copy_dir_with_substitution "$f" "$dst/$fname"
        fi
    done
}

# Copy files from source to destination
copy_files() {
    copied=0
    skipped=0

    # Create destination directory if needed
    if [[ ! -d "$DEST_DIR" ]]; then
        mkdir -p "$DEST_DIR"
    fi

    # Copy each item from config/
    for item in "$CONFIG_SOURCE"/*; do
        item_name=$(basename "$item")

        if ! is_safe_to_copy "$item"; then
            echo "Skipping (unsafe): $item_name"
            skipped=$((skipped + 1))
            continue
        fi

        if [[ -d "$item" ]]; then
            # It's a directory
            if [[ -d "$DEST_DIR/$item_name" ]]; then
                if [[ "$FORCE" == "true" ]]; then
                    echo "Overwriting: $item_name/"
                    rm -rf "$DEST_DIR/$item_name"
                    copy_dir_with_substitution "$item" "$DEST_DIR/$item_name"
                    copied=$((copied + 1))
                else
                    echo "Skipping (exists): $item_name/"
                    skipped=$((skipped + 1))
                fi
            else
                echo "Creating: $item_name/"
                copy_dir_with_substitution "$item" "$DEST_DIR/$item_name"
                copied=$((copied + 1))
            fi
        elif [[ -f "$item" ]]; then
            # It's a file
            if [[ -f "$DEST_DIR/$item_name" ]]; then
                if [[ "$FORCE" == "true" ]]; then
                    echo "Overwriting: $item_name"
                    cp -f "$item" "$DEST_DIR/$item_name"
                    copied=$((copied + 1))
                else
                    echo "Skipping (exists): $item_name"
                    skipped=$((skipped + 1))
                fi
            else
                echo "Creating: $item_name"
                cp -f "$item" "$DEST_DIR/$item_name"
                copied=$((copied + 1))
            fi
        fi
    done

    echo ""
    echo "Summary:"
    echo "  Copied: $copied"
    echo "  Skipped: $skipped"
}

# Print verification commands
print_verification() {
    echo ""
    echo "Run these commands to verify:"
    echo "  opencode debug config"
    echo "  opencode"
    echo ""
    echo "To list available agents:"
    echo "  opencode agent list"
    echo ""
    echo "To list available commands:"
    echo "  opencode command list"
}

# Main
main() {
    detect_platform
    parse_args "$@"

    echo "OpenCode Global Config Installer"
    echo "==========================="
    echo ""
    echo "Source:      $CONFIG_SOURCE"
    echo "Destination: $DEST_DIR"
    echo ""

    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY RUN] No changes will be made"
        echo ""
    fi

    if [[ "$RESTORE_MODE" == "true" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            echo "[DRY RUN] Would restore from: $RESTORE_TARGET"
        else
            restore_backup
        fi
        exit 0
    fi

    # Create backup if not dry-run and destination exists
    if [[ "$DRY_RUN" == "false" && -d "$DEST_DIR" && "$FORCE" == "true" ]]; then
        create_backup
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        echo "Would copy files from config/ to destination:"
        ls -la "$CONFIG_SOURCE/"
    else
        copy_files
        print_verification
    fi
}

main "$@"