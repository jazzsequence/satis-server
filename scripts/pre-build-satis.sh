#!/bin/bash
set -euo pipefail

echo "Getting latest SHA for fair/mini-fair-repo..."
SHA=$(git ls-remote git@github.com:fairpm/mini-fair-repo.git refs/heads/main | cut -f1)

# Use jq to inject the latest SHA into satis.json
echo "Updating satis.json with SHA: $SHA"
jq --arg sha "$SHA" '
  .repositories |= map(
    if .type == "package" and .package.name == "fair/mini-fair-repo"
    then .package.source.reference = $sha
    else .
    end
  )
' satis.json > satis.json.tmp && mv satis.json.tmp satis.json
echo "satis.json updated successfully."
