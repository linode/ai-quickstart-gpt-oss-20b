#!/usr/bin/env bash

set -euo pipefail

#==============================================================================
# ask_selection - Interactive Selection Prompt
#
# Provides a reusable function for prompting users to select from options
# Compatible with bash 3.2+ (macOS default bash)
#
# Usage:
#   source ./script/ask_selection.sh
#   ask_selection PROMPT OPTIONS_ARRAY [DEFAULT_INDEX] INDEX_VAR VALUE_VAR
#
# Example:
#   options=("Option A" "Option B" "Option C")
#   ask_selection "Choose an option:" options 2 selected_idx selected_val
#   echo "You selected: $selected_idx - $selected_val"
#==============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

#==============================================================================
# ask_selection - Prompt user to select from array of options
#
# Parameters:
#   $1 - prompt_text: Question to display
#   $2 - options_array_name: Name of array variable containing options
#   $3 - default_index: Default selection (1-based, optional, use "" or 0 for no default)
#   $4 - index_var_name: Variable name to store selected index (1-based)
#   $5 - value_var_name: Variable name to store selected value
#   $6 - default_label: Custom label for default option (optional, default: "(default)")
#   $7 - bottom_spacing: Number of blank lines for bottom spacing (optional, default: 5)
#
# Returns:
#   0 on success, 1 on error
#
# Example:
#   options=("Red" "Green" "Blue")
#   ask_selection "Pick a color:" options 2 idx val
#   ask_selection "Pick a color:" options 2 idx val "[ Recommended ]"
#   ask_selection "Pick a color:" options 2 idx val "[ Recommended ]" 5
#   echo "Selected: $idx - $val"  # Output: Selected: 2 - Green
#==============================================================================
ask_selection() {
    local prompt_text="$1"
    local options_array_name="$2"
    local default_index="${3:-}"
    local index_var_name="$4"
    local value_var_name="$5"
    local default_label="${6:-(default)}"
    local bottom_spacing="${7:-5}"

    # Get array length using eval (compatible with bash 3.2+)
    local array_length
    eval "array_length=\${#${options_array_name}[@]}"

    # Validate that array is not empty
    if [ "$array_length" -eq 0 ]; then
        echo -e "${RED}Error: Options array is empty${NC}" >&2
        return 1
    fi

    # Validate default index
    if [ -n "$default_index" ] && [ "$default_index" != "0" ]; then
        if ! [[ "$default_index" =~ ^[0-9]+$ ]] || [ "$default_index" -lt 1 ] || [ "$default_index" -gt "$array_length" ]; then
            echo -e "${RED}Error: Invalid default index: $default_index (must be 1-${array_length})${NC}" >&2
            return 1
        fi
    else
        default_index=""
    fi

    # Display options
    echo "" >&2
    local i
    for i in $(seq 0 $((array_length - 1))); do
        local display_num=$((i + 1))
        local option
        eval "option=\"\${${options_array_name}[$i]}\""

        if [ -n "$default_index" ] && [ "$display_num" -eq "$default_index" ]; then
            echo -e "  ${CYAN}${display_num}.${NC} ${YELLOW}${option}${NC} ${default_label}" >&2
        else
            echo -e "  ${CYAN}${display_num}.${NC} ${option}" >&2
        fi
    done

    echo "" >&2

    # Add bottom spacing if requested (print blank lines then scroll up)
    if [ "$bottom_spacing" -gt 0 ]; then
        # Print N newlines to create space at bottom, then move cursor back up
        local j
        for j in $(seq 1 "$bottom_spacing"); do
            printf '\n' >&2
        done
        # Move cursor up N lines to position for the prompt
        printf '\033[%dA' "$bottom_spacing" >&2
    fi

    # Prompt for selection
    local selection
    while true; do
        if [ -n "$default_index" ]; then
            read -r -p "$(echo -e "${YELLOW}${prompt_text} [default: ${default_index}]:${NC}")" selection </dev/tty
        else
            read -r -p "$(echo -e "${YELLOW}${prompt_text}:${NC}")" selection </dev/tty
        fi

        # Use default if empty input and default is set
        if [ -z "$selection" ] && [ -n "$default_index" ]; then
            selection="$default_index"
        fi

        # Validate input is a number
        if ! [[ "$selection" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}Invalid input. Please enter a number between 1 and ${array_length}.${NC}" >&2
            continue
        fi

        # Validate input is in range
        if [ "$selection" -lt 1 ] || [ "$selection" -gt "$array_length" ]; then
            echo -e "${RED}Invalid selection. Please enter a number between 1 and ${array_length}.${NC}" >&2
            continue
        fi

        # Valid selection - break loop
        break
    done

    # Convert to 0-based index for array access
    local array_index=$((selection - 1))
    local selected_value
    eval "selected_value=\"\${${options_array_name}[$array_index]}\""

    # Store results in caller's variables using eval (compatible with bash 3.2+)
    eval "${index_var_name}='${selection}'"
    eval "${value_var_name}='${selected_value}'"

    return 0
}

# If script is run directly (not sourced), show usage
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    cat >&2 <<'EOF'
Usage: source this file and use the ask_selection function

Example:
    #!/usr/bin/env bash
    source ./script/ask_selection.sh

    options=("Option A" "Option B" "Option C")

    # Basic usage with default label
    ask_selection "Choose an option:" options 2 selected_idx selected_val

    # Custom default label (inline)
    ask_selection "Choose an option:" options 2 selected_idx selected_val "[ Recommended ]"

    # Custom default label with newline (multiline)
    ask_selection "Choose an option:" options 2 selected_idx selected_val $'\n     [ RECOMMENDED ]'

    # With bottom spacing (adds 5 blank lines at bottom)
    ask_selection "Choose an option:" options 2 selected_idx selected_val "(default)" 5

    echo "You selected index: $selected_idx"
    echo "You selected value: $selected_val"

Parameters:
    1. prompt_text         - Question to display
    2. options_array_name  - Name of array variable containing options
    3. default_index       - Default selection (1-based, optional)
    4. index_var_name      - Variable name to store selected index
    5. value_var_name      - Variable name to store selected value
    6. default_label       - Custom label for default (optional, default: "(default)")
    7. bottom_spacing      - Number of blank lines for spacing (optional, default: 5)
EOF
    exit 1
fi
