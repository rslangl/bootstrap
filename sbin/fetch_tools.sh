#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
DOWNLOAD_DIR="${ROOT_DIR}/.cache/tmp"
CACHE_DIR="${ROOT_DIR}/.cache/tools/arm64"

# structure: ARM64
TERRAFORM_SRC="https://releases.hashicorp.com/terraform/1.12.2/terraform_1.12.2_linux_arm64.zip"

declare -A TOOLS

TOOLS=(
  [terraform]="$TERRAFORM_SRC"
)

is_compressed() {
  local file="$1"

  file_type=$(file -b --mime-type "$file")

  case "$file_type" in
  application/x-gzip | application/gzip | application/x-bzip2 | application/zip | application/octet-stream)
    return 0 # it's compressed
    ;;
  *)
    return 1 # not compressed
    ;;
  esac
}

decompress_file() {
  local compressed="$1"
  local dest="$2"

  case "$compressed" in
  *.zip)
    unzip "$compressed" -d "$dest"
    ;;
  *)
    echo "ERROR: Unsupported compression type"
    exit 1
    ;;
  esac
}

mkdir -p "${CACHE_DIR}"

for file in "${!TOOLS[@]}"; do
  IFS="|" read -r url <<<"${TOOLS[$file]}"
  clean_url="${url%%\?*}"
  filename="${clean_url##*/}"
  target_file="${DOWNLOAD_DIR}/${filename}"
  tool_file="${CACHE_DIR}/${file}"

  echo "Downloading from $url..."

  curl -s -o "$target_file" "$url"

  if is_compressed "$target_file"; then

    case "$target_file" in
    *.zip)
      yes | unzip -o "$target_file" -d "$tool_file"
      ;;
    *)
      echo "ERROR: Unsupported compression type"
      exit 1
      ;;
    esac
  fi
done
