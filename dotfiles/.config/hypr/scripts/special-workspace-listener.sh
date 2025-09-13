#!/bin/bash
# A generic listener for any named special workspace in Hyprland.
# Usage: ./special-workspace-listener.sh <workspace_name> <icon>

# Check for required arguments
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <workspace_name> <icon>" >&2
    exit 1
fi

WORKSPACE_NAME=$1
ICON=$2

check_workspace() {
    if hyprctl monitors -j | jq -r '.[] | .specialWorkspace.name' | grep -q "^special:$WORKSPACE_NAME$"; then
        CLASS="active"
    else
        CLASS="inactive"
    fi
    echo "{\"text\": \"$ICON\", \"class\": \"$CLASS\"}"
}

# Initial check when Waybar starts
check_workspace

INSTANCE_SIGNATURE=$(hyprctl instances -j | jq -r '.[0].instance')
if [ -z "$INSTANCE_SIGNATURE" ]; then
    exit 1
fi

SOCKET_PATH="$XDG_RUNTIME_DIR/hypr/$INSTANCE_SIGNATURE/.socket2.sock"
if [ ! -S "$SOCKET_PATH" ]; then
    SOCKET_PATH="/tmp/hypr/$INSTANCE_SIGNATURE/.socket2.sock"
fi
if [ ! -S "$SOCKET_PATH" ]; then
    exit 1
fi

# Listen for the correct event
socat -u "UNIX-CONNECT:$SOCKET_PATH" - 2>/dev/null | while read -r event; do
    if [[ $event == "activespecial>>"* ]]; then
        # Add a small delay to prevent a race condition
        sleep 0.1
        check_workspace
    fi
done

