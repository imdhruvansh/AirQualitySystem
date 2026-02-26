#!/bin/bash
set -euo pipefail

echo "=============================================="
echo "  Minikube & kubectl Setup Script (macOS)    "
echo "=============================================="
echo ""

# Color helpers
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok()   { echo -e "${GREEN}$1${NC}"; }
warn() { echo -e "${YELLOW}$1${NC}"; }
fail() { echo -e "${RED}$1${NC}"; exit 1; }

# Pre-flight checks
echo "Running pre-flight checks..."
echo ""

# Check macOS
if [[ "$(uname)" != "Darwin" ]]; then
    fail "This script is designed for macOS. Detected: $(uname)"
fi
ok "Running on macOS"

# Check Homebrew
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ok "Homebrew installed"
else
    ok "Homebrew is available"
fi

# Check Docker
if ! command -v docker &>/dev/null; then
    fail "Docker is not installed. Please install Docker Desktop from https://www.docker.com/products/docker-desktop/"
fi

if ! docker info &>/dev/null 2>&1; then
    fail "Docker is not running. Please start Docker Desktop first."
fi
ok "Docker is running"

# Install kubectl
echo ""
echo "Checking kubectl..."
if ! command -v kubectl &>/dev/null; then
    echo "Installing kubectl via Homebrew..."
    brew install kubectl
    ok "kubectl installed ($(kubectl version --client --short 2>/dev/null || kubectl version --client -o yaml | grep gitVersion | head -1))"
else
    ok "kubectl is already installed"
fi

# Install Minikube
echo ""
echo "Checking Minikube..."
if ! command -v minikube &>/dev/null; then
    echo "Installing Minikube via Homebrew..."
    brew install minikube
    ok "Minikube installed ($(minikube version --short))"
else
    ok "Minikube is already installed ($(minikube version --short))"
fi

# Start Minikube
echo ""
echo "Starting Minikube cluster..."

MINIKUBE_STATUS=$(minikube status --format='{{.Host}}' 2>/dev/null || echo "Stopped")

if [[ "$MINIKUBE_STATUS" == "Running" ]]; then
    warn "Minikube is already running"
else
    minikube start \
        --driver=docker \
        --cpus=2 \
        --memory=4096 \
        --disk-size=20g \
        --kubernetes-version=stable
    ok "Minikube cluster started"
fi

# Enable addons
echo ""
echo "Enabling Minikube addons..."
minikube addons enable metrics-server 2>/dev/null || true
minikube addons enable storage-provisioner 2>/dev/null || true
ok "Addons enabled"

# Verify cluster
echo ""
echo "Verifying cluster..."
kubectl cluster-info
echo ""
kubectl get nodes
echo ""

ok "Minikube cluster is ready"

echo ""
echo "=============================================="
echo "  Setup complete                             "
echo "=============================================="
echo ""
echo "Next steps:"
echo "  1. Run the deploy script:  ./k8s/deploy.sh"
echo "  2. Read the full guide:    k8s/K8S_GUIDE.md"
echo ""
echo "Useful commands:"
echo "  minikube status          - Check cluster status"
echo "  minikube dashboard       - Open K8s dashboard"
echo "  minikube stop            - Stop cluster"
echo "  minikube delete          - Delete cluster"
echo ""