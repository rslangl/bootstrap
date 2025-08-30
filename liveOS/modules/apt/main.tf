resource "docker_image" "deb_fetch" {
  name = "deb-fetch"
  tag = ["deb-fetch"]
  keep_locally = false
  build {
    context = "."
    dockerfile = "Dockerfile"
  }
}

resource "docker_container" "deb_fetch" {
  name = "deb-fetch"
  image = docker_image.deb_fetch.image_id
  rm = true
  volumes {
    host_path = "${LIVE_BUILD_DIR}/build-artifacts/aptrepo/packages"
    container_path = "/workdir/packages"
    read_only = true
  }
  volumes {
    host_path = "${LIVE_BUILD_DIR}/docker/apt-deb-fetcher/packages.txt"
    container_path = "/workdir/packages.txt"
  }
  volumes {
    host_path = "${LIVE_BUILD_DIR}/build-artifacts/aptrepo"
    container_path = "/repo"
  }
}
