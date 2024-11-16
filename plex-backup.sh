#!/bin/bash

# Script to Backup and Restore Plex Media Server Settings
# Usage:
# 1. Backup: ./plex_backup_restore.sh backup /path/to/backup/location
# 2. Restore: ./plex_backup_restore.sh restore /path/to/backup/location

# Variables
PLEX_DIR="/var/lib/plexmediaserver"
BACKUP_FILE="plex_backup.tar.gz"

# Functions
backup_plex() {
    echo "Stopping Plex Media Server..."
    sudo systemctl stop plexmediaserver

    echo "Creating backup of Plex Media Server settings..."
    sudo tar -czvf "$1/$BACKUP_FILE" "$PLEX_DIR"
    
    echo "Backup completed: $1/$BACKUP_FILE"
    
    echo "Restarting Plex Media Server..."
    sudo systemctl start plexmediaserver
}

restore_plex() {
    echo "Stopping Plex Media Server..."
    sudo systemctl stop plexmediaserver

    echo "Restoring Plex Media Server settings from backup..."
    if [ -f "$1/$BACKUP_FILE" ]; then
        sudo tar -xzvf "$1/$BACKUP_FILE" -C /
        echo "Backup restored successfully."
    else
        echo "Error: Backup file not found at $1/$BACKUP_FILE"
        exit 1
    fi

    echo "Setting correct permissions..."
    sudo chown -R plex:plex "$PLEX_DIR"
    
    echo "Restarting Plex Media Server..."
    sudo systemctl start plexmediaserver
}

# Main Script
if [ $# -ne 2 ]; then
    echo "Usage: $0 [backup|restore] /path/to/backup/location"
    exit 1
fi

case $1 in
    backup)
        backup_plex "$2"
        ;;
    restore)
        restore_plex "$2"
        ;;
    *)
        echo "Invalid option. Use 'backup' or 'restore'."
        exit 1
        ;;
esac
