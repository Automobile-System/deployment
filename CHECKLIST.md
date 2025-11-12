# Deployment Checklist

Use this checklist to track your deployment progress.

## Phase 1: Preparation ✅

- [ ] Docker Desktop installed and running
- [ ] Docker Hub account created
- [ ] Neon PostgreSQL credentials ready
- [ ] Terminal/PowerShell ready

## Phase 2: Local Testing 🧪

- [ ] Created `.env` file from `.env.example`
- [ ] Updated `.env` with database credentials
- [ ] Updated `.env` with JWT secret key
- [ ] Built Docker images: `docker-compose build`
- [ ] Started services: `docker-compose up -d`
- [ ] Verified backend health: http://localhost:8080/actuator/health
- [ ] Verified frontend: http://localhost:3000
- [ ] Tested login functionality
- [ ] Stopped services: `docker-compose down`

## Phase 3: Image Preparation 📦

- [ ] Logged into Docker Hub: `docker login`
- [ ] Built backend image with your Docker Hub username
- [ ] Built frontend image with your Docker Hub username
- [ ] Pushed backend image to Docker Hub
- [ ] Pushed frontend image to Docker Hub
- [ ] Verified images exist on Docker Hub

## Phase 4: Kubernetes Configuration ⚙️

- [ ] Updated `k8s/backend-deployment.yaml` with Docker Hub username
- [ ] Updated `k8s/frontend-deployment.yaml` with Docker Hub username
- [ ] Updated `k8s/neon-configmap.yaml` with database URL
- [ ] Updated `k8s/neon-secret.yaml` with database credentials
- [ ] Verified `k8s/frontend-configmap.yaml` has correct backend URL

## Phase 5: Kubernetes Setup 🚀

- [ ] Enabled Kubernetes in Docker Desktop
- [ ] Verified Kubernetes is running (green indicator)
- [ ] Verified kubectl works: `kubectl version --client`
- [ ] Verified nodes: `kubectl get nodes`

## Phase 6: Kubernetes Deployment 🎯

- [ ] Applied ConfigMaps: `kubectl apply -f k8s/neon-configmap.yaml`
- [ ] Applied ConfigMaps: `kubectl apply -f k8s/frontend-configmap.yaml`
- [ ] Applied Secrets: `kubectl apply -f k8s/neon-secret.yaml`
- [ ] Applied Backend Deployment: `kubectl apply -f k8s/backend-deployment.yaml`
- [ ] Applied Frontend Deployment: `kubectl apply -f k8s/frontend-deployment.yaml`
- [ ] Applied Backend Service: `kubectl apply -f k8s/backend-service.yaml`
- [ ] Applied Frontend Service: `kubectl apply -f k8s/frontend-service.yaml`
- [ ] Applied Ingress: `kubectl apply -f k8s/ingress.yaml` (optional)

## Phase 7: Verification ✅

- [ ] All pods running: `kubectl get pods` (all show Running)
- [ ] Services created: `kubectl get svc`
- [ ] Deployments created: `kubectl get deployments`
- [ ] Backend logs show no errors: `kubectl logs deployment/automobile-backend`
- [ ] Frontend logs show no errors: `kubectl logs deployment/automobile-frontend`
- [ ] Port-forwarded frontend: `kubectl port-forward service/automobile-frontend-service 3000:3000`
- [ ] Port-forwarded backend: `kubectl port-forward service/automobile-backend-service 8080:8080`
- [ ] Accessed frontend: http://localhost:3000
- [ ] Accessed backend: http://localhost:8080
- [ ] Tested application functionality

## Phase 8: Helm Deployment (Bonus) 🎁

- [ ] Helm installed: `helm version`
- [ ] Updated `helm/automobile/values.yaml` with image names
- [ ] Updated `helm/automobile/values.yaml` with database credentials
- [ ] Installed Helm chart: `helm install automobile ./helm/automobile`
- [ ] Verified Helm deployment: `helm status automobile`
- [ ] Tested Helm upgrade: `helm upgrade automobile ./helm/automobile`

## Phase 9: Documentation 📝

- [ ] Screenshot of `docker-compose ps` output
- [ ] Screenshot of `kubectl get pods` output
- [ ] Screenshot of `kubectl get svc` output
- [ ] Screenshot of application running
- [ ] Documented any issues encountered
- [ ] Documented solutions to issues

## Quick Command Reference

```bash
# Docker Compose
docker-compose build
docker-compose up -d
docker-compose logs -f
docker-compose down

# Docker Images
docker build -t YOUR_USERNAME/automobile-backend:latest ../backend
docker build -t YOUR_USERNAME/automobile-frontend:latest ../frontend
docker push YOUR_USERNAME/automobile-backend:latest
docker push YOUR_USERNAME/automobile-frontend:latest

# Kubernetes
kubectl apply -f k8s/
kubectl get pods
kubectl get svc
kubectl logs -f deployment/automobile-backend
kubectl port-forward service/automobile-frontend-service 3000:3000

# Helm
helm install automobile ./helm/automobile
helm status automobile
helm upgrade automobile ./helm/automobile
```

---

**Status**: ⬜ Not Started | 🟡 In Progress | ✅ Complete

