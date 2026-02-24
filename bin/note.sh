#!/usr/bin/env bash

DEFAULT_DIR="$HOME/Me.archive"

if [ -z "$1" ]; then
    echo "Usage: note <search_term> [optional_subfolder]"
    echo "Example 1 (Search all): note 'elasticity'"
    echo "Example 2 (Search specific folder): note 'monopoly' ap-microecon"
    exit 1
fi

SEARCH_TERM="$1"

if [ -n "$2" ]; then
    SEARCH_DIR="$DEFAULT_DIR/$2"
else
    SEARCH_DIR="$DEFAULT_DIR"
fi

if [ ! -d "$SEARCH_DIR" ]; then
    echo "❌ Error: Directory not found -> $SEARCH_DIR"
    exit 1
fi

echo "🔍 Searching for '$SEARCH_TERM' in $SEARCH_DIR..."
echo "---------------------------------------------------"

RESULTS=$(grep -rnw "$SEARCH_DIR" -e "$SEARCH_TERM" --include="*.md" --color=always)

if [ -z "$RESULTS" ]; then
    echo "❌ No relevant notes found."
    exit 0
fi

echo "$RESULTS"
echo "---------------------------------------------------"

echo "💡 Copy and paste a file path from above and press Enter to open in VS Code (Press Enter alone to exit):"
read -r FILE_TO_OPEN

if [ -n "$FILE_TO_OPEN" ]; then
    CLEAN_PATH=$(echo "$FILE_TO_OPEN" | awk -F':' '{print $1}' | sed -E 's/\x1B\[[0-9;]*[a-zA-Z]//g')
    
    if [ -f "$CLEAN_PATH" ]; then
        code "$CLEAN_PATH"
        echo "✅ Opened in VS Code: $CLEAN_PATH"
    else
        echo "❌ Unrecognized file path: $CLEAN_PATH"
    fi
fi