########################################
# mkcd — create directory and enter it
########################################
mkcd() {
    [[ -z "$1" ]] && { echo "usage: mkcd <dir>" >&2; return 1; }
    mkdir -p "$1" && cd "$1"
}

########################################
# up [n] — cd up n levels (default 1)
########################################
up() {
    local n="${1:-1}" target=""
    for (( i=0; i<n; i++ )); do target="../$target"; done
    cd "${target:-.}" || return 1
}

########################################
# extract — universal archive extractor
########################################
extract() {
    if [[ ! -f "$1" ]]; then
        echo "❌ Not a file: $1" >&2; return 1
    fi
    case "$1" in
        *.tar.bz2|*.tbz2) tar xjf  "$1" ;;
        *.tar.gz|*.tgz)   tar xzf  "$1" ;;
        *.tar.xz)         tar xJf  "$1" ;;
        *.tar.zst)        tar --zstd -xf "$1" ;;
        *.tar)            tar xf   "$1" ;;
        *.gz)             gunzip   "$1" ;;
        *.bz2)            bunzip2  "$1" ;;
        *.xz)             unxz     "$1" ;;
        *.zip)            unzip    "$1" ;;
        *.7z)             7z x     "$1" ;;
        *.rar)            unrar x  "$1" ;;
        *) echo "❌ Unknown format: $1" >&2; return 1 ;;
    esac
}

########################################
# save — pull + add + commit [+ push]
# Usage: save [path] ["message"] [--push]
########################################
save() {
    git rev-parse --is-inside-work-tree &>/dev/null || {
        echo "❌ Not a git repository." >&2; return 1
    }

    local target="." msg="Update $(date +%F)" do_push=false

    for arg in "$@"; do
        case "$arg" in
            --push) do_push=true ;;
            *)
                if   [[ "$target" == "."         ]]; then target="$arg"
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
# note — search ~/Me.archive with fzf
# Usage: note [query]
########################################
note() {
    local base="${NOTE_DIR:-$HOME/Me.archive}"
    local query="${*:-}"

    if command -v fzf &>/dev/null; then
        local preview_cmd
        if command -v bat &>/dev/null; then
            preview_cmd='bat --style=numbers,header --color=always {}'
        else
            preview_cmd='head -60 {}'
        fi

        local file
        file=$(
            grep -rl --include="*.md" "${query}" "$base" 2>/dev/null \
            | fzf --query="$query" \
                  --prompt='note > ' \
                  --preview="$preview_cmd" \
                  --preview-window='right:60%:wrap' \
                  --bind='ctrl-/:toggle-preview'
        )
        [[ -n "$file" ]] && "$EDITOR" "$file"
    else
        # Fallback: plain grep
        grep -rn "${query}" "$base" --include="*.md" --color=always \
        | less -R
    fi
}

########################################
# gitroot — cd to repo root
########################################
gitroot() {
    local root
    root=$(git rev-parse --show-toplevel 2>/dev/null) || {
        echo "❌ Not inside a git repository." >&2; return 1
    }
    cd "$root"
}

########################################
# port [n] — show what is listening on a port
########################################
port() {
    lsof -nP -iTCP:"${1:-80}" | grep LISTEN
}

########################################
# json — pretty-print JSON from stdin or file
########################################
json() {
    if command -v jq &>/dev/null; then
        jq '.' "${1:--}"
    else
        python3 -m json.tool "${1:--}"
    fi
}

########################################
# envdiff — show env changes after sourcing a file
########################################
envdiff() {
    local before after
    before=$(env | sort)
    source "$1"
    after=$(env | sort)
    diff <(echo "$before") <(echo "$after")
}
