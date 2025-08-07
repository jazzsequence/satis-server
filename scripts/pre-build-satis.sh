#!/bin/bash
set -euo pipefail

function get_sha_from_remote() {
    local repo_url="$1"
    local ref="$2"
    git ls-remote "$repo_url" "$ref" | cut -f1
}

function get_latest_tag() {
    local repo_url="$1"
    LATEST_TAG=$(git ls-remote --tags "$repo_url" | grep -v '\^{}' | awk '{print $2}' | sed 's|refs/tags/||' | sort -V | tail -n 1)
    if [ -z "$LATEST_TAG" ]; then
        echo "No tags found in $repo_url"
        exit 1
    fi
    echo "$LATEST_TAG"
}

function get_sha_from_tag() {
    local repo_url="$1"
    local tag="$2"
    SHA=$(get_sha_from_remote "$repo_url" "refs/tags/$tag")
    if [ -z "$SHA" ]; then
        echo "No SHA found for tag $tag in $repo_url"
        exit 1
    fi
    echo "$SHA"
}

function patch_satis_json_from_tag() {
    local repo_url="$1"
    local package_name="$2"
    local tag="$3"

    SHA=$(get_sha_from_tag "$repo_url" "$tag")

    jq --arg name "$package_name" \
       --arg version "$tag" \
       --arg url "$repo_url" \
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
       echo "satis.json updated with $PACKAGE_NAME: $LATEST_TAG ($SHA)"
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
    echo "satis.json updated with fair/mini-fair-repo: dev-main ($SHA)."
}

function get_remote_data_blocks() {
    echo "Getting latest SHA for automattic/remote-data-blocks..."
    REPO_URL="https://github.com/automattic/remote-data-blocks"
    PACKAGE_NAME="automattic/remote-data-blocks"
    # Get the latest tag (sorted by version, not alphabetical)
    LATEST_TAG=$(get_latest_tag "$REPO_URL")

    patch_satis_json_from_tag "$REPO_URL" "$PACKAGE_NAME" "$LATEST_TAG"
}

function get_jazzsequence_artists() {
    REPO_URL="https://github.com/jazzsequence/Artists"
    PACKAGE_NAME="jazzsequence/artists"
    echo "Getting latest SHA for jazzsequence/artists..."
    # Get the latest tag (sorted by version, not alphabetical)
    LATEST_TAG=$(get_latest_tag "$REPO_URL")

    patch_satis_json_from_tag "$REPO_URL" "$PACKAGE_NAME" "$LATEST_TAG"
}

function get_jazzsequence_releases() {
    REPO_URL="https://github.com/jazzsequence/releases"
    PACKAGE_NAME="jazzsequence/releases"
    echo "Getting latest SHA for jazzsequence/releases..."
    # Get the latest tag (sorted by version, not alphabetical)
    LATEST_TAG=$(get_latest_tag "$REPO_URL")

    patch_satis_json_from_tag "$REPO_URL" "$PACKAGE_NAME" "$LATEST_TAG"
}

function get_jazzsequence_reviews() {
    REPO_URL="https://github.com/jazzsequence/reviews"
    PACKAGE_NAME="jazzsequence/reviews"
    echo "Getting latest SHA for jazzsequence/reviews..."
    # Get the latest tag (sorted by version, not alphabetical)
    LATEST_TAG=$(get_latest_tag "$REPO_URL")

    patch_satis_json_from_tag "$REPO_URL" "$PACKAGE_NAME" "$LATEST_TAG"
}

function get_pantheon_content_publisher() {
    REPO_URL="https://github.com/pantheon-systems/pantheon-content-publisher-for-wordpress"
    PACKAGE_NAME="pantheon-systems/pantheon-content-publisher-for-wordpress"

    echo "Getting latest SHA for pantheon-content-publisher-for-wordpress..."
    # Get the latest tag (sorted by version, not alphabetical)
    LATEST_TAG=$(get_latest_tag "$REPO_URL")

    patch_satis_json_from_tag "$REPO_URL" "$PACKAGE_NAME" "$LATEST_TAG"
}

function main() {
    get_mini_fair
    get_jazzsequence_artists
    get_jazzsequence_releases
    get_jazzsequence_reviews
    get_pantheon_content_publisher
    get_remote_data_blocks
}

main
