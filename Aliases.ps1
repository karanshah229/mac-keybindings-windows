# Shorthand commands, oh-my-zsh style. Loaded from Shell.ps1.

# --- ls ------------------------------------------------------------------
Set-Alias -Name l -Value Get-ChildItem
function ll { Get-ChildItem @args }
function la { Get-ChildItem -Force @args }   # include hidden files

# --- git (oh-my-zsh git plugin names) ------------------------------------
# These PowerShell built-in aliases clash with the git names, so they are
# removed: gc (Get-Content), gcb (Get-Clipboard), gcm (Get-Command),
# gl (Get-Location), gm (Get-Member), gp (Get-ItemProperty).
# The full cmdlet names still work.
foreach ($a in 'gc', 'gcb', 'gcm', 'gl', 'gm', 'gp') {
    Remove-Item "Alias:$a" -Force -ErrorAction SilentlyContinue
}

function Get-GitMainBranch {
    foreach ($b in 'main', 'trunk', 'master') {
        git show-ref --quiet --verify "refs/heads/$b"
        if ($LASTEXITCODE -eq 0) { return $b }
    }
    'main'
}
function Get-GitCurrentBranch { git branch --show-current }

function g     { git @args }
function ga    { git add @args }
function gaa   { git add --all @args }
function gb    { git branch @args }
function gba   { git branch --all @args }
function gbd   { git branch --delete @args }
function gc    { git commit --verbose @args }
function gca   { git commit --verbose --all @args }
function gcmsg { git commit --message @args }
function gco   { git checkout @args }
function gcb   { git checkout -b @args }
function gcm   { git checkout (Get-GitMainBranch) @args }
function gcl   { git clone --recurse-submodules @args }
function gcp   { git cherry-pick @args }
function gd    { git diff @args }
function gds   { git diff --staged @args }
function gf    { git fetch @args }
function gl    { git pull @args }
function gp    { git push @args }
function gpf   { git push --force-with-lease @args }
function gpsup { git push --set-upstream origin (Get-GitCurrentBranch) @args }
function gm    { git merge @args }
function grb   { git rebase @args }
function grbi  { git rebase --interactive @args }
function gr    { git remote @args }
function grv   { git remote --verbose @args }
function grs   { git restore @args }
function gs    { git status @args }
function gst   { git status @args }
function gss   { git status --short @args }
function gsta  { git stash push @args }
function gstp  { git stash pop @args }
function gstl  { git stash list @args }
function gsw   { git switch @args }
function gswc  { git switch --create @args }
function glo   { git log --oneline --decorate @args }
function glog  { git log --oneline --decorate --graph @args }
