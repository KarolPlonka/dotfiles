#!/bin/env bash

function set_mode_options {
    status_bg_color="$1"
    icon="$2"

    tmux set-option prefix None
    tmux select-pane -d
    tmux set -g status-bg "${status_bg_color}"
    # tmux set status-right "${icon}  #[fg=colour0]"
    tmux refresh-client -S
}

function undo_mode_options {
    tmux set-option -u prefix
    tmux select-pane -e
    tmux set -g status-bg "black"
    # tmux set-option -u status-right
    tmux refresh-client -S
}

function main {
    case "$(tmux display-message -p '#{pane_mode}')" in
    copy-mode)
        set_mode_options 'colour96' ' COPYMODE'
        ;;
    *)
        undo_mode_options
        ;;
    esac
}

main
