#!/bin/zsh
# Removes the scheduled jobs. Leaves ~/Disposable and its contents alone.
for job in cleanup emptytrash; do
  launchctl bootout "gui/$UID/com.user.disposable.$job" 2>/dev/null
  rm -f "$HOME/Library/LaunchAgents/com.user.disposable.$job.plist"
done
rm -rf "$HOME/Library/Application Support/Disposable"
rm -rf "$HOME/Library/Services/Mark as Disposable.workflow"
/System/Library/CoreServices/pbs -update
echo "Uninstalled. ~/Disposable was kept."
