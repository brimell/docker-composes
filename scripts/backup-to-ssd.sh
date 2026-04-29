#!/usr/bin/env bash
set -euo pipefail

# === Config ===
SSD_NAME="Stuff"
BACKUP_ROOT="/Volumes/$SSD_NAME/selfhosted-backups"

# Your compose/config repo
REPO_SRC="$HOME/Documents/GitHub/docker-composes"

# Your live app data folder.
# Ideally move live data here. If you have not moved it yet, temporarily set:
# DATA_SRC="$HOME/Documents/GitHub/docker-composes/data"
DATA_SRC="$HOME/selfhosted-data"

# Containers to stop briefly for safer database backups.
# Add other database-heavy containers here if needed, e.g. actualbudget, homarr, sqlite apps, etc.
STOP_CONTAINERS=("portainer")

KEEP_DAYS=30

DATE="$(date +%Y-%m-%d_%H-%M-%S)"
DEST="$BACKUP_ROOT/$DATE"
LOG_DIR="$HOME/Library/Logs/selfhosted-backups"
LOG_FILE="$LOG_DIR/backup.log"

mkdir -p "$LOG_DIR"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

fail() {
  log "ERROR: $*"
  exit 1
}

# === Checks ===
if [ ! -d "/Volumes/$SSD_NAME" ]; then
  fail "SSD not mounted at /Volumes/$SSD_NAME. Backup skipped."
fi

if [ ! -d "$REPO_SRC" ]; then
  fail "Repo source not found: $REPO_SRC"
fi

if [ ! -d "$DATA_SRC" ]; then
  fail "Data source not found: $DATA_SRC"
fi

mkdir -p "$BACKUP_ROOT"
mkdir -p "$DEST"

log "Starting backup to $DEST"

# === Stop fragile containers ===
STARTED_CONTAINERS=()

for container in "${STOP_CONTAINERS[@]}"; do
  if docker ps --format '{{.Names}}' | grep -Fxq "$container"; then
    log "Stopping $container"
    docker stop "$container" >/dev/null
    STARTED_CONTAINERS+=("$container")
  else
    log "$container is not running; skipping stop"
  fi
done

# Make sure stopped containers are restarted even if rsync fails
cleanup() {
  for container in "${STARTED_CONTAINERS[@]}"; do
    log "Restarting $container"
    docker start "$container" >/dev/null || log "WARNING: failed to restart $container"
  done
}
trap cleanup EXIT

# === Backup live app data ===
log "Backing up live app data"

if [ -L "$BACKUP_ROOT/latest" ] && [ -d "$BACKUP_ROOT/latest/selfhosted-data" ]; then
  rsync -a --delete \
    --link-dest="$BACKUP_ROOT/latest/selfhosted-data" \
    --exclude='**/cache/**' \
    --exclude='**/Cache/**' \
    --exclude='**/logs/**' \
    --exclude='**/Logs/**' \
    --exclude='**/tmp/**' \
    --exclude='**/temp/**' \
    "$DATA_SRC/" "$DEST/selfhosted-data/"
else
  rsync -a --delete \
    --exclude='**/cache/**' \
    --exclude='**/Cache/**' \
    --exclude='**/logs/**' \
    --exclude='**/Logs/**' \
    --exclude='**/tmp/**' \
    --exclude='**/temp/**' \
    "$DATA_SRC/" "$DEST/selfhosted-data/"
fi

# === Backup compose repo, excluding things that should not be copied as live state ===
log "Backing up compose repo"

rsync -a --delete \
  --exclude='.git/' \
  --exclude='data/' \
  --exclude='.env' \
  --exclude='*.db' \
  --exclude='*.sqlite' \
  --exclude='*.sqlite3' \
  --exclude='*.key' \
  --exclude='*.pem' \
  "$REPO_SRC/" "$DEST/docker-composes/"

# === Update latest symlink ===
rm -f "$BACKUP_ROOT/latest"
ln -s "$DEST" "$BACKUP_ROOT/latest"

# === Retention cleanup ===
log "Deleting backups older than $KEEP_DAYS days"
find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -mtime +"$KEEP_DAYS" -exec rm -rf {} +

log "Backup complete: $DEST"