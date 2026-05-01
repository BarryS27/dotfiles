########################################
# Listing — eza when available, ls fallback
########################################
if command -v eza &>/dev/null; then
    alias ls='eza --group-directories-first --icons=auto'
    alias ll='eza -lah --git --group-directories-first --icons=auto'
    alias la='eza -a --group-directories-first --icons=auto'
    alias lt='eza --tree --level=3 --git-ignore --icons=auto'
    alias llt='eza --tree --level=3 --git-ignore -l --icons=auto'
else
    alias ls='ls --color=auto'
    alias ll='ls -alF'
    alias la='ls -A'
fi

########################################
# File reading — bat when available
########################################
if command -v bat &>/dev/null; then
    alias cat='bat --style=plain --paging=never'
    alias less='bat --paging=always'
fi

########################################
# Search — ripgrep
########################################
alias grep='grep --color=auto'
if command -v rg &>/dev/null; then
    alias rg='rg --smart-case'
fi

########################################
# Navigation
########################################
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'
alias dotfiles='cd "$DOTFILES"'

########################################
# Git
########################################
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add .'
alias gp='git push'
alias gpl='git pull --rebase'
alias gf='git fetch --prune'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git lg -20'
alias gla='git lga -20'
alias gsw='git switch'
alias gbr='git branch'
alias grst='git restore'
alias gcp='git cherry-pick'
alias gwip='git add -A && git commit -m "wip"'

########################################
# Node / npm
########################################
alias nr='npm run'
alias ni='npm install'
alias nid='npm install --save-dev'
alias nrd='npm run dev'
alias nrb='npm run build'
alias nrt='npm run test'
alias nrp='npm run preview'

########################################
# Python
########################################
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv .venv && source .venv/bin/activate'
alias activate='source .venv/bin/activate'

########################################
# Misc utilities
########################################
alias j='z'                             # zoxide short alias
alias serve='python3 -m http.server'   # quick local server
alias reload='exec zsh'                # reload shell
alias path='print -l $path'            # one entry per line
alias myip='curl -s ifconfig.me'
alias ports='lsof -i -P -n | grep LISTEN'

########################################
# Safety
########################################
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
