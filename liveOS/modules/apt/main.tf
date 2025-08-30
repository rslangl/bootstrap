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
    #context = "${path.cwd}/context-dir"
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
    #host_path = "${abspath("../build-artifacts/aptrepo/packages")}"
    host_path = "/home/user/dev/sw/bootstrap/liveOS/build-artifacts/aptrepo/packages"
    container_path = "/workdir/packages"
    read_only = true
  }
  volumes {
    #host_path = "${abspath("./modules/apt/packages.txt")}"
    host_path = "/home/user/dev/sw/bootstrap/liveOS/modules/apt/packages.txt"
    container_path = "/workdir/packages.txt"
  }
  volumes {
    #host_path = "${abspath("../build-artifacts/aptrepo")}"
    host_path = "/home/user/dev/sw/bootstrap/liveOS/build-artifacts/aptrepo"
    container_path = "/repo"
  }
}
