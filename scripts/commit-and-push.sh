#!/bin/bash
set -euo pipefail

git config --local user.name "GitHub Actions"
git config --local user.email "github-actions[bot]@users.noreply.github.com"

# Define allowed paths
FILES_TO_COMMIT=(
packages.json
index.html
p2/
include/
dist/
)

# Add only files that exist
for path in "${FILES_TO_COMMIT[@]}"; do
if [ -e "$path" ] || [ -d "$path" ]; then
    git add "$path"
fi
done

# Check if anything was staged
if git diff --cached --quiet; then
    echo "No changes to commit"
else
    git commit -m "Automated Satis build on $(date -u +'%Y-%m-%dT%H:%M:%SZ')"
    git push
fi
