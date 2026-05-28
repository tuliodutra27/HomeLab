#!/bin/bash
set -e

PROJECT_DIR="$HOME/uniasselvi-sjb"
BACKUP_DIR="$HOME/backups/uniasselvi-sjb"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/database_$TIMESTAMP.db"

mkdir -p "$BACKUP_DIR"

# Backup atômico — .backup é seguro com a app rodando
docker compose -f "$PROJECT_DIR/docker-compose.yml" exec -T app \
    sqlite3 /app/data/database.db ".backup /tmp/backup.db"

docker compose -f "$PROJECT_DIR/docker-compose.yml" exec -T app \
    cat /tmp/backup.db > "$BACKUP_FILE"

# Mantém apenas os últimos 30 dias localmente
find "$BACKUP_DIR" -name "database_*.db" -mtime +30 -delete

# Sincroniza pro Google Drive (requer rclone configurado: rclone config)
rclone copy "$BACKUP_FILE" gdrive:backups/uniasselvi-sjb/

echo "[$(date)] Backup OK: $BACKUP_FILE"
