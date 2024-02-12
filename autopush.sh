#!/bin/sh

# Detect OS and set stat flag
case "$(uname -s)" in
  Darwin*) stat_flag="-f %m" ;;
  Linux*)  stat_flag="-c %Y" ;;
  *)       echo "Unsupported OS: $(uname -s)" && exit 1 ;;
esac

# Variables
REPO_DIR="$HOME/code/triage"
TODO_FILE="$REPO_DIR/todo/noah.txt"
last_modif=$(stat $stat_flag "$TODO_FILE")

# Watch and update loop
while true; do
    sleep 2
    current_modif=$(stat $stat_flag "$TODO_FILE")
    if [ "$current_modif" != "$last_modif" ]; then
        last_modif=$current_modif
        cd "$REPO_DIR" && git add "$TODO_FILE" && git commit -m "Update todo list" && git pull && git push
    fi
done
