activate_nearest_venv() {
    # Return early if already in a virtual environment
    if [[ -n "$VIRTUAL_ENV" && "$PWD"/ == "$VIRTUAL_ENV"/* ]]; then
        return
    fi

    # Deactivate if in a VENV but not under it anymore
    if [[ -n "$VIRTUAL_ENV" && "$PWD"/ != "$VIRTUAL_ENV"/* ]]; then
        deactivate
    fi

    local dir="$PWD"
    local venv_names=(".venv" "venv" "env")

    while [[ "$dir" != "/" ]]; do
        for venv_dir in "${venv_names[@]}"; do
            if [[ -x "$dir/$venv_dir/bin/activate" ]]; then
                source "$dir/$venv_dir/bin/activate"
                setup_ps1 2>/dev/null || true
                return
            fi
        done
        dir="$(dirname "$dir")"
    done
}

function cd() {
    builtin cd "$@" || return
    activate_nearest_venv
}

function pip() {
    activate_nearest_venv
    command pip "$@"
}

function uv() {
    activate_nearest_venv
    command uv "$@"
}

