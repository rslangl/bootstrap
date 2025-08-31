terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
    docker = {
      source  = "kreuzwerker/docker"
    }
  }
}

resource "docker_image" "deb_fetch" {
  name = "deb-fetch"
  keep_locally = false
  build {
    context = "${path.module}"
    tag = ["deb-fetch"]
    dockerfile = "${path.module}/Dockerfile"
  }
}

resource "docker_container" "deb_fetch" {
  name = "deb-fetch"
  image = docker_image.deb_fetch.image_id
  rm = true
  volumes {
    host_path = "${var.cache_dir}/build_artifacts/aptrepo/packages"
    container_path = "/workdir/packages"
    read_only = true
  }
  volumes {
    host_path = "${abspath(path.module)}/packages.txt"
    container_path = "/workdir/packages.txt"
    read_only = true
  }
  volumes {
    host_path = "${var.cache_dir}/build_artifacts/aptrepo"
    container_path = "/repo"
  }
}
