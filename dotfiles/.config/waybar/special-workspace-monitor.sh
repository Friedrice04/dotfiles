#!/usr/bin/env bash

# Special workspace monitor for waybar using socat
# Usage: special-workspace-monitor.sh <workspace_name>

WORKSPACE_NAME="$1"

if [ -z "$WORKSPACE_NAME" ]; then
    echo "Usage: $0 <workspace_name>" >&2
    exit 1
fi

# Get Hyprland socket path
SOCKET_PATH="$XDG_RUNTIME_DIR/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"
if [ ! -S "$SOCKET_PATH" ]; then
    SOCKET_PATH="/tmp/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/socket2.sock"
fi

# Function to check if special workspace is currently active
check_active_workspace() {
    local active_workspace
    active_workspace=$(hyprctl activeworkspace -j | jq -r '.name')
    if [[ "$active_workspace" == "special:$WORKSPACE_NAME" ]]; then
        echo "true"
    else
        echo "false"
    fi
}

# Function to output waybar JSON
output_status() {
    local is_active="$1"
    local class="inactive"
    local icon=""
    
    if [[ "$is_active" == "true" ]]; then
        class="active"
        case "$WORKSPACE_NAME" in
            "social") icon="󰭹" ;;
            "music") icon="󰎈" ;;
            *) icon="󰖲" ;;
        esac
    else
        case "$WORKSPACE_NAME" in
            "social") icon="󰭹" ;;
            "music") icon="󰎆" ;;
            *) icon="󰖲" ;;
        esac
    fi
    
    cat << EOF
{"text":"$icon","class":"$class","tooltip":"Special workspace: $WORKSPACE_NAME"}
EOF
}

# Get initial state
ACTIVE=$(check_active_workspace)
output_status "$ACTIVE"

# Monitor socket2 for events
socat -u "UNIX-CONNECT:$SOCKET_PATH" - | while IFS= read -r event; do
    case "$event" in
        workspace\>\>special:$WORKSPACE_NAME)
            # Special workspace became active
            output_status "true"
            ;;
        workspace\>\>*)
            # Any other workspace became active (special workspace is no longer active)
            if [[ "$ACTIVE" == "true" ]]; then
                output_status "false"
                ACTIVE="false"
            fi
            ;;
        destroyworkspace\>\>special:$WORKSPACE_NAME)
            # Special workspace was destroyed
            output_status "false"
            ACTIVE="false"
            ;;
    esac
done