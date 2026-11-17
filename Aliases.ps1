# Shorthand commands, oh-my-zsh style. Loaded from Shell.ps1.

# --- ls ------------------------------------------------------------------
Set-Alias -Name l -Value Get-ChildItem
function ll { ls @args }        # ls takes Unix flags (-t, -S ...), see Unix.ps1
function la { ls -a @args }     # include hidden files

# --- git (oh-my-zsh git plugin names, plus a few of my own) --------------
# Differences from oh-my-zsh: gcm is commit -m (checkout main is gcom), and
# gits is another git status. PowerShell names ignore case, so oh-my-zsh's
# gbD (force-delete a branch) is gbdf here.
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
function gbdf  { git branch -D @args }                     # force delete
function gc    { git commit --verbose @args }
function gca   { git commit --verbose --all @args }
function gcm   { git commit --message @args }              # gcm "message"
function gcmsg { git commit --message @args }
function gcam  { git commit --all --message @args }        # gcam "message"
function gcane { git commit --amend --no-edit @args }      # add staged changes to the last commit
function gcamend { git commit --amend @args }              # ... and edit its message
function gundo { git reset --soft HEAD~1 @args }           # undo last commit, keep changes staged
function gco   { git checkout @args }
function gcb   { git checkout -b @args }
function gcom  { git checkout (Get-GitMainBranch) @args }
function gcl   { git clone --recurse-submodules @args }
function gcp   { git cherry-pick @args }
function gclean { git clean -fd @args }                    # delete untracked files and folders
function gd    { git diff @args }
function gds   { git diff --staged @args }
function gf    { git fetch @args }
function gl    { git pull @args }
function gpr   { git pull --rebase @args }
function gp    { git push @args }
function gpf   { git push --force-with-lease @args }
function gpsup { git push --set-upstream origin (Get-GitCurrentBranch) @args }
function gm    { git merge @args }
function grb   { git rebase @args }
function grbi  { git rebase --interactive @args }
function gr    { git remote @args }
function grv   { git remote --verbose @args }
function grs   { git restore @args }
function grh   { git reset @args }                         # unstage everything
function grhh  { git reset --hard @args }                  # discard all uncommitted changes
function gs    { git status @args }
function gst   { git status @args }
function gits  { git status @args }
function gss   { git status --short @args }
function gsh   { git show @args }
function gsta  { git stash push @args }
function gstp  { git stash pop @args }
function gstl  { git stash list @args }
function gstd  { git stash drop @args }
function gsw   { git switch @args }
function gswc  { git switch --create @args }
function glo   { git log --oneline --decorate @args }
function glog  { git log --oneline --decorate --graph @args }
function glg   { git log --stat @args }
