#!/bin/bash
set -e

echo "==> Installing k3d if missing..."
if ! command -v k3d &> /dev/null; then
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
fi

echo "==> Creating lightweight k3d cluster..."
k3d cluster delete aiops 2>/dev/null || true
k3d cluster create aiops \
  --agents 1 \
  --servers 1 \
  --k3s-arg "--disable=traefik@server:0" \
  --k3s-arg "--disable=metrics-server@server:0" \
  --port "8080:80@loadbalancer"

echo "==> Cluster ready. Checking nodes:"
kubectl get nodes
echo "==> Done. Use: kubectl cluster-info"
