#!/bin/bash

tmux start-server

if ! tmux has-session -t main 2>/dev/null; then
    tmux new-session -d -s main
fi

restore_script="$HOME/.config/tmux/plugins/tmux-resurrect/scripts/restore.sh"

if [ -f "$restore_script" ]; then
    tmux new-session -d -s temp_restore "$restore_script"
fi

tmux attach-session -t main



