#!/bin/bash
set -euo pipefail

echo "=============================================="
echo "  Air Quality System - K8s Teardown           "
echo "=============================================="
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok()   { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFESTS_DIR="$SCRIPT_DIR/manifests"

echo "🗑️  Deleting all resources in 'airquality' namespace..."
echo ""

# Delete manifests in reverse order
for manifest in $(ls -r "$MANIFESTS_DIR"/??-*.yaml 2>/dev/null); do
    echo "   Deleting $(basename "$manifest")..."
    kubectl delete -f "$manifest" --ignore-not-found=true 2>/dev/null || true
done

echo ""

# Delete namespace (catches anything we missed)
echo "🗑️  Deleting namespace..."
kubectl delete namespace airquality --ignore-not-found=true 2>/dev/null || true

ok "All Kubernetes resources removed"
echo ""

# Optionally clean up Docker images
read -p "Remove Docker images from Minikube? (y/N): " CLEAN_IMAGES
if [[ "$CLEAN_IMAGES" =~ ^[Yy]$ ]]; then
    eval $(minikube docker-env) 2>/dev/null || true
    docker rmi airquality-backend:latest 2>/dev/null || true
    docker rmi airquality-frontend:latest 2>/dev/null || true
    ok "Docker images removed"
else
    echo "   Skipping image cleanup"
fi

echo ""
echo "=============================================="
echo "  Teardown complete!                          "
echo "=============================================="
echo ""
echo "To also stop Minikube:   minikube stop"
echo "To delete Minikube:      minikube delete"
echo ""
