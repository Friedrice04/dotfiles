#!/bin/bash
# -----------------------------------------------------
# Clean nmtui Terminal Launcher
# Opens nmtui in a terminal with no color theming
# -----------------------------------------------------

# Get the terminal command from ML4W settings
TERMINAL=$(cat ~/.config/ml4w/settings/terminal.sh)

# Run nmtui in kitty with themed matugen config for better readability
kitty --config ~/.mydotfiles/dotfiles/.config/kitty/nmtui.conf --class dotfiles-floating -e nmtui