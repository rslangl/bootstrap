terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
    }
  }
}

resource "null_resource" "populate_registry" {
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command = <<EOT
echo "Fetching container images..."
docker run -d -p 5000:5000 --name local_registry registry:2 || echo "Registry already running"

for image in ${join(" ", var.registry_containers)}; do
  docker pull "$image"
  docker tag "$image" "localhost:5000/$image"
  docker push "localhost:5000/$image"
done

echo "Building container registry..."
docker cp local_registry:/var/lib/registry ${var.cache_dir}/build_artifacts/registry_data
docker save registry:2 -o ${var.cache_dir}/build_artifacts/registry/registry.tar
    EOT
  }
  triggers = {
    container_list_hash = sha1(join(",", var.registry_containers))
  }
}
