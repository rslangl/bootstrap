# bootstrap

<!-- markdownlint-disable MD013 -->
![Build](https://github.com/rslangl/bootstrap/actions/workflows/lint.yml/badge.svg) ![License](https://img.shields.io/github/license/rslangl/bootstrap) ![GitHub release](https://img.shields.io/github/v/release/rslangl/bootstrap) ![Top Language](https://img.shields.io/github/languages/top/rslangl/bootstrap) ![Repo Size](https://img.shields.io/github/repo-size/rslangl/bootstrap)
<!-- markdownlint-enable MD013 -->

Bootable environment to bootstrap my infrastructure.

## Overview

TODO

## Usage

Install collection and run locally:

```shell
ansible-galaxy collection build
ansible-galaxy collection install nekrohaven-bootstrap-*.tar.gz --force
ansible-playbook orchestrator/stage_1/playbook.yaml -i orchestrator/stage_1/inventory.yaml
```

## Development

Using nix, which spins up a nix-shell containing all tools required:

```shell
nix develop .#default
```

## TODO

* DNS:
  * Resilience: top-level DNS (router) specifies an Unbound zonefile
    * Internal DNS fetches from master
    * Clients should add both the hypervisor and the router as nameservers
  * DNSSEC:
* IPsec:

