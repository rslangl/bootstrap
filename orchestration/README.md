# Orchestration

Layered provisioning steps in which the sequence depends on the former stage.

## Stage 1

* Initializes the internal PKI
* Sets up the top-level router
* Configures hypervisor OS'es

## Stage 2

* Sets up the virtualization infrastructure on the hypervisors

## Stage 3

* Sets up the workloads
