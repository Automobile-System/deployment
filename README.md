# Automobile Project Deployment Guide

This repository coordinates containerized deployment for the Automobile application using Docker Compose for local orchestration and Kubernetes for production deployment.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Docker Compose Deployment](#docker-compose-deployment)
3. [Kubernetes Deployment](#kubernetes-deployment)
4. [Helm Chart Deployment (Bonus)](#helm-chart-deployment-bonus)
5. [Architecture Overview](#architecture-overview)
6. [Troubleshooting](#troubleshooting)

## Prerequisites

### For Docker Compose
- Docker Desktop 4.0+ (Windows/Mac) or Docker Engine 20.10+ (Linux)
- Docker Compose 2.0+
- 4GB+ RAM available
- Neon PostgreSQL database credentials

### For Kubernetes
- Kubernetes cluster (1.19+) or Docker Desktop with Kubernetes enabled
- `kubectl` CLI (bundled with Docker Desktop)
- Container registry account (Docker Hub, GitHub Container Registry, etc.)
- `helm` CLI 3.0+ (for Helm deployment)

## Docker Compose Deployment

### Step 1: Configure Environment Variables

Create a `.env` file in the `deployment/` directory:

```bash
cd deployment
cp .env.example .env
```

Edit `.env` with your actual values:

```env
# Database Configuration (Neon PostgreSQL)
SPRING_DATASOURCE_URL=jdbc:postgresql://your-neon-host:5432/neondb?sslmode=require
SPRING_DATASOURCE_USERNAME=your_username
SPRING_DATASOURCE_PASSWORD=your_password

# Application Ports
BACKEND_PORT=8080
FRONTEND_PORT=3000

# Frontend Configuration
NEXT_PUBLIC_BASE_URL=http://localhost:8080

# JWT Secret Key
APP_SECURITY_JWT_SECRET_KEY=your-secure-random-secret-key-here

# CORS Allowed Origins
APP_SECURITY_CORS_ALLOWED_ORIGINS=http://localhost:3000

# JPA Configuration
SPRING_JPA_HIBERNATE_DDL_AUTO=update
```

### Step 2: Build and Start Services

```bash
# Build images
docker-compose build

# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Step 3: Verify Deployment

- Backend: `http://localhost:8080/actuator/health`
- Frontend: `http://localhost:3000`
- Swagger UI: `http://localhost:8080/swagger-ui.html`

### Step 4: Monitor Services

```bash
# Check service status
docker-compose ps

# View backend logs
docker-compose logs -f backend

# View frontend logs
docker-compose logs -f frontend

# Check resource usage
docker stats
```

## Kubernetes Deployment

### Step 1: Build and Push Docker Images

```bash
# Login to Docker Hub (or your registry)
docker login

# Build backend image
cd ../backend
docker build -t yourusername/automobile-backend:latest .
docker push yourusername/automobile-backend:latest

# Build frontend image
cd ../frontend
docker build -t yourusername/automobile-frontend:latest --build-arg NEXT_PUBLIC_BASE_URL=http://automobile-backend-service:8080 .
docker push yourusername/automobile-frontend:latest
```

### Step 2: Update Kubernetes Manifests

Edit the following files in `k8s/` directory:

1. **Update image references** in:
   - `backend-deployment.yaml` (line 19)
   - `frontend-deployment.yaml` (line 19)

   Replace `yourusername` with your Docker Hub username.

2. **Update database credentials** in:
   - `neon-configmap.yaml` - Update the database URL
   - `neon-secret.yaml` - Update username and password

   **Important**: For production, use Kubernetes Secrets management or external secret management tools.

### Step 3: Enable Kubernetes (Docker Desktop)

1. Open Docker Desktop
2. Go to Settings → Kubernetes
3. Enable Kubernetes
4. Wait for Kubernetes to start (green indicator)

Verify:
```bash
kubectl version --client
kubectl get nodes
```

### Step 4: Apply Kubernetes Manifests

```bash
cd deployment/k8s

# Apply ConfigMaps and Secrets first
kubectl apply -f neon-configmap.yaml
kubectl apply -f neon-secret.yaml
kubectl apply -f frontend-configmap.yaml

# Apply Deployments
kubectl apply -f backend-deployment.yaml
kubectl apply -f frontend-deployment.yaml

# Apply Services
kubectl apply -f backend-service.yaml
kubectl apply -f frontend-service.yaml

# Apply Ingress (optional)
kubectl apply -f ingress.yaml

# Or apply all at once
kubectl apply -f .
```

### Step 5: Verify Deployment

```bash
# Check pods
kubectl get pods

# Check services
kubectl get svc

# Check deployments
kubectl get deployments

# View pod logs
kubectl logs -f deployment/automobile-backend
kubectl logs -f deployment/automobile-frontend

# Describe resources
kubectl describe pod <pod-name>
kubectl describe service automobile-backend-service
```

### Step 6: Access the Application

**Option 1: Port Forwarding**

```bash
# Forward frontend port
kubectl port-forward service/automobile-frontend-service 3000:3000

# Forward backend port
kubectl port-forward service/automobile-backend-service 8080:8080
```

Access:
- Frontend: `http://localhost:3000`
- Backend: `http://localhost:8080`

**Option 2: LoadBalancer (Docker Desktop)**

```bash
# Get external IP
kubectl get svc automobile-frontend-service
```

**Option 3: Ingress (if enabled)**

Add to `/etc/hosts` (Linux/Mac) or `C:\Windows\System32\drivers\etc\hosts` (Windows):
```
127.0.0.1 automobile.local
```

Access: `http://automobile.local`

## Helm Chart Deployment (Bonus)

### Step 1: Update Helm Values

Edit `helm/automobile/values.yaml`:

```yaml
backend:
  image:
    repository: yourusername/automobile-backend
    tag: latest

frontend:
  image:
    repository: yourusername/automobile-frontend
    tag: latest

database:
  config:
    url: "your-neon-postgresql-url"
  secret:
    username: "your-username"
    password: "your-password"
```

### Step 2: Install Helm Chart

```bash
cd deployment

# Install
helm install automobile ./helm/automobile

# Upgrade
helm upgrade automobile ./helm/automobile

# Check status
helm status automobile

# List releases
helm list

# Uninstall
helm uninstall automobile
```

### Step 3: Verify Deployment

```bash
# Check all resources
kubectl get all -l app.kubernetes.io/instance=automobile

# View Helm values
helm get values automobile
```

## Architecture Overview

### Docker Compose Architecture

```
┌─────────────────────────────────────────┐
│         Docker Network                   │
│  ┌──────────────┐  ┌──────────────┐    │
│  │   Frontend   │  │   Backend    │    │
│  │  (Port 3000) │  │  (Port 8080) │    │
│  └──────┬───────┘  └──────┬───────┘    │
│         │                  │            │
└─────────┼──────────────────┼────────────┘
          │                  │
          │                  │
          ▼                  ▼
    ┌─────────────────────────────┐
    │   Neon PostgreSQL (Cloud)   │
    └─────────────────────────────┘
```

### Kubernetes Architecture

```
┌─────────────────────────────────────────────────────┐
│                  Kubernetes Cluster                │
│                                                     │
│  ┌──────────────┐         ┌──────────────┐       │
│  │   Frontend   │         │   Backend    │       │
│  │  Deployment  │         │  Deployment  │       │
│  │  (2 replicas)│         │  (2 replicas)│       │
│  └──────┬───────┘         └──────┬───────┘       │
│         │                        │                │
│  ┌──────▼───────┐         ┌──────▼───────┐       │
│  │   Service    │         │   Service    │       │
│  │ (LoadBalancer)│        │ (ClusterIP)  │       │
│  └──────┬───────┘         └──────┬───────┘       │
│         │                        │                │
│         └──────────┬────────────┘                │
│                    │                              │
│              ┌─────▼──────┐                      │
│              │   Ingress   │                      │
│              └────────────┘                      │
│                                                     │
└─────────────────────────────────────────────────────┘
                    │
                    ▼
        ┌─────────────────────────┐
        │  Neon PostgreSQL (Cloud)│
        └─────────────────────────┘
```

### Key Components

#### ConfigMaps
- **neon-db-config**: Database connection URL
- **frontend-config**: Frontend environment variables

#### Secrets
- **neon-db-secret**: Database credentials (username/password)

#### Services
- **automobile-backend-service**: ClusterIP service for backend (internal)
- **automobile-frontend-service**: LoadBalancer service for frontend (external)

#### Deployments
- **automobile-backend**: Backend application with health checks
- **automobile-frontend**: Frontend application with health checks

## Troubleshooting

### Docker Compose Issues

**Problem**: Services won't start
```bash
# Check logs
docker-compose logs

# Rebuild images
docker-compose build --no-cache

# Remove volumes and restart
docker-compose down -v
docker-compose up -d
```

**Problem**: Database connection errors
- Verify `.env` file has correct database credentials
- Check network connectivity to Neon PostgreSQL
- Ensure SSL mode is set correctly

**Problem**: Frontend can't reach backend
- Verify `NEXT_PUBLIC_BASE_URL` is set correctly
- Check backend health: `curl http://localhost:8080/actuator/health`
- Ensure both services are on the same Docker network

### Kubernetes Issues

**Problem**: Pods stuck in Pending
```bash
# Check pod events
kubectl describe pod <pod-name>

# Check node resources
kubectl top nodes
```

**Problem**: Image pull errors
```bash
# Verify image exists
docker pull yourusername/automobile-backend:latest

# Check image pull secrets
kubectl get secrets
```

**Problem**: Services not accessible
```bash
# Check service endpoints
kubectl get endpoints

# Check service selector matches pod labels
kubectl get pods --show-labels
kubectl get svc -o yaml
```

**Problem**: ConfigMap/Secret not found
```bash
# Verify resources exist
kubectl get configmaps
kubectl get secrets

# Check deployment references
kubectl describe deployment automobile-backend
```

### Common Commands

```bash
# View all resources
kubectl get all

# Delete and recreate
kubectl delete -f k8s/
kubectl apply -f k8s/

# Scale deployments
kubectl scale deployment automobile-backend --replicas=3

# Execute commands in pods
kubectl exec -it <pod-name> -- /bin/sh
```

## Security Best Practices

1. **Never commit secrets**: Use `.env` files (gitignored) or Kubernetes Secrets
2. **Use image tags**: Avoid `latest` tag in production
3. **Resource limits**: Always set CPU/memory limits
4. **Network policies**: Implement network policies for pod-to-pod communication
5. **RBAC**: Configure proper role-based access control
6. **TLS**: Enable TLS for ingress in production

## Production Checklist

- [ ] Update all image references to specific tags
- [ ] Configure proper resource limits
- [ ] Set up monitoring and logging
- [ ] Configure backup strategy for database
- [ ] Enable TLS/SSL for ingress
- [ ] Set up CI/CD pipeline
- [ ] Configure horizontal pod autoscaling
- [ ] Set up alerting and monitoring
- [ ] Document runbooks for common issues
- [ ] Perform load testing

## Additional Resources

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [Neon PostgreSQL Documentation](https://neon.tech/docs/)

## Support

For issues or questions:
1. Check logs: `docker-compose logs` or `kubectl logs`
2. Review this README
3. Check application-specific documentation in `backend/README.md` and `frontend/README.md`
