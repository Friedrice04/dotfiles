#!/bin/bash

# Rofi Launcher Switcher - Interactive script to change launcher type and style
# Run this script to easily switch between different launcher configurations

CONFIG_FILE="$HOME/.config/rofi/launcher_config"
ROFI_DIR="$HOME/.config/rofi/launchers"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Source current configuration
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    LAUNCHER_TYPE="type-1"
    LAUNCHER_STYLE="style-1"
fi

echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}         Rofi Launcher Switcher         ${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo
echo -e "${GREEN}Current Configuration:${NC}"
echo -e "  Type:  ${YELLOW}$LAUNCHER_TYPE${NC}"
echo -e "  Style: ${YELLOW}$LAUNCHER_STYLE${NC}"
echo

# Function to update config file
update_config() {
    cat > "$CONFIG_FILE" << EOF
#!/bin/bash

# Rofi Launcher Switcher System
# Configuration file to store current launcher selection

# Current launcher configuration
LAUNCHER_TYPE="$1"
LAUNCHER_STYLE="$2"

# Available types and styles
AVAILABLE_TYPES=("type-1" "type-2" "type-3" "type-4" "type-5" "type-6" "type-7")

# Number of styles per type (adjust if needed)
declare -A STYLES_PER_TYPE=(
    ["type-1"]="15"
    ["type-2"]="15" 
    ["type-3"]="10"
    ["type-4"]="10"
    ["type-5"]="5"
    ["type-6"]="10"
    ["type-7"]="10"
)
EOF
}

# Function to get available styles for a type
get_available_styles() {
    local type_dir="$ROFI_DIR/$1"
    if [[ -d "$type_dir" ]]; then
        find "$type_dir" -name "style-*.rasi" -type f | sort -V | while read -r file; do
            basename "$file" .rasi
        done
    fi
}

# Function to preview a launcher (optional)
preview_launcher() {
    local type="$1"
    local style="$2"
    echo -e "${BLUE}Preview: $type/$style${NC}"
    echo "  Path: $ROFI_DIR/$type/$style.rasi"
    
    if [[ -f "$ROFI_DIR/$type/$style.rasi" ]]; then
        echo -e "  ${GREEN}✓ Available${NC}"
    else
        echo -e "  ${RED}✗ Not found${NC}"
    fi
}

# Main menu
while true; do
    echo -e "${YELLOW}Choose an option:${NC}"
    echo "1) Change launcher type"
    echo "2) Change launcher style (current type: $LAUNCHER_TYPE)"
    echo "3) Preview current selection"
    echo "4) Test current launcher"
    echo "5) Show all available combinations"
    echo "6) Exit"
    echo
    read -p "Enter your choice (1-6): " choice

    case $choice in
        1)
            echo
            echo -e "${YELLOW}Available launcher types:${NC}"
            for i in "${!AVAILABLE_TYPES[@]}"; do
                type="${AVAILABLE_TYPES[$i]}"
                echo "  $((i+1))) $type"
            done
            echo
            read -p "Select type (1-${#AVAILABLE_TYPES[@]}): " type_choice
            
            if [[ "$type_choice" -ge 1 && "$type_choice" -le "${#AVAILABLE_TYPES[@]}" ]]; then
                NEW_TYPE="${AVAILABLE_TYPES[$((type_choice-1))]}"
                
                # Get first available style for this type
                FIRST_STYLE=$(get_available_styles "$NEW_TYPE" | head -n 1)
                if [[ -n "$FIRST_STYLE" ]]; then
                    update_config "$NEW_TYPE" "$FIRST_STYLE"
                    LAUNCHER_TYPE="$NEW_TYPE"
                    LAUNCHER_STYLE="$FIRST_STYLE"
                    echo -e "${GREEN}✓ Updated to: $LAUNCHER_TYPE/$LAUNCHER_STYLE${NC}"
                else
                    echo -e "${RED}✗ No styles found for $NEW_TYPE${NC}"
                fi
            else
                echo -e "${RED}Invalid choice!${NC}"
            fi
            echo
            ;;
            
        2)
            echo
            echo -e "${YELLOW}Available styles for $LAUNCHER_TYPE:${NC}"
            mapfile -t styles < <(get_available_styles "$LAUNCHER_TYPE")
            
            if [[ ${#styles[@]} -eq 0 ]]; then
                echo -e "${RED}No styles found for $LAUNCHER_TYPE${NC}"
                echo
                continue
            fi
            
            for i in "${!styles[@]}"; do
                echo "  $((i+1))) ${styles[$i]}"
            done
            echo
            read -p "Select style (1-${#styles[@]}): " style_choice
            
            if [[ "$style_choice" -ge 1 && "$style_choice" -le "${#styles[@]}" ]]; then
                NEW_STYLE="${styles[$((style_choice-1))]}"
                update_config "$LAUNCHER_TYPE" "$NEW_STYLE"
                LAUNCHER_STYLE="$NEW_STYLE"
                echo -e "${GREEN}✓ Updated style to: $LAUNCHER_STYLE${NC}"
            else
                echo -e "${RED}Invalid choice!${NC}"
            fi
            echo
            ;;
            
        3)
            echo
            preview_launcher "$LAUNCHER_TYPE" "$LAUNCHER_STYLE"
            echo
            ;;
            
        4)
            echo
            echo -e "${BLUE}Testing launcher: $LAUNCHER_TYPE/$LAUNCHER_STYLE${NC}"
            if [[ -f "$HOME/.config/rofi/rofi_launcher.sh" ]]; then
                "$HOME/.config/rofi/rofi_launcher.sh"
            else
                echo -e "${RED}Main launcher script not found!${NC}"
            fi
            echo
            ;;
            
        5)
            echo
            echo -e "${YELLOW}All available launcher combinations:${NC}"
            for type in "${AVAILABLE_TYPES[@]}"; do
                echo -e "${BLUE}$type:${NC}"
                mapfile -t styles < <(get_available_styles "$type")
                for style in "${styles[@]}"; do
                    if [[ "$type" == "$LAUNCHER_TYPE" && "$style" == "$LAUNCHER_STYLE" ]]; then
                        echo -e "  ${GREEN}● $style (current)${NC}"
                    else
                        echo -e "    $style"
                    fi
                done
                echo
            done
            ;;
            
        6)
            echo -e "${BLUE}Goodbye!${NC}"
            exit 0
            ;;
            
        *)
            echo -e "${RED}Invalid option! Please choose 1-6.${NC}"
            echo
            ;;
    esac
done