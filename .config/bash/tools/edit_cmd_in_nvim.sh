edit_command_in_nvim() {
    local cmd_tmpfile=$(mktemp)
    echo "$READLINE_LINE" > "$cmd_tmpfile"
    local history_file=$(mktemp)

    if [ -n "$TMUX" ]; then
        tmux capture-pane -pS - > "$history_file"
    fi
    
    nvim -c "edit $cmd_tmpfile" \
         -c "set filetype=sh" \
         -c "split" \
         -c "view $history_file" \
         -c "$" \
         -c "wincmd j"
    
    if [ -f "$cmd_tmpfile" ]; then
        READLINE_LINE=$(<"$cmd_tmpfile")
        READLINE_POINT=${#READLINE_LINE}
    fi
    rm "$cmd_tmpfile"
}

bind -x '"\C-e": edit_command_in_nvim'
