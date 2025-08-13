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
   local asset_name_pattern="$4"

   echo "Getting release for $package_name for tag $tag..."

   RELEASE_DATA=$(curl -s "https://api.github.com/repos/$repo_url/releases/tags/$tag")
   TAG_FROM_API=$(echo "$RELEASE_DATA" | jq -r '.tag_name')

   if [ -z "$asset_name_pattern" ]; then
       # if no pattern, assume package name is the asset name
       asset_name_pattern="${package_name##*/}.zip"
   fi

   ZIP_URL=$(echo "$RELEASE_DATA" | jq -r --arg pattern "$asset_name_pattern" '.assets[] | select(.name | test($pattern; "i")) | .browser_download_url')

   if [ -z "$TAG_FROM_API" ] || [ "$TAG_FROM_API" == "null" ]; then
       echo "No release found for tag $tag in $package_name"
       exit 1
   fi

   if [ -z "$ZIP_URL" ] || [ "$ZIP_URL" == "null" ]; then
       echo "No zip asset found for $package_name with pattern $asset_name_pattern"
       exit 1
   fi

   jq --arg name "$package_name" \
      --arg version "$tag" \
      --arg url "$ZIP_URL" \
      --arg ref "$tag" \
      '
      .repositories |= map(
          if .type == "package" and .package.name == $name
          then
              .package.version = $version |
              .package.dist.url = $url |
              .package.dist.reference = $ref
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

function get_humanmade_ai() {
    echo "Getting latest SHA for humanmade/ai..."
    SHA=$(get_sha_from_remote "git@github.com:humanmade/ai-plugin.git" "refs/heads/main")

    # Use jq to inject the latest SHA into satis.json
    echo "Updating satis.json with SHA: $SHA"
    jq --arg sha "$SHA" '
    .repositories |= map(
        if .type == "package" and .package.name == "humanmade/ai-plugin"
        then .package.source.reference = $sha
        else .
        end
    )
    ' satis.json > satis.json.tmp && mv satis.json.tmp satis.json
    echo "satis.json updated with humanmade/ai-plugin: dev-main ($SHA)."
}

function get_remote_data_blocks() {
    REPO_SLUG="automattic/remote-data-blocks"
    REPO_URL="https://github.com/$REPO_SLUG"
    PACKAGE_NAME="automattic/remote-data-blocks"
    LATEST_TAG=$(get_latest_tag "$REPO_URL")
    echo "Getting release for $PACKAGE_NAME for $LATEST_TAG..."

    patch_satis_json_from_github_release "$REPO_SLUG" "$PACKAGE_NAME" "$LATEST_TAG" "remote-data-blocks.zip"
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
    REPO_SLUG="pantheon-systems/pantheon-content-publisher-wordpress"
    REPO_URL="https://github.com/$REPO_SLUG"
    PACKAGE_NAME="pantheon-systems/pantheon-content-publisher-wordpress"
    LATEST_TAG=$(get_latest_tag "$REPO_URL")

    patch_satis_json_from_github_release "$REPO_SLUG" "$PACKAGE_NAME" "$LATEST_TAG" "pantheon-content-publisher-for-wordpress.zip"
}

function main() {
    get_mini_fair
    get_humanmade_ai
    get_jazzsequence_artists
    get_jazzsequence_releases
    get_jazzsequence_reviews
    get_pantheon_content_publisher
    get_remote_data_blocks
}

main
