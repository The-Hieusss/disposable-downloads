#!/bin/zsh
# Moves the given files/folders into ~/Disposable (used by the Finder
# "Mark as Disposable" Quick Action). Never overwrites: a name clash gets
# " 1", " 2", ... appended. The 24h countdown starts when the move happens.

CONFIG="$HOME/Library/Application Support/Disposable/config"
[[ -f "$CONFIG" ]] && source "$CONFIG"
HOURS="${HOURS:-24}"

DEST="${DISPOSABLE_DIR:-$HOME/Disposable}"
LOG="$HOME/Library/Logs/disposable.log"
mkdir -p "$DEST"
moved=0

for f in "$@"; do
  [[ -e "$f" ]] || continue
  [[ "${f:A:h}" == "${DEST:A}" ]] && continue    # already in Disposable

  base="${f:t}"
  target="$DEST/$base"
  n=1
  while [[ -e "$target" ]]; do
    if [[ -f "$f" && "$base" == ?*.* ]]; then
      target="$DEST/${base:r} $n.${base:e}"
    else
      target="$DEST/$base $n"
    fi
    (( n++ ))
  done

  if mv -n "$f" "$target"; then
    (( moved++ ))
    echo "$(date '+%F %T') marked: $f" >> "$LOG"
  fi
done

if (( moved > 0 )) && [[ -z "$NO_NOTIFY" ]]; then
  if (( moved == 1 )); then msg="1 item will be trashed in $HOURS hours"
  else msg="$moved items will be trashed in $HOURS hours"; fi
  osascript -e "display notification \"$msg\" with title \"Moved to Disposable\""
fi
