#!/bin/bash

# commit-batch.sh - Commit and push changes in batches to avoid GitHub limits
# Usage: ./commit-batch.sh [batch-size]
# Example: ./commit-batch.sh 20

set -e

BATCH_SIZE=${1:-10}  # Default to 10 files per batch

echo "Committing changes in batches of $BATCH_SIZE files..."

# Get list of changed files (added/modified/deleted)
CHANGED_FILES=$(git diff --name-only HEAD)

if [ -z "$CHANGED_FILES" ]; then
    echo "No changes to commit."
    exit 0
fi

# Convert to array
readarray -t FILES_ARRAY <<< "$CHANGED_FILES"
TOTAL_FILES=${#FILES_ARRAY[@]}

echo "Found $TOTAL_FILES changed files"
echo "Will create $(( (TOTAL_FILES + BATCH_SIZE - 1) / BATCH_SIZE )) commits"

BATCH_NUM=1
for ((i=0; i<TOTAL_FILES; i+=BATCH_SIZE)); do
    echo ""
    echo "Batch $BATCH_NUM: Files $((i+1)) to $((i+BATCH_SIZE < TOTAL_FILES ? i+BATCH_SIZE : TOTAL_FILES))"
    
    # Add files for this batch
    for ((j=i; j<TOTAL_FILES && j<i+BATCH_SIZE; j++)); do
        git add "${FILES_ARRAY[j]}"
        echo "  Added: ${FILES_ARRAY[j]}"
    done
    
    # Commit this batch
    git commit -m "feat: randomized gallery batch $BATCH_NUM

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
    
    echo "Committed batch $BATCH_NUM"
    
    # Push this batch
    echo "Pushing batch $BATCH_NUM..."
    git push origin main
    echo "Pushed batch $BATCH_NUM successfully"
    
    ((BATCH_NUM++))
    
    # Small delay to be nice to GitHub
    if [ $i -lt $((TOTAL_FILES-BATCH_SIZE)) ]; then
        echo "Waiting 2 seconds before next batch..."
        sleep 2
    fi
done

echo ""
echo "All batches committed and pushed successfully!"