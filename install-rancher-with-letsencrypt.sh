#!/bin/bash

# Configuration Path from RKE Provider
config_path="$(pwd)/kube_config_cluster.yml"

# Terraform Templates
lets_encrypt_email=${lets-encrypt-email}
lets_encrypt_environment=${lets-encrypt-environment}
rancher_hostname=${rancher-domain-name}

# Initialize Helm
helm init --service-account tiller --kube-context local --kubeconfig "$config_path" --wait

helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo add rancher-alpha https://releases.rancher.com/server-charts/alpha
helm repo update

# Install Rancher
echo "Let's Encrypt Email $lets_encrypt_email"
echo "Let's Encrypt Environment $lets_encrypt_environment"
echo "Rancher Hostname $rancher_hostname"

helm install rancher-latest/rancher \
  --version v2.3.5 \
  --name rancher \
  --namespace cattle-system \
  --kube-context local \
  --kubeconfig "$config_path" \
  --set ingress.tls.source="letsEncrypt" \
  --set letsEncrypt.email="$lets_encrypt_email" \
  --set letsEncrypt.environment="$lets_encrypt_environment" \
  --set hostname="$rancher_hostname" \
  --set auditLog.level="1" \
  --set addLocal="true" \
  --timeout="600" \
  --wait
