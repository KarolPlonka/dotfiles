
function pyte {
    # CONSTANTS
    local venv_name=".venv"
    local venv_args=""
    local file_name="test.py"

    local create_venv=false
    local session_name="PYTE__$(date +"%H-%M_%Y-%m-%d")"


    for arg in "$@"; do
        case "$arg" in
            -v|--venv)
                create_venv=true
                ;;
            --venv=*)
                create_venv=true
                venv_args="${arg#*=}"
                ;;
            -v=*)
                create_venv=true
                venv_args="${arg#*=}"
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

    echo "Creating session: $session_name"

    touch "$path/$file_name"

    tmux new-session -d -s "$session_name" -c "$path" \
        "$(if $create_venv; then
            echo "uv venv $venv_args && uv init --bare && source $path/$venv_name/bin/activate && "
        fi)tmux rename-window nvim && nvim $file_name"

    # Create the second window with venv activated
    tmux new-window -t "$session_name" -c "$path" \
        "$(if $create_venv; then echo "source $path/$venv_name/bin/activate; "; fi)exec $SHELL"

    tmux switch -t "$session_name" \; select-window -t nvim
}
