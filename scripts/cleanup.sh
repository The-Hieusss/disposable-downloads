#!/bin/zsh
# Moves anything that has been sitting in ~/Disposable for longer than
# HOURS (default 24) to the Trash. Runs hourly via launchd.

CONFIG="$HOME/Library/Application Support/Disposable/config"
[[ -f "$CONFIG" ]] && source "$CONFIG"

DIR="${DISPOSABLE_DIR:-$HOME/Disposable}"
HOURS="${DISPOSABLE_HOURS:-${HOURS:-24}}"
LOG="$HOME/Library/Logs/disposable.log"

mkdir -p "$DIR"

# -cmin uses the inode change time, which is updated when a download finishes
# or when a file is moved into the folder, so the clock starts when it arrives.
# Hidden files and unfinished browser downloads are skipped.
find "$DIR" -mindepth 1 -maxdepth 1 \
  ! -name '.*' ! -name '*.crdownload' ! -name '*.download' ! -name '*.part' \
  -cmin +$(( HOURS * 60 )) -print0 |
while IFS= read -r -d '' f; do
  if [[ -n "$DRY_RUN" ]]; then
    echo "would trash: $f"
  elif /usr/bin/trash "$f"; then
    echo "$(date '+%F %T') trashed: $f" >> "$LOG"
  fi
done
