#!/bin/bash

# Proxmox VE Backup and Restore Script

# Exit on error
set -e

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Main script logic
main() {
    log "Starting Proxmox VE Backup and Restore Script"

    # Load configuration
    source "$(dirname "$0")/pve-backup-restore.conf"

    # Check for root privileges
    if [ "$(id -u)" -ne 0 ]; then
        log "This script must be run as root"
        exit 1
    fi

    # Check for arguments
    if [ $# -eq 0 ]; then
        log "Usage: $0 <backup|restore>"
        exit 1
    fi

    case "$1" in
        backup)
            backup
            ;;
        restore)
            restore
            ;;
        *)
            log "Invalid command: $1"
            exit 1
            ;;
    esac
}

backup() {
    log "Starting backup..."

    # Create a timestamp
    TIMESTAMP=$(date +%Y%m%d%H%M%S)

    # Backup filename
    BACKUP_FILENAME="pve-config-backup-$TIMESTAMP.tar.gz"
    BACKUP_FILEPATH="/tmp/$BACKUP_FILENAME"

    BACKUP_SOURCES="/etc/pve/lxc /etc/pve/qemu-server /etc/pve/storage.cfg"

    log "Creating backup archive at $BACKUP_FILEPATH (following symlinks)"
    tar -czhf "$BACKUP_FILEPATH" $BACKUP_SOURCES

    log "Verifying backup contents:"
    tar -tvf "$BACKUP_FILEPATH"

    log "Moving backup to $BACKUP_DIR"
    mv "$BACKUP_FILEPATH" "$BACKUP_DIR/"

    log "Backup complete. Created $BACKUP_DIR/$BACKUP_FILENAME"
}

restore() {
    log "Starting restore..."

    # List available backups
    log "Available backups:"
    ls -1 "$BACKUP_DIR"/pve-config-backup-*.tar.gz

    # Prompt for backup file
    read -p "Enter the backup file to restore (full path): " backup_file

    # Check if the backup file exists
    if [ ! -f "$backup_file" ]; then
        log "Error: Backup file not found!"
        exit 1
    fi

    TIMESTAMP=$(date +%Y%m%d%H%M%S)
    log "Starting selective restore from $backup_file (files only)"

    # Get the list of files from the archive and process them one by one
    tar -tf "$backup_file" | while read -r archived_file; do
        # Construct the absolute path for the target file
        target_path="/$archived_file"

        # Check if the regular file exists at the target location
        if [ -f "$target_path" ]; then
            # Backup the existing file
            backup_path="$target_path.$TIMESTAMP.bak"
            log "Backing up existing file $target_path to $backup_path"
            mv "$target_path" "$backup_path"

            # Extract the specific file from the archive
            log "Restoring file $target_path"
            tar -xzf "$backup_file" -C / "$archived_file"
        fi
    done

    log "Restore complete."
}

main "$@"
