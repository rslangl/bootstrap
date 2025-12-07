#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
DOWNLOAD_DIR="${ROOT_DIR}/.cache/tmp"
CACHE_DIR="${ROOT_DIR}/.cache/tools/arm64"

# renovate: datasource=github-tags depName=ansible/ansible versioning=semver
ANSIBLE_VERSION="2.20.0"
# renovate: datasource=github-releases depName=kcl-lang/kcl versioning=semver
KCL_VERSION="0.21.1"
# renovate: datasource=github-releases depName=terraform-linters/tflint versioning=semver
TFLINT_VERSION="0.60.0"
# renovate: datasource=regex depName=terraform versioning=semver
TERRAFORM_VERSION="1.12.2"
# renovate: datasource=regex depName=docker versioning=semver
DOCKER_VERSION="29.1.0"

TERRAFORM_SRC_AMD64="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
TFLINT_SRC_AMD64="https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip"
KCL_SRC_AMD64="https://github.com/kcl-lang/cli/releases/download/v${KCL_VERSION}/kcl-v${KCL_VERSION}-linux-amd64.tar.gz"
ANSIBLE_SRC_AMD64="https://github.com/ansible/ansible/archive/refs/tags/v${ANSIBLE_VERSION}.tar.gz"
DOCKER_SRC_AMD64="https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz"

declare -A TOOLS_AMD64

TOOLS_AMD64=(
  [terraform]="$TERRAFORM_SRC_AMD64"
  [tflint]="$TFLINT_SRC_AMD64"
  [kcl]="$KCL_SRC_AMD64"
  [ansible]="$ANSIBLE_SRC_AMD64"
  [docker]="$DOCKER_SRC_AMD64"
)

mkdir -p "${CACHE_DIR}/amd64"

for file in "${!TOOLS_AMD64[@]}"; do
  IFS="|" read -r url <<<"${TOOLS_AMD64[$file]}"
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

