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

    echo "Getting latest SHA for $package_name for $tag..."

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
       echo "satis.json updated with $package_name: $tag ($SHA)"
}

function patch_satis_json_from_github_release() {
   local repo_url="$1"
   local package_name="$2"
   local tag="$3"

   echo "Getting latest release for $package_name..."

   RELEASE_DATA=$(curl -s "https://api.github.com/repos/$repo_url/releases/latest")

   ZIP_URL=$(echo "$RELEASE_DATA" | jq -r '.zipball_url')

   jq --arg name "$package_name" \
      --arg version "$tag" \
      --arg url "$ZIP_URL" \
      '
      .repositories |= map(
          if .type == "package" and .package.name == $name
          then
              .package.version = $version |
              .package.dist.url = $url
          else
              .
          end
      )
      ' satis.json > satis.json.tmp && mv satis.json.tmp satis.json
      echo "satis.json updated with $package_name: $tag"
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
    REPO_URL="https://github.com/automattic/remote-data-blocks"
    PACKAGE_NAME="automattic/remote-data-blocks"
    LATEST_TAG=$(get_latest_tag "$REPO_URL")

    patch_satis_json_from_github_release "$REPO_URL" "$PACKAGE_NAME" "$LATEST_TAG"
}

function get_jazzsequence_artists() {
    REPO_URL="https://github.com/jazzsequence/Artists"
    PACKAGE_NAME="jazzsequence/artists"
    LATEST_TAG=$(get_latest_tag "$REPO_URL")

    patch_satis_json_from_tag "$REPO_URL" "$PACKAGE_NAME" "$LATEST_TAG"
}

function get_jazzsequence_releases() {
    REPO_URL="https://github.com/jazzsequence/releases"
    PACKAGE_NAME="jazzsequence/releases"
    LATEST_TAG=$(get_latest_tag "$REPO_URL")

    patch_satis_json_from_tag "$REPO_URL" "$PACKAGE_NAME" "$LATEST_TAG"
}

function get_jazzsequence_reviews() {
    REPO_URL="https://github.com/jazzsequence/reviews"
    PACKAGE_NAME="jazzsequence/reviews"
    LATEST_TAG=$(get_latest_tag "$REPO_URL")

    patch_satis_json_from_tag "$REPO_URL" "$PACKAGE_NAME" "$LATEST_TAG"
}

function get_pantheon_content_publisher() {
    REPO_URL="https://github.com/pantheon-systems/pantheon-content-publisher-for-wordpress"
    PACKAGE_NAME="pantheon-systems/pantheon-content-publisher-for-wordpress"
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
