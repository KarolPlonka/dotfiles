SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd "$SCRIPT_DIR"

# Parse command-line arguments
SYM_LINK=false
for arg in "$@"
do
    if [ "$arg" == "--symlink" ]; then
        SYM_LINK=true
    else
        echo "Invalid argument: $arg"
        exit 1
    fi
done

new_links=0
echo "Creating links for config files..."
while read -r path; do
    # Determine relative path
    source_path="$SCRIPT_DIR/$path"
    target_path="$HOME/$path"
    if [ -d "$source_path" ]; then
        mkdir -p "$target_path"
    elif [ -f "$source_path" ]; then
        if [ -e "$target_path" ]; then
            echo "Target already exists: $target_path"
            continue
        elif [ "$SYM_LINK" = true ]; then
            ln -sv "$source_path" "$target_path"
            new_links=$((new_links + 1))
        else
            ln -sfv "$source_path" "$target_path"
            new_links=$((new_links + 1))
        fi
    fi
done < <(find ".config")
echo "Created $new_links new links."
