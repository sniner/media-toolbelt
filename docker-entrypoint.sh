#!/usr/bin/bash
set -e

# If no arguments are given, display README
if [ $# -eq 0 ]; then
    if [ -f /app/README.md ]; then
        glow /app/README.md
    else
        echo "No README available"
    fi
    exit 0
fi

exec "$@"
