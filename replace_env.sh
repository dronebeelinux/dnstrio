#!/bin/bash

# Function to replace placeholders in the zone file using sed and create a new file
replace_placeholders() {
    zone_file="$1"
    env_file="$2"
    output_file="$3"

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

    cp "$zone_file" "$output_file"  # Create a copy of the original file

    for placeholder in $(cut -d= -f1 "$env_file"); do
        value="${!placeholder}"
        sed -i "s/${placeholder//\./\\.}/${value//\./\\.}/g" "$output_file"
    done

    echo "Placeholder values replaced successfully. Updated file: $output_file"
}

# Example usage:
zone_file="path/to/your/zone/file.db"
env_file="placeholder.env"
output_file="path/to/output/zone/file.db.updated"  # Provide the path for the updated file

replace_placeholders "$zone_file" "$env_file" "$output_file"
