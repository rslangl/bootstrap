#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
DOWNLOAD_DIR="${ROOT_DIR}/.cache/tmp"
CACHE_DIR="${ROOT_DIR}/.cache/tools/arm64"

# QEMU: https://www.qemu.org/download/ (source only), github tags: https://api.github.com/repos/qemu/qemu/tags

TERRAFORM_SRC_ARM64="https://releases.hashicorp.com/terraform/1.12.2/terraform_1.12.2_linux_arm64.zip"
TFLINT_SRC_ARM64="https://github.com/terraform-linters/tflint/releases/download/v0.60.0/tflint_linux_arm64.zip"
KCL_SRC_ARM64="https://github.com/kcl-lang/cli/releases/download/v0.12.1/kcl-v0.12.1-linux-arm64.tar.gz"
ANSIBLE_SRC_ARM64="https://github.com/ansible/ansible/archive/refs/tags/v2.20.0.tar.gz"
DOCKER_SRC_ARM64="https://download.docker.com/linux/static/stable/aarch64/docker-29.1.2.tgz"

declare -A TOOLS_ARM64

TOOLS_ARM64=(
  [terraform]="$TERRAFORM_SRC_ARM64"
  [tflint]="$TFLINT_SRC_ARM64"
  [kcl]="$KCL_SRC_ARM64"
  [ansible]="$ANSIBLE_SRC_ARM64"
  [docker]="$DOCKER_SRC_ARM64"
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

# decompress_file() {
#   local compressed="$1"
#   local dest="$2"
#
#   case "$compressed" in
#   *.zip)
#     unzip "$compressed" -d "$dest"
#     ;;
#   *)
#     echo "ERROR: Unsupported compression type"
#     exit 1
#     ;;
#   esac
# }

mkdir -p "${CACHE_DIR}/arm64"

for file in "${!TOOLS_ARM64[@]}"; do
  IFS="|" read -r url <<<"${TOOLS_ARM64[$file]}"
  clean_url="${url%%\?*}"
  filename="${clean_url##*/}"
  target_file="${DOWNLOAD_DIR}/${filename}"
  tool_file="${CACHE_DIR}/arm64/${file}"

  # echo "clean_url: $clean_url"
  # echo "filename: $filename"
  # echo "target_file: $target_file"
  # echo "tool_file: $tool_file"
  
  if [ -f "$tool_file" ]; then

    echo "Downloading from $url..."

    curl -s -o "$target_file" "$url"

    if is_compressed "$target_file"; then

      case "$target_file" in
        *.zip)
          yes | unzip -o "$target_file" -d "$tool_file"
          ;;
        *.tar.xz)
          tar -xJF "$target_file" -C "$tool_file"
          ;;
        *.tar.gz|*.tgz)
          tar -xzf "$target_file" -C "$tool_file"
          ;;
        *)
          echo "ERROR: Unsupported compression type"
          exit 1
          ;;
      esac
    fi

    # TODO: if directory, handle accordingly
  else
    echo "INFO: $tool_file already exists, skipping..."
  fi
done

