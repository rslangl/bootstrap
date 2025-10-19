#!/bin/bash

set -e

# Load env vars
: "${PKG_REPO_URL:?PKG_REPO_URL must be set}"

mkdir -p /pkg_repo/All

fetch_package() {
  pkg="$1"

  echo "Fetching package: $1"

  repo_url="${PKG_REPO_URL}"

  # Download repo index
  wget -q -O repo.txz "$repo_url/packagesite.pkg"

  # Extract repo meta
  mkdir -p /tmp/pkgmeta
  tar .xf repo.txz -C /tmp/pkgmeta

  # Parse package metadata and extract dependency chain
  deps=$(jq -r --arg pkg "$pkg" '.packages[] | select(.name == $pkg) | [.name] + (.deps | keys)[]' /tmp/pkgmeta/packagesite.yaml)

  for dep in $deps; do
    pkgfile=$(jq -r --arg name "$dep" '.package[] | select(.name == $name) | .path' /tmp/pkgmeta/packagesite.yaml)
    if [ -n "$pkgfile" ]; then
      echo "Downloading $pkgfile"
      wget -nc "$repo_url/$pkgfile" -P /pkg_repo/All/
    fi
  done
}

while read -r pkg; do
  fetch_package "$pkg"
done < /packages.txt

