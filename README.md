# Proxmox VE backup and restore script

This script provides a simple way to back up and restore Proxmox VE virtual machines and containers.

## Use case

I have a single Proxmox VE node and no Proxmox Backup Server. I also "polluted" the host by installing and configuring it a lot. I just wanted to ensure that my LXC containers can work independently, by cleaning up the host with a fresh Proxmox VE install. I have all my LXC boot volumes on a separate ZFS pool, therfore, I do not have a problem with wiping my boot ZFS pool.

## Features

- Backup and restore VMs and CTs
- Simple configuration
- Logging

## Usage

1.  **Configuration:** Edit `pve-backup-restore.conf` to specify the backup directory and the VM/CT IDs to back up. I use a samba share on another machine, by adding it as Storage on the Datacenter>Storage>Add>SMB/CIFS.
2.  **Backup:** Run `./pve-backup-restore.sh backup` to back up the specified VMs/CTs.
3.  **Prepare Proxmox**: If you have freshly install Proxmox, then you need access to the backup tarball. You can use a flash drive, smb like me, NFS or anyother way.
4.  **Restore:** Run `./pve-backup-restore.sh restore` to restore a backup. The script will list available backups and prompt you for the backup file and a new VM/CT ID.
