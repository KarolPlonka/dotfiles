#!/usr/bin/env bash

current=$(tmux display-message -p '#I')
tmux list-windows -F '#I' \
  | awk -v c="$current" '$1 > c' \
  | sort -rn \
  | xargs -I {} tmux kill-window -t {}
