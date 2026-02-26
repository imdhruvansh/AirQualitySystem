# Air Quality System — Kubernetes (Minikube) Deployment Guide

End-to-end guide for deploying the Air Quality Prediction System on Kubernetes using Minikube.

## Prerequisites

- **macOS** (the setup script is macOS-specific)
- **Docker Desktop** installed and running
- **4GB RAM** minimum available for Minikube
- **10GB disk space** free

## Architecture Overview

The same 4-container architecture from Docker Compose is replicated in Kubernetes:

```
┌─────────────────────────────────────────────────────────┐
│                  Minikube Cluster                        │
│                Namespace: airquality                     │
│                                                         │
│  ┌──────────┐    ┌──────────┐    ┌──────────────────┐   │
│  │  Nginx   │───▶│ Frontend │    │   PostgreSQL     │   │
│  │ NodePort │    │ ClusterIP│    │   ClusterIP      │   │
│  │ :30080   │    │ :80      │    │   :5432          │   │
│  └────┬─────┘    └──────────┘    └────────▲─────────┘   │
│       │                                   │             │
│       │          ┌──────────┐             │             │
│       └─────────▶│ Backend  │─────────────┘             │
│                  │ ClusterIP│                            │
│                  │ :5000    │                            │
│                  └──────────┘                            │
└─────────────────────────────────────────────────────────┘
        ▲
        │ http://<minikube-ip>:30080
        │
      User
```

## Step 1: Install Minikube & kubectl

Run the setup script (one-time only):

```bash
chmod +x k8s/setup-minikube.sh
./k8s/setup-minikube.sh
```

This script will:
- Install Homebrew (if missing)
- Install `kubectl` via Homebrew
- Install `minikube` via Homebrew
- Start a Minikube cluster (2 CPUs, 4GB RAM, 20GB disk)
- Enable the metrics-server and storage-provisioner addons
- Verify the cluster is healthy

### Manual Installation (alternative)

If you prefer to install manually:

```bash
# Install kubectl
brew install kubectl

# Install Minikube
brew install minikube

# Start cluster
minikube start --driver=docker --cpus=2 --memory=4096 --disk-size=20g
```

## Step 2: Deploy to Kubernetes

Run the deploy script:

```bash
chmod +x k8s/deploy.sh
./k8s/deploy.sh
```

This script will:
1. Verify Minikube is running
2. Point Docker CLI to Minikube's Docker daemon
3. Build `airquality-backend` and `airquality-frontend` images inside Minikube
4. Apply all Kubernetes manifests in order
5. Wait for all pods to become ready
6. Display the access URL and run a health check

### Manual Deployment (alternative)

```bash
# Point Docker to Minikube
eval $(minikube docker-env)

# Build images
docker build -t airquality-backend:latest ./backend
docker build -t airquality-frontend:latest ./frontend

# Apply manifests in order
kubectl apply -f k8s/manifests/00-namespace.yaml
kubectl apply -f k8s/manifests/01-secrets.yaml
kubectl apply -f k8s/manifests/02-db-init-configmap.yaml
kubectl apply -f k8s/manifests/03-nginx-configmap.yaml
kubectl apply -f k8s/manifests/04-postgres-pvc.yaml
kubectl apply -f k8s/manifests/05-postgres.yaml
kubectl apply -f k8s/manifests/06-backend.yaml
kubectl apply -f k8s/manifests/07-frontend.yaml
kubectl apply -f k8s/manifests/08-nginx.yaml

# Wait for pods
kubectl wait --for=condition=ready pod -l app=db -n airquality --timeout=120s
kubectl wait --for=condition=ready pod -l app=backend -n airquality --timeout=180s
kubectl wait --for=condition=ready pod -l app=frontend -n airquality --timeout=120s
kubectl wait --for=condition=ready pod -l app=nginx -n airquality --timeout=120s
```

## Step 3: Access the Application

### Option A: Port Forwarding (recommended for macOS)

On macOS with the Docker driver, the Minikube IP is not directly accessible.
Use `kubectl port-forward` in a **separate terminal**:

```bash
kubectl port-forward -n airquality svc/nginx 8080:80
```

Then open http://localhost:8080 in your browser.

### Option B: Using minikube service

```bash
minikube service nginx -n airquality --url
```

### Option C: Using Minikube IP + NodePort (Linux only)

```bash
echo "http://$(minikube ip):30080"
open "http://$(minikube ip):30080"
```

### Access Points (with port-forward on port 8080)

| Service   | URL                              |
|-----------|----------------------------------|
| Frontend  | `http://localhost:8080`          |
| API       | `http://localhost:8080/api/`     |
| Health    | `http://localhost:8080/health`   |

## Step 4: Verify the Deployment

### Check pod status

```bash
kubectl get pods -n airquality
```

Expected output (all should be `Running` and `1/1` ready):

