alias py=python3
alias python=python3
alias clip='xclip -selection clipboard'

mkdir -p ~/.bash_history

export HISTCONTROL=ignoredups

handle_in_tmux_history() {
    local tmp_history="/dev/shm/tmp_history.tmp"
    touch "$tmp_history"
    history -a "$tmp_history"
    if [ ! -s "$tmp_history" ]; then
        rm -f "$tmp_history"
        return
    fi
    cat "$tmp_history" >> $HISTFILE
    cat "$tmp_history" >> ~/.bash_history/all
    history -c
    history -r $HISTFILE
    rm -f "$tmp_history"
}

if [ -n "$TMUX" ]; then
    tmux_session=$(tmux display-message -p '#S')
    santized_tmux_session=$(echo -n $tmux_session | tr -c '[:alnum:]._-' '_')
    export HISTFILE=~/.bash_history/session.$santized_tmux_session
    export PROMPT_COMMAND="handle_in_tmux_history"
else
    export HISTFILE=~/.bash_history/all
    export PROMPT_COMMAND="history -a; history -c; history -r $HISTFILE"
fi

history() {
    if [ "$1" = "--all" ]; then
        cat ~/.bash_history/all
    else
        builtin history "$@"
    fi
}

set -o vi

export VISUAL=nvim
export EDITOR="$VISUAL"

set completion-query-items 200
set show-all-if-ambiguous on

set show-mode-in-prompt on
set vi-cmd-mode-string "\1\e[2 q\2"
set vi-ins-mode-string "\1\e[6 q\2"

if [ -f ~/.config/bash/prompt.sh ]; then
    source ~/.config/bash/prompt.sh
fi

for file in ~/.config/bash/tools/*; do
    [ -r "$file" ] && source "$file"
done

if [ -f ~/.env ]; then
  source ~/.env 
fi

alias vim='nvim'

if gh copilot --help &>/dev/null; then
    eval "$(gh copilot alias -- bash)"
fi

alias collama='~/snippets/collama.sh'

bind '"\C-p": history-search-backward'
bind '"\C-n": history-search-forward'

bind '"\C-a": end-of-line'
bind '"\C-o": beginning-of-line'

bind '"\C-j": menu-complete'
bind '"\C-k": menu-complete-backward'

bind '"\C-h": backward-word'
bind '"\C-l": forward-word'

