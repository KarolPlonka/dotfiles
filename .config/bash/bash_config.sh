alias py=python3
alias python=python3
alias xclip='xclip -selection clipboard'

set -o vi

export VISUAL=nvim
export EDITOR="$VISUAL"

bind '"\C-p": history-search-backward'
bind '"\C-n": history-search-forward'

# bind '"\C-i": beginning-of-line'
# bind '"\C-a": end-of-line'

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

# alias ghcs='gh copilot suggest --no-prompt'
# alias ghcs='gh copilot suggest --shell-out -t shell'
eval "$(gh copilot alias -- bash)"

bind '"\C-a": end-of-line'