```
NAME                        READY   STATUS    RESTARTS   AGE
backend-xxxxx               1/1     Running   0          2m
db-xxxxx                    1/1     Running   0          2m
frontend-xxxxx              1/1     Running   0          2m
nginx-xxxxx                 1/1     Running   0          2m
```

### Test API endpoints

```bash
# Ensure port-forward is running: kubectl port-forward -n airquality svc/nginx 8080:80
APP_URL="http://localhost:8080"

# Health check
curl $APP_URL/health

# Get locations
curl $APP_URL/api/locations

# Get current data for Delhi
curl $APP_URL/api/current/Delhi

# Get statistics
curl $APP_URL/api/stats/Delhi

# Generate prediction
curl -X POST $APP_URL/api/predict \
  -H "Content-Type: application/json" \
  -d '{"location": "Delhi", "hours_ahead": 24}'

# Add new data
curl -X POST $APP_URL/api/add-data \
  -H "Content-Type: application/json" \
  -d '{
    "location": "Delhi",
    "pm25": 156.3, "pm10": 210.5,
    "no2": 45.2, "so2": 12.3,
    "co": 1.2, "o3": 65.4,
    "temperature": 28.5, "humidity": 62.0, "wind_speed": 3.2
  }'
```

## Step 5: Monitoring & Debugging

### View logs

```bash
# All pods
kubectl logs -f deployment/backend -n airquality
kubectl logs -f deployment/frontend -n airquality
kubectl logs -f deployment/db -n airquality
kubectl logs -f deployment/nginx -n airquality
```

### Open K8s Dashboard

```bash
minikube dashboard
```

### Describe a pod (debugging)

```bash
kubectl describe pod -l app=backend -n airquality
```

### Exec into a pod

```bash
# Backend shell
kubectl exec -it deployment/backend -n airquality -- /bin/bash

# Database shell
kubectl exec -it deployment/db -n airquality -- psql -U admin -d airquality
```

### Check resource usage

```bash
kubectl top pods -n airquality
```

## Teardown

### Remove K8s resources (keep Minikube running)

```bash
chmod +x k8s/teardown.sh
./k8s/teardown.sh
```

### Stop Minikube (preserves cluster state)

```bash
minikube stop
```

### Delete Minikube entirely

```bash
minikube delete
```

## Manifest Files Reference

| File | Purpose |
|------|---------|
| `00-namespace.yaml` | Creates the `airquality` namespace |
| `01-secrets.yaml` | DB credentials (base64 encoded) |
| `02-db-init-configmap.yaml` | SQL schema + seed data |
| `03-nginx-configmap.yaml` | Nginx reverse proxy config |
| `04-postgres-pvc.yaml` | 1Gi persistent storage for DB |
| `05-postgres.yaml` | PostgreSQL Deployment + ClusterIP Service |
| `06-backend.yaml` | Flask backend Deployment + ClusterIP Service |
| `07-frontend.yaml` | React frontend Deployment + ClusterIP Service |
| `08-nginx.yaml` | Nginx Deployment + NodePort Service (30080) |

## Docker Compose vs Kubernetes Comparison

| Aspect | Docker Compose | Kubernetes |
|--------|---------------|------------|
| Config files | `docker-compose.yml` | `k8s/manifests/*.yaml` |
| Start command | `docker-compose up --build` | `./k8s/deploy.sh` |
| Stop command | `docker-compose down` | `./k8s/teardown.sh` |
| Networking | Bridge network | K8s ClusterIP Services |
| External access | Direct port mapping | NodePort (30080) |
| Secrets | Plain text in compose file | K8s Secrets (base64) |
| Persistence | Docker volumes | PersistentVolumeClaims |
| Health checks | Docker healthcheck | K8s readiness/liveness probes |
| Scaling | Manual | `kubectl scale` |

## Troubleshooting

### Pod stuck in `ImagePullBackOff`

This means the image wasn't built inside Minikube's Docker daemon:

```bash
eval $(minikube docker-env)
docker build -t airquality-backend:latest ./backend
docker build -t airquality-frontend:latest ./frontend
kubectl rollout restart deployment/backend -n airquality
kubectl rollout restart deployment/frontend -n airquality
```

### Backend CrashLoopBackOff

Usually means DB is not ready. Check backend logs:

```bash
kubectl logs -l app=backend -n airquality
```

If it shows DB connection errors, wait for the DB pod to be ready and restart:

```bash
kubectl rollout restart deployment/backend -n airquality
```

### Cannot access the app via browser

```bash
# Verify services
kubectl get svc -n airquality

# Check minikube IP
minikube ip

# Try using minikube service
minikube service nginx -n airquality
```

### PVC stuck in Pending

```bash
# Check if storage provisioner is enabled
minikube addons enable storage-provisioner

# Check PVC status
kubectl get pvc -n airquality
```

### Reset everything and start fresh

```bash
./k8s/teardown.sh
./k8s/deploy.sh
```
