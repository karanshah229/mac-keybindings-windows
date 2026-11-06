# mac-keybindings-windows

macOS keyboard shortcuts on Windows 11, so muscle memory from a Mac keeps working.

| Mac     | Windows key |
|---------|-------------|
| Cmd     | Alt         |
| Option  | Win         |
| Control | Ctrl        |
| Rectangle (window snapping) | Win + Alt |

Everything is one [AutoHotkey v2](https://www.autohotkey.com/) script, plus a PowerShell 7 setup that gives Windows Terminal an iTerm + oh-my-zsh feel.

## Files

| File | What it does |
|------|--------------|
| `MacKeys.ahk` | All the key remapping. Runs at login. |
| `MacKeys.ps1` | PSReadLine keys for the terminal: Ctrl+A/E/K/U/W, and the Cmd+K clear handler. |
| `Shell.ps1` | PowerShell 7 setup: loads `MacKeys.ps1`, `Aliases.ps1` and `Unix.ps1`, Oh My Posh prompt, zoxide, history suggestions, posh-git, Terminal-Icons, PSFzf. |
| `Aliases.ps1` | `l` / `ll` / `la` and oh-my-zsh git shorthands (`gst`, `gco`, `gpsup`, ...). |
| `Unix.ps1` | Mac/Linux commands: see [Terminal commands](#terminal-commands). |
| `windows-terminal/settings.json` | Windows Terminal settings snapshot (default profile, Nerd Font, keybindings). |

## Shortcuts

### Everywhere

| Keys | Action |
|------|--------|
| Alt + any letter/digit/symbol | Ctrl + that key (Cmd = Ctrl), with or without Shift |
| Alt + Click / Alt + Shift + Click | Ctrl + Click / Ctrl + Shift + Click |
| Alt + scroll wheel | Ctrl + scroll wheel: zoom in / out |
| Alt + Left / Right | Start / end of line (+ Shift selects) |
| Alt + Up / Down | Start / end of document (+ Shift selects) |
| Alt + Backspace | Delete to start of line |
| Win + Left / Right | Previous / next word (+ Shift selects) |
| Win + Backspace / Delete | Delete previous / next word |
| Win + Up / Down | Page up / down |
| Ctrl + A / E / K | Start of line / end of line / delete to end of line (outside terminals) |
| Alt + Q | Quit app (closes all its windows) |
| Alt + H | Hide app (minimizes all its windows) |
| Alt + M | Minimize |
| Alt + G / Alt + Shift + G | Find next / previous |
| Alt + Shift + Z | Redo |
| Alt + Shift + [ / ] | Previous / next tab |
| Alt + Shift + 3 | Full-screen screenshot (saved) |
| Alt + Shift + 4 or X | Region screenshot (Snipping Tool) |
| Alt + E | File Explorer |
| Alt + Shift + C | [Ditto](https://github.com/sabrogden/Ditto) clipboard history popup |
| Alt + Ctrl + F | Full screen |
| Alt + Ctrl + Q | Lock screen |
| Alt + Ctrl + Space | Emoji picker |
| Win + Alt + Esc | Task Manager (Force Quit) |
| Win + Alt + I | Developer tools |
| Win + Alt + F | Find and replace |
| Ctrl + Left / Right | Previous / next virtual desktop (Spaces) |
| Ctrl + Up | Task View (Mission Control) |
| Win + Alt + Left / Right | Left / right half of the screen |
| Win + Alt + Up / Down | Top / bottom half of the screen |
| (press the same one again) | Move to the monitor in that direction, on its opposite half (e.g. top half → bottom half of the screen above), like Rectangle |
| Win + Alt + Enter | Maximize |
| Win + Alt + Backspace | Back to the size before snapping |
| Win + Alt + Shift + Left / Right | Move window to the previous / next monitor |

Tapping Alt alone does not open the menu bar, and tapping Win alone does not open Start. While the Alt+Tab switcher is open, every remap is paused so arrows and clicks reach the switcher.

### Windows Terminal (iTerm-style)

| Keys | Action |
|------|--------|
| Alt + C / V | Copy / paste (Alt+C never sends an interrupt) |
| Alt + A | Select the command line, so Backspace or typing replaces it; Alt+C copies it (PowerShell). Ctrl + Shift + A still selects everything on screen |
| Alt + K | Clear screen and scrollback, keeping what you've typed |
| Alt + T / N / W | New tab / new window / close pane or tab |
| Alt + 1..9 | Switch to tab 1..9 |
| Alt + F | Find |
| Alt + D / Alt + Shift + D | Split pane right / down |
| Alt + [ / ] | Focus pane left / right |
| Alt + Left / Right | Start / end of line |
| Alt + Up / Down | Scroll to top / bottom |
| Alt + Backspace | Delete to start of line |
| Win + Backspace | Delete previous word |

### File Explorer and browsers

| Keys | Action |
|------|--------|
| Alt + [ / ] | Back / forward |
| Alt + Left / Right | Back / forward (start / end of line while typing in a text field, and always in Word / Excel / PowerPoint on the web) |
| Alt + Up | Enclosing folder (Explorer) |
| Alt + Down | Open selection (Explorer) |
| Alt + Backspace | Move to Recycle Bin (Explorer) |
| Alt + Shift + J | Downloads (Chrome) |

### Excel (desktop and on the web)

| Keys | Action |
|------|--------|
| Alt + Enter / Win + Enter | New line in a cell |
| Win + Backspace / Win + Delete | Delete the previous / next word while editing a cell (Excel has no Ctrl + Backspace for this) |

Office on the web (Word, Excel, PowerPoint) is recognised by the app's frame in the page, checked via UI Automation when you press the key: on SharePoint and OneDrive neither the tab title nor the address says which app it is. In other web pages Alt + Enter stays Ctrl + Enter.

### Claude desktop app

| Keys | Action |
|------|--------|
| Enter | New line in the prompt box |
| Alt + Enter | Send the prompt |

Only while typing in the prompt box with no `/` or `@` suggestion menu open, so Enter still picks a suggestion and confirms dialogs. The app has no setting for this (its `keybindings.json` support is for the terminal version only).

### Microsoft Teams

| Keys | Action |
|------|--------|
| Alt + Shift + F | Search (Alt + E stays File Explorer) |
| Alt + Enter | Send message, with Teams' Settings > Chats and channels > "When writing a message, press Enter to" set to "Start a new line" |

### VS Code

| Keys | Action |
|------|--------|
| Win + Up / Down | Move line up / down |
| Win + Shift + Up / Down | Copy line up / down |
| Win + Click | Add a cursor |

### Left to PowerToys

| Keys | PowerToys module |
|------|------------------|
| Alt + Space | Command Palette (Spotlight) |
| Alt + \` / Alt + Shift + \` | Alt Window Cycle (switch between windows of the same app) |

PowerToys Keyboard Manager is turned off: all remapping lives in `MacKeys.ahk`.

## Terminal commands

`Unix.ps1` makes Mac/Linux commands work in PowerShell 7.

| Commands | Where they come from |
|----------|----------------------|
| `grep` `head` `tail` `wc` `less` `sed` `awk` `cut` `tr` `uniq` `xargs` `column` `find` `diff` `touch` `du` `df` `file` `basename` `dirname` `realpath` `unzip` `gzip` `md5sum` `sha256sum` `base64` `env` `date` | GNU versions from Git for Windows, with all their flags (`tail -f`, `grep -r`, `find . -name`). `find` and `diff` replace Windows' `find.exe` and PowerShell's `Compare-Object` alias. |
| `rm` `ls` `kill` | PowerShell's versions, which also take `rm -rf`, `ls -la` / `-lt` / `-lS` / `-r`, `kill -9`. PowerShell parameters (`-Recurse`, `-Filter`) still work. `pkill <name>` stops processes by name. |
| `open` | Opens a file in its default app, a folder in Explorer, or a URL. `open` alone opens the current folder. |
| `pbcopy` / `pbpaste` | `... \| pbcopy` copies to the clipboard; `pbpaste` prints it. |
| `export NAME=value` / `unset NAME` | Set or remove an environment variable for this session. |
| `which [-a]` | Path of a program, or what an alias or function is. |
| `watch [-n 2] <command>` | Re-runs a command every n seconds until Ctrl + C. |
| `ln [-sf] target [link]` | Hard link, or symbolic link with `-s`. Symbolic links to files need Developer Mode or an Administrator shell; to folders, `ln -s` makes a junction instead. |
| `jq` `rg` `fd` `make` `kubectl` | Installed with winget (see Setup). |
| `wget` | GNU `wget2` (winget's `wget` package fails its checksum check). |
| `btop` / `top` / `htop` | `btop4win`. |

PowerShell quirks to remember with these tools:

- Quote commas and braces: `cut -d ',' -f1`, `awk '{ print $1 }'`.
- Text piped from PowerShell into them ends in Windows line endings (`'hi' | base64` encodes `hi\r\n`).

## Setup on a new machine

1. Install the tools:

   ```powershell
   winget install AutoHotkey.AutoHotkey Microsoft.PowerShell Microsoft.WindowsTerminal Git.Git JanDeDobbeleer.OhMyPosh ajeetdsouza.zoxide junegunn.fzf
   winget install jqlang.jq BurntSushi.ripgrep.MSVC sharkdp.fd ezwinports.make GNU.Wget2 Kubernetes.kubectl aristocratos.btop4win
   oh-my-posh font install meslo
   ```

   Then, in PowerShell 7:

   ```powershell
   Install-PSResource posh-git, Terminal-Icons, PSFzf
   ```

2. Clone this repo to `%USERPROFILE%\AutoHotkey`:

   ```powershell
   git clone https://github.com/karanshah229/mac-keybindings-windows "$HOME\AutoHotkey"
   ```

3. Start `MacKeys.ahk` at login. The UIA build of AutoHotkey also works in windows running as administrator:

   ```powershell
   $s = (New-Object -ComObject WScript.Shell).CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\MacKeys.lnk")
   $s.TargetPath = "C:\Program Files\AutoHotkey\v2\AutoHotkey64_UIA.exe"
   $s.Arguments = "`"$HOME\AutoHotkey\MacKeys.ahk`""
   $s.Save()
   Invoke-Item $s.FullName
   ```

4. Load the shell setup from your PowerShell profiles (open each with `notepad $PROFILE`):

   - PowerShell 7: `. "$HOME\AutoHotkey\Shell.ps1"`
   - Windows PowerShell 5.1 (optional, keys only): `. "$HOME\AutoHotkey\MacKeys.ps1"`

5. Windows Terminal: copy the relevant parts of `windows-terminal/settings.json` into your own settings (Ctrl + Shift + , opens the file). The important parts are the PowerShell 7 default profile and `"font": { "face": "MesloLGM Nerd Font" }`.

6. In PowerToys, turn off Keyboard Manager, and set Command Palette to Alt + Space.

7. If you use [Ditto](https://github.com/sabrogden/Ditto) (`winget install Ditto.Ditto`), clear its own shortcut in Options > Keyboard Shortcuts. Its default, Ctrl + Shift + C, is what Alt + C sends to copy in Windows Terminal. Alt + Shift + C opens Ditto instead.

## Notes

- Hotkeys are matched in file order: app-specific rules first, then global rules, then the generic "Cmd = Ctrl" rule. To override a shortcut for one app, add it to the app-specific section at the top of `MacKeys.ahk`.
- Windows Terminal drops its text selection on any key press, including the invisible key AutoHotkey uses to stop Alt from opening menus. Terminal hotkeys therefore use `TermSend`, which skips that key.
- Alt + K in the terminal sends Ctrl + F12. `MacKeys.ps1` binds that key to clear the screen and scrollback and redraw the prompt at the top, keeping whatever you had typed, like Cmd + K in iTerm.
- `Aliases.ps1` removes the built-in PowerShell aliases `gc`, `gcb`, `gcm`, `gl`, `gm` and `gp` so the git names work. The full cmdlet names (`Get-Content`, ...) still work.
