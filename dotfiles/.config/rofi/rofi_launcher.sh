#!/bin/bash

# Rofi Launcher - Main launcher script for hotkey
# This script reads the current launcher configuration and launches it
# Place this path in your Hyprland keybind: ~/.config/rofi/rofi_launcher.sh

CONFIG_FILE="$HOME/.config/rofi/launcher_config"
ROFI_DIR="$HOME/.config/rofi/launchers"

# Source the configuration
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    # Default fallback
    LAUNCHER_TYPE="type-1"
    LAUNCHER_STYLE="style-1"
fi

# Construct the launcher path
LAUNCHER_PATH="$ROFI_DIR/$LAUNCHER_TYPE"
LAUNCHER_SCRIPT="$LAUNCHER_PATH/launcher.sh"

# Check if the launcher exists
if [[ -f "$LAUNCHER_SCRIPT" ]]; then
    # Change to the launcher directory and run it
    cd "$LAUNCHER_PATH" || exit 1
    
    # Set the style before launching
    if [[ -f "$LAUNCHER_PATH/$LAUNCHER_STYLE.rasi" ]]; then
        # Create a temporary launcher script that uses the specific style
        TEMP_LAUNCHER="/tmp/rofi_launcher_temp.sh"
        
        # Read the original launcher and replace the theme variable
        sed "s/theme='style-[0-9]\+'/theme='$LAUNCHER_STYLE'/g" "$LAUNCHER_SCRIPT" > "$TEMP_LAUNCHER"
        chmod +x "$TEMP_LAUNCHER"
        
        # Run the temporary launcher
        "$TEMP_LAUNCHER"
        
        # Clean up
        rm -f "$TEMP_LAUNCHER"
    else
        # Fallback to default launcher
        "$LAUNCHER_SCRIPT"
    fi
else
    # Notify if launcher not found
    notify-send "Rofi Launcher" "Launcher not found: $LAUNCHER_TYPE/$LAUNCHER_STYLE" -u normal
    
    # Fallback to type-1 style-1
    cd "$ROFI_DIR/type-1" || exit 1
    ./launcher.sh
fi