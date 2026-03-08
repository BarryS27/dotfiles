########################################
# 0. Interactive Shell Guard
########################################
[[ -o interactive ]] || return

########################################
# 1. History & Behavior
########################################
setopt checkwinsize
setopt appendhistory

HISTCONTROL=ignoredups:ignorespace
HISTSIZE=5000
HISTFILESIZE=10000

########################################
# 2. Aliases & Local Overrides
########################################
[[ -f "$HOME/aliases.zsh" ]] && source "$HOME/aliases.zsh"
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

########################################
# 3. Color System (256-safe)
########################################
if tput setaf 1 &>/dev/null && [ "$(tput colors)" -ge 256 ]; then
    reset=$(tput sgr0)
    bold=$(tput bold)

    blue=$(tput setaf 33)
    cyan=$(tput setaf 37)
    green=$(tput setaf 64)
    orange=$(tput setaf 166)
    purple=$(tput setaf 125)
    violet=$(tput setaf 61)

    p_blue="%{$blue%}"
    p_cyan="%{$cyan%}"
    p_green="%{$green%}"
    p_orange="%{$orange%}"
    p_purple="%{$purple%}"
    p_violet="%{$violet%}"
    p_reset="%{$reset%}"
else
    p_blue="" p_reset="" p_purple="" p_violet=""
fi

########################################
# 4. Fast Git Prompt
########################################
__git_prompt() {
    GIT_PS1=""
    git rev-parse --is-inside-work-tree &>/dev/null || return

    local branch status=""
    branch=$(git branch --show-current 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)

    git diff --cached --quiet || status+="+"
    git diff-files --quiet || status+="!"
    [[ -n $(git ls-files --others --exclude-standard) ]] && status+="?"
    git rev-parse --verify refs/stash &>/dev/null && status+="$"

    [[ -n $status ]] && status=" [$status]"
    GIT_PS1=" ${p_violet}on ${p_purple}${branch}${p_blue}${status}${p_reset}"
}

########################################
# 5. Prompt System
########################################
__build_prompt() {
    local s=$?

    EXIT_PS1=""
    (( s != 0 )) && EXIT_PS1=" ${p_orange}✘${s}${p_reset}"

    __git_prompt
    PROMPT='${p_blue}%1~${p_reset}${GIT_PS1}${EXIT_PS1}\n$ '
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd __build_prompt

########################################
# 6. Power Functions
########################################
mkcd() {
    mkdir -p "$1" && cd "$1"
}

save() {
    git rev-parse --is-inside-work-tree &>/dev/null || {
        echo "❌ Error: Not a git repository."
        return 1
    }

    local target="."
    local msg="Auto-update"
    local do_push=false

    for arg in "$@"; do
        if [[ "$arg" == "--push" ]]; then
            do_push=true
        elif [[ "$target" == "." && "$arg" != -* ]]; then
            target="$arg"
        elif [[ "$msg" == "Auto-update" && "$arg" != -* ]]; then
            msg="$arg"
        fi
    done

    local stashed=false

    echo "💾 Syncing repository..."

    if [[ -n $(git status --porcelain) ]]; then
        echo "📦 Stashing current changes..."
        git stash push -u -m "autosave-$(date +%F-%T)"
        stashed=true
    fi

    echo "📥 Pulling remote changes (rebase)..."
    git pull --rebase || {
        echo "❌ Error: Pull failed. Please resolve manually."
        return 1
    }

    if $stashed; then
        echo "📤 Restoring stashed changes..."
        git stash apply || {
            echo "⚠️ Warning: Merge conflict detected. Stash retained for manual resolution."
            return 1
        }
        git stash drop
    fi

    git add "$target"

    if ! git diff-index --quiet HEAD --; then
        git commit -m "$msg"
        echo "✅ Changes committed locally."

        if $do_push; then
            echo "🚀 Pushing to remote repository..."
            git push && echo "✅ Push successful."
        else
            echo "ℹ️ Push skipped. Use 'git push' to upload, or run save with '--push'."
        fi
    else
        echo "ℹ️ No changes detected to commit."
    fi
}

########################################
# 7. Performance Tweaks
########################################
ulimit -n 8192 &>/dev/null

########################################
# 8. Completion (Cross-platform)
########################################
autoload -Uz compinit
compinit

########################################
# 9. Platform Specific
########################################
[[ $OS == mac && -f "$DOTFILES/install/macos.sh" ]] && source "$DOTFILES/install/macos.sh"
