#!/usr/bin/env bash

# Special workspace monitor for waybar using socat
# Usage: special-workspace-monitor.sh <workspace_name>

# Configuration - Add/remove workspaces here
declare -A WORKSPACES=(
    ["social"]="󰭹"
    ["music"]="󰎈"
    ["scratchpad"]="󰖲"
)

WORKSPACE_NAME="$1"

if [ -z "$WORKSPACE_NAME" ]; then
    echo "Usage: $0 <workspace_name>" >&2
    echo "Available workspaces: ${!WORKSPACES[*]}" >&2
    exit 1
fi

# Check if workspace is configured
if [[ ! -v WORKSPACES["$WORKSPACE_NAME"] ]]; then
    echo "Error: Workspace '$WORKSPACE_NAME' not configured" >&2
    echo "Available workspaces: ${!WORKSPACES[*]}" >&2
    exit 1
fi

# Get Hyprland socket path
SOCKET_PATH="$XDG_RUNTIME_DIR/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"
if [ ! -S "$SOCKET_PATH" ]; then
    SOCKET_PATH="/tmp/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/socket2.sock"
fi

# Function to check if special workspace is currently active based on socket events
# Special workspaces are never returned by hyprctl activeworkspace, only detectable via socket
check_active_workspace() {
    # For initial state, assume special workspace is not active
    # This will be updated by socket events
    echo "false"
}

# Function to output waybar JSON
output_status() {
    local is_active="$1"
    local icon="${WORKSPACES[$WORKSPACE_NAME]}"
    local class=""
    
    # Set class to "active" when workspace is visible
    if [[ "$is_active" == "true" ]]; then
        class="active"
    fi
    
    cat << EOF
{"text":"$icon","class":"$class","tooltip":"Special workspace: $WORKSPACE_NAME"}
EOF
}

# Initialize state - special workspaces start as inactive
ACTIVE="false"
output_status "$ACTIVE"

# Monitor socket2 for events
socat -u UNIX-CONNECT:/run/user/$(id -u)/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while IFS= read -r event; do
    case "$event" in
        activespecial\>\>,*)
            # Special workspace is being hidden (format: activespecial>>,monitor)
            if [[ "$ACTIVE" == "true" ]]; then
                ACTIVE="false"
                output_status "$ACTIVE"
            fi
            ;;
        activespecial\>\>special:$WORKSPACE_NAME,*)
            # Our special workspace is being shown (format: activespecial>>special:workspace,monitor)
            ACTIVE="true"
            output_status "$ACTIVE"
            ;;
        activespecial\>\>special:*,*)
            # Another special workspace is being shown
            if [[ "$ACTIVE" == "true" ]]; then
                ACTIVE="false"
                output_status "$ACTIVE"
            fi
            ;;
        workspace\>\>*)
            # Regular workspace became active (special workspace is no longer active)
            if [[ "$ACTIVE" == "true" ]]; then
                ACTIVE="false"
                output_status "$ACTIVE"
            fi
            ;;
    esac
done
