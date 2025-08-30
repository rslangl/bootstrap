resource "docker_image" "liveos" {
  name = "liveos"
  tag = ["liveos"]
  keep_locally = false
  build {
    context = "."
    dockerfile = "Dockerfile"
  }
}

resource "docker_container" "liveos" {
  name = "liveos"
  image = docker_image.liveos.image_id
  rm = true
  privileged = true
  capabilities {
    add = ["SYS_ADMIN"]
  }
  security_opts = ["seccomp=unconfined"]
  volumes {
    host_path = "${CURDIR}/config"
    container_path = "/home/builder/config"
  }
  volumes {
    host_path = "${CURDIR}/output"
    container_path = "/home/builder/output"
  }
  entrypoint = "build.sh"
}
