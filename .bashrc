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

export PROMPT_COMMAND="history -a; history -n"


########################################
# 2. Color System (256-safe)
########################################
if tput setaf 1 &>/dev/null && [ "$(tput colors)" -ge 256 ]; then

    reset=$(tput sgr0)

    blue=$(tput setaf 33)
    orange=$(tput setaf 166)
    purple=$(tput setaf 125)
    violet=$(tput setaf 61)

    p_blue="\001$blue\002"
    p_orange="\001$orange\002"
    p_purple="\001$purple\002"
    p_violet="\001$violet\002"
    p_reset="\001$reset\002"

else
    p_blue="" p_reset="" p_purple="" p_violet="" p_orange=""
fi


########################################
# 3. Fast Git Prompt
########################################
__git_prompt() {
    GIT_PS1=""
    git rev-parse --is-inside-work-tree &>/dev/null || return

    local branch status=""
    branch=$(git branch --show-current 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)

    git diff --cached --quiet        || status+="+"
    git diff-files --quiet           || status+="!"
    [[ -n $(git ls-files --others --exclude-standard) ]] && status+="?"
    git rev-parse --verify refs/stash &>/dev/null && status+='$'

    [[ -n $status ]] && status=" [$status]"
    GIT_PS1=" ${p_violet}on ${p_purple}${branch}${p_blue}${status}${p_reset}"
}


########################################
# 4. Prompt System
########################################
__build_prompt() {
    local s=$?

    EXIT_PS1=""
    (( s != 0 )) && EXIT_PS1=" ${p_orange}✘${s}${p_reset}"

    __git_prompt
}

PROMPT_COMMAND="__build_prompt; $PROMPT_COMMAND"

PS1='${p_blue}\W${p_reset}${GIT_PS1}${EXIT_PS1}\n\$ '


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
    [[ -z "$1" ]] && { echo "usage: mkcd <dir>" >&2; return 1; }
    mkdir -p "$1" && cd "$1"
}

# Safe Git Sync — pull + add + commit [+ push]
# Usage: save [path] ["message"] [--push]
save() {
    git rev-parse --is-inside-work-tree &>/dev/null || {
        echo "❌ Not a git repository." >&2; return 1
    }

    local target="." msg="Update $(date +%F)" do_push=false

    for arg in "$@"; do
        case "$arg" in
            --push) do_push=true ;;
            *)
                if   [[ "$target" == "."        ]]; then target="$arg"
                elif [[ "$msg"    == "Update "* ]]; then msg="$arg"
                fi
                ;;
        esac
    done

    echo "📥 Pulling upstream changes..."
    git pull --rebase --autostash || { echo "❌ Pull failed." >&2; return 1; }

    git add "$target"

    if git diff-index --quiet HEAD --; then
        echo "ℹ️  Nothing to commit."
        $do_push && git push
        return 0
    fi

    git commit -m "$msg" && echo "✅ Committed: $msg"

    if $do_push; then
        git push && echo "🚀 Pushed."
    else
        echo "ℹ️  Run 'git push' or 'save --push' to upload."
    fi
}


########################################
# 7. Performance Tweaks
########################################
export LESS='-R -F -X'
# EDITOR is intentionally vim here — bash is used in Codespaces/Linux
# where Zed may not be available.
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

if [[ $OS == linux && -n "$CODESPACES" ]]; then
    export NODE_OPTIONS="--max-old-space-size=4096"
fi
