#!/bin/bash

# Function to replace placeholders in the zone file using sed
replace_placeholders() {
    zone_file="$1"
    env_file="$2"

    if [ ! -f "$zone_file" ]; then
        echo "File $zone_file not found"
        exit 1
    fi

    # Load placeholder-value pairs from the environment file
    if [ ! -f "$env_file" ]; then
        echo "Environment file $env_file not found"
        exit 1
    fi
    source "$env_file"

    for placeholder in $(cut -d= -f1 "$env_file"); do
        value="${!placeholder}"
        sed -i "s/${placeholder//\./\\.}/${value//\./\\.}/g" "$zone_file"
    done

    echo "Placeholder values replaced successfully in $zone_file"
}

# Example usage:
zone_file="path/to/your/zone/file.db"
env_file="placeholder.env"

replace_placeholders "$zone_file" "$env_file"
