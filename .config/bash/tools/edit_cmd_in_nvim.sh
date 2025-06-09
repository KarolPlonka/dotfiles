edit_command_in_nvim() {
    local tmpfile=$(mktemp)
    echo "$READLINE_LINE" > "$tmpfile"
    local cursor_pos=$READLINE_POINT

    nvim -c "set filetype=sh" -c "normal! ${cursor_pos}|" "$tmpfile"

    if [ -f "$tmpfile" ]; then
        READLINE_LINE=$(<"$tmpfile")
        READLINE_POINT=${#READLINE_LINE}
    fi

    rm "$tmpfile"
}

bind -x '"\C-e": edit_command_in_nvim'

