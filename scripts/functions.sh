#!/bin/bash

# load the clusters definition
cluster_definition_load()
    if [[ ! -f ../clusters.sh ]]; then
        echo "Error: clusters.sh not found!"
        exit 1
    fi

    source ../clusters.sh

#!/bin/bash

# Array of colors
colors=(
    "blue=\033[34m"
    "green=\033[32m"
    "red=\033[31m"
    "yellow=\033[33m"
    "orange=\033[38;5;214m" # Approximation for orange
)

# Function to print the color names programmatically
available_colors() {
    echo "Available colors:"
    for item in "${colors[@]}"; do
        # Extract the color name
        name="${item%%=*}"
        echo "- $name"
    done
}

# Function to print text in the specified color
# Example usage
# printc "This is a blue text" "blue"
# printc "This is a green text" "green"
# printc "This is a red text" "red"
# printc "This is a yellow text" "yellow"
# printc "This is an invalid color" "purple"
printc() {
    local text=$1
    local color=$2
    local reset_color="\033[0m"

    # Validate that both parameters are provided
    if [ -z "$text" ] || [ -z "$color" ]; then
        echo "Error: Both 'text' and 'color' parameters are required."
        echo "Usage: print_colored_text <text> <color>"
        available_colors
        return 1
    fi

    # Flag to check if color exists in the array
    local color_found=false

    # Iterate through the array to find the color
    for item in "${colors[@]}"; do
        # Extract color name and code
        name="${item%%=*}"
        code="${item#*=}"

        # Match the color name
        if [ "$color" == "$name" ]; then
            echo -e "${code}${text}${reset_color}"
            color_found=true
            return
        fi
    done

    # If color not found, print an alert
    if [ "$color_found" == false ]; then
        echo "ERROR: Color '$color' is not valid."
        available_colors
        return 1
    fi
}