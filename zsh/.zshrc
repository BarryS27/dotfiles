########################################
# 0. Interactive Shell Guard
########################################
[[ -o interactive ]] || return

########################################
# 1. History & Behavior
########################################
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt INC_APPEND_HISTORY

HISTSIZE=5000
SAVEHIST=10000
HISTFILE="${HISTFILE:-$HOME/.zsh_history}"

########################################
# 2. Aliases & Functions & Local Overrides
########################################
[[ -f "$HOME/aliases.zsh" ]]    && source "$HOME/aliases.zsh"
[[ -f "$HOME/functions.zsh" ]]  && source "$HOME/functions.zsh"
[[ -f "$HOME/fzf.zsh" ]]        && source "$HOME/fzf.zsh"
[[ -f "$HOME/.zshrc.local" ]]   && source "$HOME/.zshrc.local"

########################################
# 3. Color System (256-safe)
########################################
if tput setaf 1 &>/dev/null && [ "$(tput colors)" -ge 256 ]; then
    reset=$(tput sgr0)

    blue=$(tput setaf 33)
    orange=$(tput setaf 166)
    purple=$(tput setaf 125)
    violet=$(tput setaf 61)

    p_blue="%{$blue%}"
    p_orange="%{$orange%}"
    p_purple="%{$purple%}"
    p_violet="%{$violet%}"
    p_reset="%{$reset%}"
else
    p_blue="" p_reset="" p_purple="" p_violet="" p_orange=""
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
    git rev-parse --verify refs/stash &>/dev/null && status+='$'

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
    PROMPT="${p_blue}%1~${p_reset}${GIT_PS1}${EXIT_PS1}
$ "
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd __build_prompt

########################################
# 6. Performance Tweaks
########################################
ulimit -n 8192 &>/dev/null

########################################
# 7. Completion
########################################
autoload -Uz compinit
compinit

########################################
# 8. Key Bindings
########################################
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

########################################
# 9. Platform Specific
########################################
[[ $OS == mac && -f "$DOTFILES/install/macos.sh" ]] && source "$DOTFILES/install/macos.sh"
