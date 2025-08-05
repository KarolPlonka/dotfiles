#!/bin/bash
# Script that accepts named arguments: path and command
# Initialize variables
PATH_ARG=""
COMMAND_ARG=""
DIR_LENGTH_LIMIT=10
DIRS=3

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--path)
            PATH_ARG="$2"
            shift 2
            ;;
        -c|--command)
            COMMAND_ARG="$2"
            shift 2
            ;;
        -l|--dir-length)
            DIR_LENGTH_LIMIT="$2"
            shift 2
            ;;
        -n|--dirs)
            DIRS="$2"
            shift 2
            ;;
        *)
            echo "Error: Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Validate that both arguments are provided
if [ -z "$PATH_ARG" ]; then
    echo "Error: --path argument is required"
    usage
    exit 1
fi

if [ -z "$COMMAND_ARG" ]; then
    echo "Error: --command argument is required"
    usage
    exit 1
fi

# Function to truncate a directory name if it's too long
truncate_dir() {
    local dir="$1"
    local limit="$2"
    
    if [ ${#dir} -le $limit ]; then
        echo "$dir"
    else
        # Calculate how many chars to show on each side
        local side_chars=$(( limit / 2 ))  # -3 for "..."
        local left="${dir:0:$side_chars}"
        local right="${dir: -$side_chars}"
        echo "${left}…${right}"
    fi
}

# Function to format the path
format_path() {
    local path="$1"
    local formatted_path=""
    
    # Replace home directory with ~
    local home_dir="$HOME"
    if [[ "$path" == "$home_dir"* ]]; then
        path="~${path#$home_dir}"
    fi
    
    # Split path into components
    IFS='/' read -ra path_components <<< "$path"
    
    # Count total components (excluding empty ones)
    local total_components=0
    for component in "${path_components[@]}"; do
        if [ -n "$component" ] || [ "$component" = "~" ]; then
            ((total_components++))
        fi
    done
    
    if [ $total_components -gt $DIRS ]; then
        local shown_dirs=0
        local skip_start=$(( (total_components - DIRS) / 2 ))
        local skip_end=$(( skip_start + (total_components - DIRS) ))
        local i=0
        local added_ellipsis=false
        
        for component in "${path_components[@]}"; do
            if [ -n "$component" ] || [ "$component" = "~" ]; then
                if [ $i -lt $skip_start ] || [ $i -ge $skip_end ]; then
                    # Truncate the component if needed
                    local truncated=$(truncate_dir "$component" "$DIR_LENGTH_LIMIT")
                    
                    if [ -n "$formatted_path" ] && [ "$component" != "~" ]; then
                        formatted_path="${formatted_path}/${truncated}"
                    else
                        formatted_path="${formatted_path}${truncated}"
                    fi
                elif [ "$added_ellipsis" = false ]; then
                    if [ -n "$formatted_path" ]; then
                        formatted_path="${formatted_path}/…"
                    else
                        formatted_path="…"
                    fi
                    added_ellipsis=true
                fi
                ((i++))
            fi
        done
    else
        # Show all directories, but truncate each if needed
        for component in "${path_components[@]}"; do
            if [ -n "$component" ] || [ "$component" = "~" ]; then
                local truncated=$(truncate_dir "$component" "$DIR_LENGTH_LIMIT")
                
                if [ -n "$formatted_path" ] && [ "$component" != "~" ]; then
                    formatted_path="${formatted_path}/${truncated}"
                else
                    formatted_path="${formatted_path}${truncated}"
                fi
            fi
        done
    fi
    
    # Handle absolute paths that started with /
    if [[ "$path" == /* ]] && [[ "$formatted_path" != /* ]]; then
        formatted_path="/${formatted_path}"
    fi
    
    echo "$formatted_path"
}

# Format the path
formatted_path=$(format_path "$PATH_ARG")

# Output based on command
case "$COMMAND_ARG" in
    nvim|neovim|vim|nv|vi)
        echo "  $formatted_path"
        ;;
    bash)
        echo " $formatted_path"
        ;;
    *)
        echo " $COMMAND_ARG"
        ;;
esac
