#!/bin/zsh
# Installs Disposable Downloads.
#
# Options (environment variables):
#   HOURS=24        how long a file stays in ~/Disposable before going to Trash
#   EMPTY_TRASH=1   empty the whole Trash once a day (0 = leave the Trash alone)
#   EMPTY_HOUR=3    hour of day (0-23) to empty the Trash
#
# Example:  HOURS=12 EMPTY_TRASH=0 ./install.sh
set -e

HERE="${0:A:h}"
APP="$HOME/Library/Application Support/Disposable"
AGENTS="$HOME/Library/LaunchAgents"
SERVICES="$HOME/Library/Services"
HOURS="${HOURS:-24}"
EMPTY_TRASH="${EMPTY_TRASH:-1}"
EMPTY_HOUR="${EMPTY_HOUR:-3}"

if [[ ! -x /usr/bin/trash ]]; then
  echo "This needs macOS 15 (Sequoia) or newer, which includes /usr/bin/trash." >&2
  exit 1
fi
[[ "$HOURS" == <1-> ]] || { echo "HOURS must be a whole number of hours." >&2; exit 1; }
[[ "$EMPTY_HOUR" == <0-23> ]] || { echo "EMPTY_HOUR must be 0-23." >&2; exit 1; }

mkdir -p "$HOME/Disposable" "$APP" "$AGENTS" "$SERVICES" "$HOME/Library/Logs"

# Scripts and settings
cp "$HERE/scripts/cleanup.sh" "$APP/cleanup.sh"
cp "$HERE/scripts/mark.sh" "$APP/mark.sh"
cat > "$APP/empty-trash.sh" <<'EOF'
#!/bin/zsh
osascript -e 'tell application "Finder" to empty trash' \
  && echo "$(date '+%F %T') emptied Trash" >> "$HOME/Library/Logs/disposable.log"
EOF
chmod +x "$APP"/*.sh
echo "HOURS=$HOURS" > "$APP/config"

# Finder right-click > Quick Actions > Mark as Disposable
rm -rf "$SERVICES/Mark as Disposable.workflow"
cp -R "$HERE/Mark as Disposable.workflow" "$SERVICES/"
# A ZIP downloaded from GitHub is quarantined, which would block the Quick Action.
xattr -dr com.apple.quarantine "$SERVICES/Mark as Disposable.workflow" "$APP" 2>/dev/null || true
/System/Library/CoreServices/pbs -update

# Hourly cleanup job
cat > "$AGENTS/com.user.disposable.cleanup.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>com.user.disposable.cleanup</string>
  <key>ProgramArguments</key><array><string>$APP/cleanup.sh</string></array>
  <key>StartInterval</key><integer>3600</integer>
  <key>RunAtLoad</key><true/>
</dict></plist>
EOF
launchctl bootout "gui/$UID/com.user.disposable.cleanup" 2>/dev/null || true
launchctl bootstrap "gui/$UID" "$AGENTS/com.user.disposable.cleanup.plist"

# Optional daily Trash empty
launchctl bootout "gui/$UID/com.user.disposable.emptytrash" 2>/dev/null || true
rm -f "$AGENTS/com.user.disposable.emptytrash.plist"
if [[ "$EMPTY_TRASH" == 1 ]]; then
  cat > "$AGENTS/com.user.disposable.emptytrash.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>com.user.disposable.emptytrash</string>
  <key>ProgramArguments</key><array><string>$APP/empty-trash.sh</string></array>
  <key>StartCalendarInterval</key><dict>
    <key>Hour</key><integer>$EMPTY_HOUR</integer><key>Minute</key><integer>0</integer>
  </dict>
</dict></plist>
EOF
  launchctl bootstrap "gui/$UID" "$AGENTS/com.user.disposable.emptytrash.plist"
fi

echo "Installed Disposable Downloads."
echo "  Folder:       ~/Disposable (files go to Trash after $HOURS hours)"
if [[ "$EMPTY_TRASH" == 1 ]]; then
  echo "  Trash:        emptied every day at $EMPTY_HOUR:00"
else
  echo "  Trash:        not emptied automatically"
fi
echo "  Quick Action: right-click files in Finder > Quick Actions > Mark as Disposable"
echo "  Log:          ~/Library/Logs/disposable.log"
