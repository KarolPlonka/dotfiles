function tui_file_picker() {
    local chosen_file_file=$(mktemp -u /tmp/nvim_selected_file_XXXXXX)
    local start_dir=$(pwd)
    
    local vim_script="
        function! SelectFile()
            let l:path = expand('%:p')
            if filereadable(l:path) && &filetype != 'netrw'
                let l:rel_path = fnamemodify(l:path, ':.')
                execute 'silent !echo ' . shellescape(l:rel_path) . ' > ${chosen_file_file}'
                qa!
            endif
        endfunction
        autocmd BufEnter * call SelectFile()
        autocmd FileType netrw autocmd BufEnter <buffer> call SelectFile()
    "
    
    if [ -n "$TMUX" ]; then
        local pane_close_signal_file=$(mktemp -u /tmp/nvim_pane_result_XXXXXX)
        
        tmux split-window -v "
            cd '$start_dir'
            nvim -c $(printf '%q' "$vim_script") .
            echo 'done' > ${pane_close_signal_file}
        "
        
        while [ ! -f "$pane_close_signal_file" ]; do
            sleep 0.1
        done

        rm -f "$pane_close_signal_file"
    else
        local saved_tty=$(stty -g)
        
        nvim -c "${vim_script}" . </dev/tty >/dev/tty 2>&1
        
        stty "$saved_tty"
    fi
    
    if [ -f "$chosen_file_file" ]; then
        local selected_file=$(cat "$chosen_file_file")
        rm -f "$chosen_file_file"
        
        READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}${selected_file}${READLINE_LINE:$READLINE_POINT}"
        READLINE_POINT=$((READLINE_POINT + ${#selected_file}))
    fi
}

# Bind to Ctrl+Alt+F
bind -x '"\e\C-f": tui_file_picker'
