#!/bin/sh

DATA_DIR="/data"
BACKUP_DIR="/backup"

if [ ! -d "$DATA_DIR" ]; then
    echo "Error: $DATA_DIR does not exist."
    exit 1
fi

mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
ARCHIVE="$BACKUP_DIR/backup-$TIMESTAMP.tar.gz"

echo "Creating backup..."
tar -czf "$ARCHIVE" -C "$DATA_DIR" .
echo "$ARCHIVE"

echo "Removing backups older than 30 days..."
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +30 -delete

echo "Backup completed."

