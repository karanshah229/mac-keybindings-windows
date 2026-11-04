# PowerShell 7 setup: iTerm/zsh equivalents in Windows Terminal.
# Loaded from the PowerShell 7 $PROFILE with:  . "$HOME\AutoHotkey\Shell.ps1"
if ($Host.Name -ne 'ConsoleHost') { return }

# Mac line-editing keys (Ctrl+A/E/K/U/W) and Alt+K clear
. "$PSScriptRoot\MacKeys.ps1"

# ls and git shorthands (l, la, ll, gst, gco, ...)
. "$PSScriptRoot\Aliases.ps1"

# Mac/Linux commands: GNU tools (grep, tail, find ...), rm -rf / ls -la /
# kill -9, open, pbcopy, export, which, watch, ln
. "$PSScriptRoot\Unix.ps1"

# zsh-autosuggestions: grey suggestion from history, accept with Right / End.
# Syntax highlighting is built into PSReadLine.
try { Set-PSReadLineOption -PredictionSource History -PredictionViewStyle InlineView } catch {}   # fails when output is redirected
Set-PSReadLineOption -HistoryNoDuplicates

# zoxide: `z <part of a folder name>` jumps to frequent folders
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# Prompt: powerlevel10k-style. Running oh-my-posh just to get its one-line
# init command costs ~150 ms, so that line is cached and only re-made when an
# update removes the paths it points to. Each tab gets a fresh session id.
$ompTheme = 'powerlevel10k_lean'
$ompCache = "$env:LOCALAPPDATA\oh-my-posh-init-$ompTheme.txt"
$ompInit = if (Test-Path $ompCache) { Get-Content $ompCache -Raw }
$ompPaths = [regex]::Matches("$ompInit", "'([^']+)'") | ForEach-Object { $_.Groups[1].Value }
if (!$ompPaths -or ($ompPaths | Where-Object { !(Test-Path $_) })) {
    $ompInit = oh-my-posh init pwsh --config $ompTheme | Out-String
    Set-Content $ompCache $ompInit -NoNewline
}
($ompInit -replace '(?<=POSH_SESSION_ID = ")[^"]+', [guid]::NewGuid()) | Invoke-Expression

# Slower modules load once the first prompt is up and PowerShell is idle,
# so they don't delay opening a tab (~1 s saved).
#   posh-git        branch-aware git tab completion (leaves the prompt alone,
#                   since oh-my-posh has already replaced the default one)
#   Terminal-Icons  colored file and folder icons in ls / Get-ChildItem
#   PSFzf           Ctrl+R fuzzy history search, Ctrl+T fuzzy file picker
$null = Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
    Import-Module posh-git -Global
    Import-Module Terminal-Icons -Global
    Import-Module PSFzf -Global
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}
