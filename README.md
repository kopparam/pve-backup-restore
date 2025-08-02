# Proxmox VE Backup and Restore Script

This script provides a simple way to back up and restore Proxmox VE virtual machines and containers.

## Features

- Backup and restore VMs and CTs
- Simple configuration
- Logging

## Usage

1.  **Configuration:** Edit `pve-backup-restore.conf` to specify the backup directory and the VM/CT IDs to back up.
2.  **Backup:** Run `./pve-backup-restore.sh backup` to back up the specified VMs/CTs.
3.  **Restore:** Run `./pve-backup-restore.sh restore` to restore a backup. The script will list available backups and prompt you for the backup file and a new VM/CT ID.

## Prerequisites

- Proxmox VE
- The script must be run as root.
