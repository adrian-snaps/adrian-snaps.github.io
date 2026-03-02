#!/bin/bash

# randomize-gallery-weights.sh - Randomize gallery order using weight parameters instead of renaming files
# Usage: ./randomize-gallery-weights.sh <gallery-directory> [--yes]
# Example: ./randomize-gallery-weights.sh content/nature/ --yes

set -e  # Exit on any error

# Parse arguments
GALLERY_DIR=""
AUTO_YES=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --yes|-y)
            AUTO_YES=true
            shift
            ;;
        *)
            if [ -z "$GALLERY_DIR" ]; then
                GALLERY_DIR="$1"
            else
                echo "Error: Too many arguments"
                echo "Usage: $0 <gallery-directory> [--yes]"
                exit 1
            fi
            shift
            ;;
    esac
done

# Check if directory argument is provided
if [ -z "$GALLERY_DIR" ]; then
    echo "Usage: $0 <gallery-directory> [--yes]"
    echo "Example: $0 content/nature/"
    echo "Example: $0 content/nature/ --yes  (skip confirmation)"
    exit 1
fi

# Check if directory exists
if [ ! -d "$GALLERY_DIR" ]; then
    echo "Error: Directory '$GALLERY_DIR' does not exist."
    exit 1
fi

# Change to the gallery directory
cd "$GALLERY_DIR"

# Check if there are any image files (jpg, jpeg, png, gif, webp, tif)
IMAGE_COUNT=$(find . -maxdepth 1 \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" -o -name "*.webp" -o -name "*.tif" \) -type f | wc -l)
if [ "$IMAGE_COUNT" -eq 0 ]; then
    echo "No image files found in '$GALLERY_DIR' (.jpg, .jpeg, .png, .gif, .webp, .tif)"
    exit 1
fi

echo "Found $IMAGE_COUNT image files in '$GALLERY_DIR'"
echo "Creating weight-based randomization..."

# Create temporary directory for processing
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Generate list of current image files and shuffle them
find . -maxdepth 1 \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" -o -name "*.webp" -o -name "*.tif" \) -type f -exec basename {} \; | shuf > "$TEMP_DIR/shuffled_files.txt"

# Generate random weights for each file
COUNTER=1
echo "Weight assignments:"
while IFS= read -r filename; do
    # Generate random weight (1-9999, higher numbers sort first in desc order)
    WEIGHT=$(shuf -i 1-9999 -n 1)
    
    # Ensure weight is unique
    while grep -q "^$WEIGHT " "$TEMP_DIR/weight_map.txt" 2>/dev/null; do
        WEIGHT=$(shuf -i 1-9999 -n 1)
    done
    
    echo "$WEIGHT $filename" >> "$TEMP_DIR/weight_map.txt"
    echo "  $filename -> weight: $WEIGHT"
    
    ((COUNTER++))
done < "$TEMP_DIR/shuffled_files.txt"

# Sort by weight to determine cover image (highest weight first)
sort -nr "$TEMP_DIR/weight_map.txt" > "$TEMP_DIR/sorted_weights.txt"
COVER_IMAGE=$(head -n 1 "$TEMP_DIR/sorted_weights.txt" | cut -d' ' -f2)

echo ""
echo "Cover image will be: $COVER_IMAGE (highest weight)"

echo ""
if [ "$AUTO_YES" = false ]; then
    read -p "Update index.md with weight-based sorting? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Update cancelled."
        exit 0
    fi
else
    echo "Auto-confirming update (--yes flag used)"
fi


echo "Updating index.md..."

# Create new index.md with weight-based sorting
TEMP_DIR="$TEMP_DIR" python3 << 'EOF'
import sys
import re
import os

# Read the current index.md
try:
    with open('index.md', 'r') as f:
        content = f.read()
except FileNotFoundError:
    print("Error: index.md not found")
    sys.exit(1)

# Read weight mappings
weights = {}
with open(os.environ['TEMP_DIR'] + '/weight_map.txt', 'r') as f:
    for line in f:
        weight, filename = line.strip().split(' ', 1)
        weights[filename] = int(weight)

# Get cover image
with open(os.environ['TEMP_DIR'] + '/sorted_weights.txt', 'r') as f:
    cover_image = f.readline().strip().split(' ', 1)[1]

# Split content into front matter and body
parts = content.split('---', 2)
if len(parts) != 3:
    print("Error: Invalid front matter format")
    sys.exit(1)

front_matter = parts[1]
body = parts[2] if len(parts) > 2 else ""

# Update sort_by parameter
front_matter = re.sub(r'sort_by: .*', 'sort_by: Params.weight', front_matter)

# Update featured_image
front_matter = re.sub(r'featured_image: .*', f'featured_image: {cover_image}', front_matter)

# Remove existing resources section (everything from 'resources:' to end of front matter)
front_matter = re.sub(r'resources:\s*\n.*', '', front_matter, flags=re.DOTALL)

# Build new resources section
resources_section = "resources:\n"
for filename, weight in sorted(weights.items(), key=lambda x: x[1], reverse=True):
    if filename == cover_image:
        resources_section += f"  - src: {filename}\n    params:\n      weight: {weight}\n      cover: true\n"
    else:
        resources_section += f"  - src: {filename}\n    params:\n      weight: {weight}\n"

# Add resources section before the closing ---
front_matter = front_matter.rstrip() + "\n" + resources_section

# Write new content
new_content = "---" + front_matter + "---" + body

with open('index.md', 'w') as f:
    f.write(new_content)

print("index.md updated successfully!")
EOF

echo ""
echo "Gallery randomization complete!"
echo "- Set sorting to weight-based ('Params.weight')"
echo "- Assigned random weights to all images"
echo "- Set '$COVER_IMAGE' as cover image (highest weight)"
