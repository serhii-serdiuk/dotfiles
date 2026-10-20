# devc <container> [command...]: run a command in a dev container, starting it if needed, or open
# a login shell there. Uses the host's shell; DEVC_ENGINE=podman for podman containers.
# Pass commands with &&, | or ; as one quoted argument: devc box 'cd src && make'
devc() {
    if [ $# -eq 0 ]; then
        echo "usage: devc <container> [command...]" >&2
        return 2
    fi
    local name=$1
    shift

    local engine=${DEVC_ENGINE:-docker}

    # The devcontainer CLI labels its containers with the workspace folder and definition, which
    # makes this work from any directory
    local folder=$("$engine" container inspect \
        -f '{{index .Config.Labels "devcontainer.local_folder"}}' "$name" 2> /dev/null)
    local config=$("$engine" container inspect \
        -f '{{index .Config.Labels "devcontainer.config_file"}}' "$name" 2> /dev/null)
    if [ -z "$folder" ]; then
        echo "devc: no dev container named $name; create it with devcontainer up first" >&2
        return 1
    fi
    if [ ! -f "$config" ]; then
        echo "devc: no dev container definition $config" >&2
        return 1
    fi

    local running=$("$engine" container inspect -f '{{.State.Running}}' "$name" 2> /dev/null)
    if [ "$running" != true ]; then
        echo "devc: starting $name..." >&2
        # Declared apart: "local output=$(...)" would make $? the status of local, not of up
        local output
        output=$(devcontainer up --docker-path "$engine" --workspace-folder "$folder" \
            --config "$config" 2>&1)
        if [ $? -ne 0 ]; then
            echo "$output" >&2
            return 1
        fi
    fi

    # -c takes one string: several arguments are quoted one by one so they arrive unchanged
    local container_command=
    if [ $# -eq 1 ]; then
        container_command=$1
    elif [ $# -gt 1 ]; then
        container_command=$(printf '%q ' "$@")
    fi

    # The host shell's name only: its path may differ in the container
    local shell=${SHELL##*/}
    local exec_shell=(devcontainer exec --docker-path "$engine" --workspace-folder "$folder"
        --config "$config" "$shell" -l)
    if [ -z "$container_command" ]; then
        "${exec_shell[@]}"
    else
        "${exec_shell[@]}" -c "$container_command"
    fi
}
