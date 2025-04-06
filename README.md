# bootstrap

Bootable environment to bootstrap my infrastructure.

## Usage

Local development:
```shell
# Launch nix shell
nix-shell

# Starts Docker service
start_docker

# Generate SSH key
generate_ssh_key

# Add host to environment
add_host
appsrv
10.0.0.2
```
For local, virtualized testing:
```shell
# launch Vagrant:
vagrant up --provider=qemu

# use dev workspace
terraform workspace select dev
terraform apply -var-file=dev.tfvars
```

