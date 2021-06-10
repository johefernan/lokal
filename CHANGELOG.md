# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
- Metrics (Prometheus/InfluxDB).
- Ingress (Istio/Envoy).
- Tracing (Kiali).
- Dashboard and RBAC.

## [1.0.0] - 2020-12-29
### Changed
- Containerd as CRI instead of Docker (yes, no Docker at all).
- Since Kubernetes v1.20.1 minimum required memory is 1700 MB, master node memory was spinned up to 2048 MB.

## [1.0.1] - 2021-01-05
### Changed
- Weave CNI instead of Calico.

## [1.0.2] - 2021-06-10
### Changed
- Getting started with bootstrap.sh script.