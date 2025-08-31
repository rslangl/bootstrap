terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
    }
    null = {
      source = "hashicorp/null"
    }
  }
}

resource "null_resource" "copy_resources" {
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command = <<EOT
cp -r ${var.cache_dir}/build_artifacts/aptrepo ${path.module}/config/includes.chroot/srv
cp -r ${var.cache_dir}/build_artifacts/registry ${path.module}/config/includes.chroot/srv
cp -r ${var.cache_dir}/build_artifacts/registry_data ${path.module}/config/includes.chroot/srv
    #cp -r ${var.cache_dir}/build_artifacts/tf_providers ${path.module}/config/includes.chroot/srv
    EOT
  }
}

resource "docker_image" "liveos" {
  name = "liveos"
  keep_locally = false
  build {
    context = "${path.module}"
    tag = ["liveos"]
    dockerfile = "${path.module}/Dockerfile"
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
  # volumes {
  #   host_path = "${abspath(path.module)}/config"
  #   container_path = "/var/livebuild/config/includes.chroot/srv"
  # }
  volumes {
    host_path = "${var.cache_dir}/output"
    container_path = "/workdir/output"
  }
}
