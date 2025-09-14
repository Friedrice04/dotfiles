#!/bin/bash
# -----------------------------------------------------
# Dynamic Gitignore Generator for Matugen
# -----------------------------------------------------
# This script reads matugen config and generates gitignore patterns
# Run this whenever you add new matugen templates

MATUGEN_CONFIG="$HOME/.config/matugen/config.toml"
DOTFILES_DIR="$HOME/.mydotfiles"
GITIGNORE_FILE="$DOTFILES_DIR/.gitignore"

# Function to extract output paths from matugen config
generate_matugen_ignores() {
    if [[ -f "$MATUGEN_CONFIG" ]]; then
        echo "# Auto-generated matugen output paths"
        
        # Extract output_path lines and convert to gitignore format
        grep "output_path" "$MATUGEN_CONFIG" | \
        sed "s/output_path = '//" | \
        sed "s/'$//" | \
        sed "s|^~|$HOME|" | \
        sed "s|^$HOME|dotfiles|" | \
        while read -r path; do
            # Skip cache paths (already handled by cache patterns)
            if [[ ! "$path" =~ \.cache ]]; then
                echo "$path"
            fi
        done
        
        echo ""
    fi
}

# Function to update gitignore with dynamic content
update_gitignore() {
    local temp_file=$(mktemp)
    
    # Read existing gitignore until the dynamic section marker
    if [[ -f "$GITIGNORE_FILE" ]]; then
        sed '/# === DYNAMIC MATUGEN IGNORES ===/,$d' "$GITIGNORE_FILE" > "$temp_file"
    fi
    
    # Add dynamic section
    echo "# === DYNAMIC MATUGEN IGNORES ===" >> "$temp_file"
    echo "# Generated automatically from matugen config.toml" >> "$temp_file"
    generate_matugen_ignores >> "$temp_file"
    
    # Move temp file to gitignore
    mv "$temp_file" "$GITIGNORE_FILE"
    
    echo "✅ Updated .gitignore with current matugen outputs"
}

# Main execution
if [[ "$1" == "--update" ]] || [[ "$1" == "-u" ]]; then
    update_gitignore
else
    echo "Matugen Dynamic Gitignore Generator"
    echo "Usage: $0 --update|-u"
    echo ""
    echo "Current matugen outputs that would be ignored:"
    generate_matugen_ignores
fi