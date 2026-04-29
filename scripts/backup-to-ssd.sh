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

human_size() {
  du -sh "$1" 2>/dev/null | awk '{print $1}' || echo "unknown"
}

count_files() {
  find "$1" -type f 2>/dev/null | wc -l | tr -d ' '
}

rsync_supports_info_progress2() {
  rsync --help 2>/dev/null | grep -q -- "--info"
}

run_rsync() {
  local source="$1"
  local destination="$2"
  local link_dest="${3:-}"

  local common_args=(
    -a
    --human-readable
    --delete
    --exclude='**/cache/**'
    --exclude='**/Cache/**'
    --exclude='**/logs/**'
    --exclude='**/Logs/**'
    --exclude='**/tmp/**'
    --exclude='**/temp/**'
  )

  if [ -n "$link_dest" ]; then
    common_args+=(--link-dest="$link_dest")
  fi

  if rsync_supports_info_progress2; then
    rsync "${common_args[@]}" \
      --info=progress2,stats2 \
      "$source" "$destination" | tee -a "$LOG_FILE"
  else
    # macOS built-in rsync is usually old and may not support --info=progress2.
    # --progress is noisier, but works on the older rsync.
    rsync "${common_args[@]}" \
      --progress \
      "$source" "$destination" | tee -a "$LOG_FILE"
  fi
}

run_repo_rsync() {
  local source="$1"
  local destination="$2"

  local common_args=(
    -a
    --human-readable
    --delete
    --exclude='.git/'
    --exclude='data/'
    --exclude='.env'
    --exclude='*.db'
    --exclude='*.sqlite'
    --exclude='*.sqlite3'
    --exclude='*.key'
    --exclude='*.pem'
  )

  if rsync_supports_info_progress2; then
    rsync "${common_args[@]}" \
      --info=progress2,stats2 \
      "$source" "$destination" | tee -a "$LOG_FILE"
  else
    rsync "${common_args[@]}" \
      --progress \
      "$source" "$destination" | tee -a "$LOG_FILE"
  fi
}

# === Checks ===
log "Stage 1/7: Running checks"

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

log "Backup destination: $DEST"
log "Live data source: $DATA_SRC ($(human_size "$DATA_SRC"), $(count_files "$DATA_SRC") files)"
log "Repo source: $REPO_SRC ($(human_size "$REPO_SRC"), $(count_files "$REPO_SRC") files)"

# === Stop fragile containers ===
log "Stage 2/7: Stopping fragile containers"

STARTED_CONTAINERS=()

for container in "${STOP_CONTAINERS[@]}"; do
  if docker ps --format '{{.Names}}' | grep -Fxq "$container"; then
    log "Stopping $container"
    docker stop "$container" >/dev/null
    STARTED_CONTAINERS+=("$container")
    log "$container stopped"
  else
    log "$container is not running; skipping stop"
  fi
done

# Make sure stopped containers are restarted even if rsync fails
cleanup() {
  if [ "${#STARTED_CONTAINERS[@]}" -gt 0 ]; then
    log "Stage cleanup: Restarting stopped containers"
  fi

  for container in "${STARTED_CONTAINERS[@]}"; do
    log "Restarting $container"
    docker start "$container" >/dev/null || log "WARNING: failed to restart $container"
  done
}
trap cleanup EXIT

# === Backup live app data ===
log "Stage 3/7: Backing up live app data"

if [ -L "$BACKUP_ROOT/latest" ] && [ -d "$BACKUP_ROOT/latest/selfhosted-data" ]; then
  log "Using previous backup as link-dest for faster incremental backup"
  run_rsync "$DATA_SRC/" "$DEST/selfhosted-data/" "$BACKUP_ROOT/latest/selfhosted-data"
else
  log "No previous backup found; doing full data backup"
  run_rsync "$DATA_SRC/" "$DEST/selfhosted-data/"
fi

log "Live app data backup complete: $(human_size "$DEST/selfhosted-data")"

# === Backup compose repo ===
log "Stage 4/7: Backing up compose repo"

run_repo_rsync "$REPO_SRC/" "$DEST/docker-composes/"

log "Compose repo backup complete: $(human_size "$DEST/docker-composes")"

# === Update latest symlink ===
log "Stage 5/7: Updating latest symlink"

rm -f "$BACKUP_ROOT/latest"
ln -s "$DEST" "$BACKUP_ROOT/latest"

log "latest -> $DEST"

# === Retention cleanup ===
log "Stage 6/7: Deleting backups older than $KEEP_DAYS days"

find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -mtime +"$KEEP_DAYS" -print -exec rm -rf {} + | tee -a "$LOG_FILE"

# === Summary ===
log "Stage 7/7: Backup summary"
log "Backup complete: $DEST"
log "Final backup size: $(human_size "$DEST")"
log "Backups currently stored:"
find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d -print | sort | tee -a "$LOG_FILE"