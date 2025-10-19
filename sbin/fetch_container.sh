#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
DOWNLOAD_DIR="${ROOT_DIR}/.cache/tmp"
CACHE_DIR="${ROOT_DIR}/.cache/containers"

declare -A CONTAINERS

CONTAINERS=(

)

# Save the registry image itself
#docker pull registry:2
#docker save registry:2 -o "${CACHE_DIR}/registry.tar"

# Run a temporary local registry to create image blobs and metadata
docker run -d -p 5000:5000 --name local_registry registry:2

# Add all containers to the registry with custom tag
for container in "${!CONTAINERS[@]}"; do
  IFS="|" read -r name <<< "${CONTAINERS[$container]}"
  docker pull "$name"
  docker tag "$name" "localhost:5000/$name"
  docker push "localhost:5000/$name"
done

# Once finished loading images, prepare the registry tarball
mkdir "${DOWNLOAD_DIR}/registry_data"
docker stop registry
docker cp registry:/var/lib/registry "${DOWNLOAD_DIR}/registry_data"
docker save registry:2 -o "${CACHE_DIR}/registry.tar"
