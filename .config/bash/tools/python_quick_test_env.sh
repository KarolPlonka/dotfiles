
function pyte {
    # CONSTANTS
    local venv_name=".venv"
    local file_name="test.py"

    local create_venv=false
    local session_name="PYTE__$(date +"%H-%M_%Y-%m-%d")"


    for arg in "$@"; do
        case "$arg" in
            -v|--venv)
                create_venv=true
                ;;
            *)
                session_name="$arg"
                ;;
        esac
    done

    if tmux has-session -t "$session_name" 2>/dev/null; then
        tmux switch -t "$session_name"
        return
    fi

    local path="/tmp/pyte/$session_name"

    mkdir -p "/tmp/pyte"
    mkdir -p "$path"

    if $create_venv; then
        python -m venv "$path/$venv_name"
    fi

    touch "$path/$file_name"


    tmux new-session -d -s "$session_name" -c "$path" 
    if $create_venv; then
        tmux send-keys -t "$session_name" "source $path/$venv_name/bin/activate" C-m
    fi
    tmux send-keys -t "$session_name" "tmux new-window -d" C-m
    tmux send-keys -t "$session_name:1" "source $path/$venv_name/bin/activate" C-m
    tmux send-keys -t "$session_name" "nvim $file_name" C-m
    tmux switch -t "$session_name"
}
