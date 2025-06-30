activate_nearest_venv() {
    # Deactivate the current virtual environment if necessary
    if [[ -n "$VIRTUAL_ENV" ]]; then
        # Check if the current directory is still part of the active VIRTUAL_ENV
        if [[ "$PWD"/ != "$VIRTUAL_ENV"/* ]]; then
            deactivate
            setup_ps1
            return
        fi
    fi

    # A list of possible virtual environment directory names
    declare -a venv_names=(".venv" "venv" "env")

    # Check each directory in the path to see if it contains a virtual environment
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        for venv_dir in "${venv_names[@]}"; do
            if [[ -d "$dir/$venv_dir" ]]; then
                source "$dir/$venv_dir/bin/activate"
                setup_ps1 
                return 
            fi
        done
        dir="$(dirname "$dir")" # Move up a directory
    done
}

function cd() {
    builtin cd "$@" || return
    activate_nearest_venv
}

function pip() {
    command pip "$@" || return
    activate_nearest_venv
}

function uv() {
    command uv "$@" || return
    activate_nearest_venv
}

# On shell startup
activate_nearest_venv   
