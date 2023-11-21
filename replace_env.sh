#!/bin/bash

# Function to replace placeholders in the copied zone file using sed
replace_placeholders() {
    local zone_file="$1"
    local placeholders_file="$2"
    local output_file="$3"

    if [ ! -f "$zone_file" ]; then
        echo "File $zone_file not found"
        exit 1
    fi

    if [ ! -f "$placeholders_file" ]; then
        echo "Placeholders file $placeholders_file not found"
        exit 1
    fi

    cp "$zone_file" "$output_file"  # Create a copy of the original file

    # Read placeholder-value pairs from the environment file and replace placeholders
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ $line =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
            placeholder="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[2]}"
            if [ "$placeholder" == "EXAMPLE_HOSTIP" ]; then
                value=$(hostname -I | awk '{print $1}')
            fi
            sed -i "s/$placeholder/$value/g" "$output_file"
        fi
    done < "$placeholders_file"

    echo "Placeholder values replaced successfully in $output_file"
}

# Check if arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <zone_file> <placeholders_file> <output_file>"
    exit 1
fi

# Assign arguments to variables
zone_file="$1"
placeholders_file="$2"
output_file="$3"

replace_placeholders "$zone_file" "$placeholders_file" "$output_file"
