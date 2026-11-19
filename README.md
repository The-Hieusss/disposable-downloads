# Disposable Downloads

Self-cleaning downloads for macOS.

You download lots of files you only need for a few minutes: an assignment to submit on Canvas, a file to share with an AI assistant, a form to upload somewhere. Then they pile up in your Downloads folder forever.

Disposable Downloads gives you a folder, `~/Disposable`. Anything you put there goes to the Trash automatically after 24 hours.

## How it works

| What | When |
| --- | --- |
| A file sitting in `~/Disposable` for 24 hours is moved to the Trash | Checked every hour |
| The Trash is emptied *(optional, on by default)* | Every day at 3:00 AM |

The 24-hour countdown starts when a file **arrives** in the folder, either when a download finishes or when you move a file in. Unfinished downloads and hidden files are skipped.

It uses only built-in macOS tools: `launchd` for scheduling, the `trash` command, and a Finder Quick Action. There's nothing to keep running and nothing to sign in to.

## Requirements

- macOS 15 (Sequoia) or newer

## Install
git clone this project
```bash
cd disposable-downloads
./install.sh
```

No git? Click **Code → Download ZIP** on this page, unzip it, then in Terminal run `cd` into the unzipped folder and run `./install.sh`.

### Options

Set options in front of the install command:

```bash
HOURS=12 EMPTY_TRASH=0 ./install.sh
```

| Option | Default | Meaning |
| --- | --- | --- |
| `HOURS` | `24` | Hours a file stays in `~/Disposable` before going to the Trash |
| `EMPTY_TRASH` | `1` | `1` empties the Trash daily, `0` leaves your Trash alone |
| `EMPTY_HOUR` | `3` | Hour of the day (0–23) to empty the Trash |

To change a setting later, run `./install.sh` again with the new values.

> **Heads up:** with `EMPTY_TRASH=1` the **whole** Trash is emptied every day, including things you deleted yourself, not only files from `~/Disposable`. If you'd rather keep macOS's normal 30-day Trash behavior, install with `EMPTY_TRASH=0`.

## Use it

### 1. Choose "disposable" when you download

Have your browser ask where to save each download, then pick **Disposable** for throwaway files and **Downloads** for files you want to keep.

- **Chrome / Edge / Brave:** Settings → Downloads → turn on **Ask where to save each file before downloading**
- **Safari:** Settings → General → File download location → **Ask for each download**
- **Firefox:** Settings → General → Files and Applications → **Always ask you where to save files**

Tip: drag the `Disposable` folder (in your home folder) into the Finder sidebar so it's one click away in every save dialog.

### 2. Mark files you already have

Select files or folders in Finder, right-click, and choose **Quick Actions → Mark as Disposable**. They move into `~/Disposable`, and a notification tells you when they'll be trashed. If a file with the same name is already there, the new one gets a number (`report 1.pdf`) instead of overwriting it.

If you don't see it, open the **Quick Actions** submenu, choose **Customize…**, and tick **Mark as Disposable**.

### 3. Changed your mind?

Drag the file out of `~/Disposable` before its time is up. If it's already gone, it's in the Trash until the next daily empty.

## First-run permission prompts

- **Notifications:** the first time you use *Mark as Disposable*, macOS may ask to allow notifications from it.
- **Finder control:** the first time the daily empty runs, macOS asks to let it control Finder. Click **OK**, or the Trash won't be emptied. (Only with `EMPTY_TRASH=1`.)

## Check what it did

Every file that's marked or trashed, and every Trash empty, is logged:

```bash
cat ~/Library/Logs/disposable.log
```

## Uninstall

```bash
./uninstall.sh
```

This removes the scheduled jobs and the Quick Action. Your `~/Disposable` folder and anything in it are kept.

## What gets installed

| Path | Purpose |
| --- | --- |
| `~/Disposable/` | The self-cleaning folder |
| `~/Library/Application Support/Disposable/` | Scripts and settings |
| `~/Library/LaunchAgents/com.user.disposable.cleanup.plist` | Hourly cleanup job |
| `~/Library/LaunchAgents/com.user.disposable.emptytrash.plist` | Daily Trash empty (if enabled) |
| `~/Library/Services/Mark as Disposable.workflow` | Finder Quick Action |

Everything runs as your user. Nothing needs `sudo`, and no system files are changed.

## License

[MIT](LICENSE)
