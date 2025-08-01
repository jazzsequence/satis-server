#!/bin/bash
set -euo pipefail

function get_sha_from_remote() {
    local repo_url="$1"
    local ref="$2"
    git ls-remote "$repo_url" "$ref" | cut -f1
}

function get_mini_fair() {
    echo "Getting latest SHA for fair/mini-fair-repo..."
    SHA=$(get_sha_from_remote "git@github.com:fairpm/mini-fair-repo.git" "refs/heads/main")

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
}

function get_jazzsequence_artists() {
    REPO_URL="https://github.com/jazzsequence/Artists"
    PACKAGE_NAME="jazzsequence/artists"
    echo "Getting latest SHA for jazzsequence/artists..."
    # Get the latest tag (sorted by version, not alphabetical)
    LATEST_TAG=$(git ls-remote --tags "$REPO_URL" | grep -v '\^{}' | awk '{print $2}' | sed 's|refs/tags/||' | sort -V | tail -n 1)

    SHA=$(get_sha_from_remote "$REPO_URL" "refs/tags/$LATEST_TAG")

    # Update satis.json (replace existing entry or inject dynamically)
    jq --arg name "$PACKAGE_NAME" \
    --arg version "$LATEST_TAG" \
    --arg url "$REPO_URL" \
    --arg sha "$SHA" \
    '
    .repositories |= map(
        if .type == "package" and .package.name == $name
        then
        .package.version = $version |
        .package.source.reference = $sha
        else
        .
        end
    )
    ' satis.json > satis.json.tmp && mv satis.json.tmp satis.json

    echo "satis.json updated with jazzsequence/artists: $LATEST_TAG ($SHA)"
}

function get_jazzsequence_releases() {
    REPO_URL="https://github.com/jazzsequence/releases"
    PACKAGE_NAME="jazzsequence/releases"
    echo "Getting latest SHA for jazzsequence/releases..."
    # Get the latest tag (sorted by version, not alphabetical)
    LATEST_TAG=$(git ls-remote --tags "$REPO_URL" | grep -v '\^{}' | awk '{print $2}' | sed 's|refs/tags/||' | sort -V | tail -n 1)

    SHA=$(get_sha_from_remote "$REPO_URL" "refs/tags/$LATEST_TAG")

    # Update satis.json (replace existing entry or inject dynamically)
    jq --arg name "$PACKAGE_NAME" \
    --arg version "$LATEST_TAG" \
    --arg url "$REPO_URL" \
    --arg sha "$SHA" \
    '
    .repositories |= map(
        if .type == "package" and .package.name == $name
        then
        .package.version = $version |
        .package.source.reference = $sha
        else
        .
        end
    )
    ' satis.json > satis.json.tmp && mv satis.json.tmp satis.json

    echo "satis.json updated with jazzsequence/releases: $LATEST_TAG ($SHA)"
}

function get_jazzsequence_reviews() {
    REPO_URL="https://github.com/jazzsequence/reviews"
    PACKAGE_NAME="jazzsequence/reviews"
    echo "Getting latest SHA for jazzsequence/reviews..."
    # Get the latest tag (sorted by version, not alphabetical)
    LATEST_TAG=$(git ls-remote --tags "$REPO_URL" | grep -v '\^{}' | awk '{print $2}' | sed 's|refs/tags/||' | sort -V | tail -n 1)

    SHA=$(get_sha_from_remote "$REPO_URL" "refs/tags/$LATEST_TAG")

    # Update satis.json (replace existing entry or inject dynamically)
    jq --arg name "$PACKAGE_NAME" \
    --arg version "$LATEST_TAG" \
    --arg url "$REPO_URL" \
    --arg sha "$SHA" \
    '
    .repositories |= map(
        if .type == "package" and .package.name == $name
        then
        .package.version = $version |
        .package.source.reference = $sha
        else
        .
        end
    )
    ' satis.json > satis.json.tmp && mv satis.json.tmp satis.json

    echo "satis.json updated with jazzsequence/reviews: $LATEST_TAG ($SHA)"
}

function get_pantheon_content_publisher() {
    REPO_URL="https://github.com/pantheon-systems/pantheon-content-publisher-for-wordpress"
    PACKAGE_NAME="pantheon-systems/pantheon-content-publisher-for-wordpress"

    echo "Getting latest SHA for pantheon-content-publisher-for-wordpress..."
    # Get the latest tag (sorted by version, not alphabetical)
    LATEST_TAG=$(git ls-remote --tags "$REPO_URL" | grep -v '\^{}' | awk '{print $2}' | sed 's|refs/tags/||' | sort -V | tail -n 1)

    SHA=$(get_sha_from_remote "$REPO_URL" "refs/tags/$LATEST_TAG")

    # Update satis.json (replace existing entry or inject dynamically)
    jq --arg name "$PACKAGE_NAME" \
    --arg version "$LATEST_TAG" \
    --arg url "$REPO_URL" \
    --arg sha "$SHA" \
    '
    .repositories |= map(
        if .type == "package" and .package.name == $name
        then
        .package.version = $version |
        .package.source.reference = $sha
        else
        .
        end
    )
    ' satis.json > satis.json.tmp && mv satis.json.tmp satis.json

    echo "satis.json updated with pantheon-content-publisher-for-wordpress: $LATEST_TAG ($SHA)"
}

function main() {
    get_mini_fair
    get_jazzsequence_artists
    get_jazzsequence_releases
    get_jazzsequence_reviews
    get_pantheon_content_publisher
}

main
