#!/bin/bash
set -euo pipefail

echo "=============================================="
echo "  Air Quality System - K8s Deployment Script  "
echo "=============================================="
echo ""

# ─── Color helpers ───────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok()   { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
fail() { echo -e "${RED}❌ $1${NC}"; exit 1; }

# ─── Resolve project root ───────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MANIFESTS_DIR="$SCRIPT_DIR/manifests"

echo "📁 Project root: $PROJECT_ROOT"
echo "📁 Manifests:    $MANIFESTS_DIR"
echo ""

# ─── Pre-flight checks ──────────────────────────
echo "🔍 Running pre-flight checks..."

if ! command -v minikube &>/dev/null; then
    fail "Minikube not found. Run setup-minikube.sh first."
fi

if ! command -v kubectl &>/dev/null; then
    fail "kubectl not found. Run setup-minikube.sh first."
fi

MINIKUBE_STATUS=$(minikube status --format='{{.Host}}' 2>/dev/null || echo "Stopped")
if [[ "$MINIKUBE_STATUS" != "Running" ]]; then
    fail "Minikube is not running. Start it with: minikube start"
fi

ok "Minikube is running"
echo ""

# ─── Build Docker images in Minikube ─────────────
echo "🐳 Configuring Docker to use Minikube's daemon..."
eval $(minikube docker-env)
ok "Docker now points to Minikube"

echo ""
echo "🔨 Building backend image..."
docker build -t airquality-backend:latest "$PROJECT_ROOT/backend"
ok "Backend image built"

echo ""
echo "🔨 Building frontend image..."
docker build -t airquality-frontend:latest "$PROJECT_ROOT/frontend"
ok "Frontend image built"

echo ""
echo "📦 Images available in Minikube:"
docker images | grep airquality || true
echo ""

# ─── Apply Kubernetes manifests ──────────────────
echo "🚀 Applying Kubernetes manifests..."
echo ""

# Apply in order (numbered files ensure correct ordering)
for manifest in "$MANIFESTS_DIR"/??-*.yaml; do
    echo "   Applying $(basename "$manifest")..."
    kubectl apply -f "$manifest"
done

ok "All manifests applied"
echo ""

# ─── Wait for pods to be ready ───────────────────
echo "⏳ Waiting for pods to become ready..."
echo ""

echo "   Waiting for PostgreSQL..."
kubectl wait --for=condition=ready pod -l app=db -n airquality --timeout=120s 2>/dev/null || warn "DB pod not ready yet"

echo "   Waiting for Backend (may take ~60s for ML model training)..."
kubectl wait --for=condition=ready pod -l app=backend -n airquality --timeout=180s 2>/dev/null || warn "Backend pod not ready yet"

echo "   Waiting for Frontend..."
kubectl wait --for=condition=ready pod -l app=frontend -n airquality --timeout=120s 2>/dev/null || warn "Frontend pod not ready yet"

echo "   Waiting for Nginx..."
kubectl wait --for=condition=ready pod -l app=nginx -n airquality --timeout=120s 2>/dev/null || warn "Nginx pod not ready yet"

echo ""

# ─── Show deployment status ──────────────────────
echo "📊 Deployment Status:"
echo ""
kubectl get pods -n airquality -o wide
echo ""
kubectl get services -n airquality
echo ""

# ─── Get access URL ──────────────────────────────
echo "=============================================="
echo "  Deployment Complete!                        "
echo "=============================================="
echo ""
echo "📍 Access the application (use port-forward on macOS):"
echo ""
echo "   kubectl port-forward -n airquality svc/nginx 8080:80"
echo ""
echo "   Then open:  http://localhost:8080"
echo "   Health:     http://localhost:8080/health"
echo "   API:        http://localhost:8080/api/locations"
echo ""
echo "📊 Useful commands:"
echo "   kubectl get pods -n airquality              - List pods"
echo "   kubectl logs -f <pod-name> -n airquality    - View pod logs"
echo "   kubectl describe pod <pod-name> -n airquality - Debug a pod"
echo "   minikube dashboard                          - Open K8s dashboard"
echo ""
echo "🛑 Teardown:"
echo "   ./k8s/teardown.sh"
echo ""

# ─── Quick health check via port-forward ─────────
echo "🔍 Running quick health check..."
kubectl port-forward -n airquality svc/nginx 8080:80 &>/dev/null &
PF_PID=$!
sleep 5
if curl -s --max-time 10 "http://localhost:8080/health" >/dev/null 2>&1; then
    ok "Health endpoint is responding!"
    echo "   Response: $(curl -s --max-time 10 "http://localhost:8080/health")"
else
    warn "Health endpoint not responding yet. The backend may still be starting up (ML model training takes ~30s)."
    echo "   Try: curl http://localhost:8080/health"
fi
kill $PF_PID 2>/dev/null || true
echo ""
echo "💡 To keep the app accessible, run in a separate terminal:"
echo "   kubectl port-forward -n airquality svc/nginx 8080:80"
echo ""
