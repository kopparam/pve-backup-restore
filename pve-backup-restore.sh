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
    source pve-backup-restore.conf

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
    for vmid in $VM_IDS; do
        log "Backing up VM/CT $vmid"
        vzdump $vmid --mode snapshot --storage $BACKUP_DIR --compress zstd
    done
    log "Backup complete."
}

restore() {
    log "Starting restore..."
    
    # List available backups
    log "Available backups:"
    ls -1 $BACKUP_DIR/vzdump-*.vma.zst

    # Prompt for backup file
    read -p "Enter the backup file to restore: " backup_file

    # Prompt for new VM ID
    read -p "Enter the new VM/CT ID: " new_vmid

    # Restore the backup
    qmrestore $backup_file $new_vmid --storage local-lvm

    log "Restore complete."
}

main "$@"
