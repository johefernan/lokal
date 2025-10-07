# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
- Metrics (Prometheus/InfluxDB).
- Ingress (Istio/Envoy).
- Tracing (Kiali).

## [1.2.0] - 2025-10-07
### Changed
- Install VirtualBox if not present (Linux)
- Install Kubernetes 1.30

## [1.1.3] - 2024-06-25
### Changed
- Add skippable hardening (default enabled).
- Update Ansible tasks to add apt signing key and repository for Kubernetes.
- Update image to ubuntu-24.04
- Add Vagrant box versioning (202404.26.0).
- Add 'values.yml' file with cluster definitions for Vagrant.
- Remove Kubernetes Dashboard bootstrap.
- Calico 3.28.0 instead of deprecated Weave CNI.
- runc v1.1.13
- containerd v1.7.14

## [1.1.2] - 2023-09-14
### Changed
- Change script name to lokal.sh
- -n option argument to set or disable the number of nodes (default=1).
- -d feature flag to destroy the cluster.
- `KUBECONFIG` environment variable.
- Ubuntu 22.04
- Containerd v1.7.5 (dependencies: runc)
- Dashboard v2.7.0
- Weave CNI v2.8.1

## [1.1.1] - 2021-10-17
### Changed
- Ubuntu 20.04
- Dashboard v2.4.0
- Ansible Compatibility "2.0"

## [1.1.0] - 2021-06-11
### Changed
- bootstrap.sh now with macOS support.

## [1.0.2] - 2021-06-10
### Changed
- Getting started with bootstrap.sh script.

## [1.0.1] - 2021-01-05
### Changed
- Weave CNI instead of Calico.


## [1.0.0] - 2020-12-29
### Changed
- Containerd as CRI instead of Docker (yes, no Docker at all).
- Since Kubernetes v1.20.1 minimum required memory is 1700 MB, the control plane memory was spinned up to 2048 MB.
