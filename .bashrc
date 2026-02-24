########################################
# 0. Interactive Shell Guard
########################################
[[ $- != *i* ]] && return


########################################
# 1. History & Behavior
########################################
shopt -s checkwinsize
shopt -s histappend

HISTCONTROL=ignoredups:ignorespace
HISTSIZE=5000
HISTFILESIZE=10000

export PROMPT_COMMAND="history -a; history -c; history -r"


########################################
# 2. Color System (256-safe)
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

    p_blue="\001$blue\002"
    p_cyan="\001$cyan\002"
    p_green="\001$green\002"
    p_orange="\001$orange\002"
    p_purple="\001$purple\002"
    p_violet="\001$violet\002"
    p_reset="\001$reset\002"

else
    p_blue="" p_reset="" p_purple="" p_violet=""
fi


########################################
# 3. Fast Git Prompt (Optimized)
########################################
__git_prompt() {

    git rev-parse --is-inside-work-tree &>/dev/null || return

    local branch status=""

    branch=$(git branch --show-current 2>/dev/null ||
             git rev-parse --short HEAD 2>/dev/null)

    git diff --cached --quiet        || status+="+"
    git diff-files --quiet          || status+="!"
    [[ -n $(git ls-files --others --exclude-standard) ]] && status+="?"
    git rev-parse --verify refs/stash &>/dev/null && status+="$"

    [[ -n $status ]] && status=" [$status]"

    echo " ${p_violet}on ${p_purple}${branch}${p_blue}${status}${p_reset}"
}


########################################
# 4. Prompt System
########################################
__exit_status() {
    local s=$?
    (( s != 0 )) && echo " ${p_orange}✘${s}${p_reset}"
}

PS1='${p_blue}\W${p_reset}$(__git_prompt)$(__exit_status)\n\$ '


########################################
# 5. Safety Aliases
########################################
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias grep='grep --color=auto'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias ..='cd ..'


########################################
# 6. Power Functions
########################################

# Create + enter dir
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Safe Git Sync
save() {

    git rev-parse --is-inside-work-tree &>/dev/null || {
        echo "❌ Not a git repository"
        return 1
    }

    local target=${1:-.}
    local msg=${2:-"update $target"}
    local stashed=false

    echo "💾 Sync starting..."

    if [[ -n $(git status --porcelain) ]]; then
        echo "📦 Stashing..."
        git stash push -u -m "autosave-$(date +%F-%T)"
        stashed=true
    fi

    echo "📥 Pulling..."
    git pull --rebase || {
        echo "❌ Pull failed"
        return 1
    }

    if $stashed; then
        echo "📤 Restoring..."
        git stash apply || {
            echo "⚠️ Conflict. Stash kept."
            return 1
        }
        git stash drop
    fi

    git add "$target"

    if ! git diff-index --quiet HEAD --; then
        git commit -m "$msg" &&
        git push &&
        echo "✅ Done"
    else
        echo "ℹ️ Nothing to commit"
    fi
}


########################################
# 7. Performance Tweaks
########################################
export LESS='-R -F -X'
export EDITOR=vim

ulimit -n 8192 &>/dev/null


########################################
# 8. Bash Completion (Cross-platform)
########################################
for f in \
    /etc/bash_completion \
    /usr/local/etc/bash_completion \
    /opt/homebrew/etc/bash_completion
do
    [[ -f $f ]] && source "$f" && break
done


########################################
# 9. Platform Specific
########################################
case "$(uname -s)" in
  Darwin) export OS=mac ;;
  Linux)  export OS=linux ;;
esac

[[ $OS == mac && -f "$DOTFILES/install/macos.sh" ]] && source "$DOTFILES/install/macos.sh"

# 3. 针对 Codespaces (Linux) 的特殊调优（可选）
if [[ $OS == linux && -n "$CODESPACES" ]]; then
    export NODE_OPTIONS="--max-old-space-size=4096"
fi