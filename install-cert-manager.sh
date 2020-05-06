#!/bin/bash

# Configuration Path from RKE Provider
config_path="$(pwd)/kube_config_cluster.yml"

# Install Cert Manager
kubectl --kubeconfig="$config_path" create namespace cert-manager
kubectl --kubeconfig="$config_path" label namespace cert-manager certmanager.k8s.io/disable-validation=true
kubectl --kubeconfig="$config_path" apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.14.3/cert-manager.crds.yaml