#!/usr/bin/env bash

SEARCH_DIR="$HOME/Me.archive"
grep -rnw "$SEARCH_DIR" -e "$1" --include="*.md" --color=always