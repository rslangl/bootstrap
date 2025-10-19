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

# Copy pre-provisioned resources to directory to be loaded by the ISO builder
resource "null_resource" "liveos_system_copy_resources" {
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

# Docker image for the live OS builder
resource "docker_image" "liveos_system_image" {
  name = "liveos"
  keep_locally = false
  build {
    context = "${path.module}"
    tag = ["liveos"]
    dockerfile = "${path.module}/Dockerfile"
  }
}

# Docker container that builds the live OS image, where the output ISO
# will be stored in ../../../.cache/output
resource "docker_container" "liveos_system_container" {
  name = "liveos"
  image = docker_image.liveos_system_image.image_id
  rm = true
  privileged = true
  capabilities {
    add = ["SYS_ADMIN"]
  }
  security_opts = ["seccomp=unconfined"]
  volumes {
    host_path = "${var.cache_dir}/output"
    container_path = "/workdir/output"
  }
}
