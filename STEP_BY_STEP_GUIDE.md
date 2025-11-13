# Step-by-Step Deployment Guide

This guide will walk you through deploying the Automobile application from start to finish.

## Prerequisites Checklist

Before starting, ensure you have:
- [ ] Docker Desktop installed and running
- [ ] Docker Hub account (or another container registry)
- [ ] Neon PostgreSQL database credentials
- [ ] Git installed
- [ ] Terminal/PowerShell access

---

## Phase 1: Local Testing with Docker Compose

### Step 1: Configure Environment Variables

1. Navigate to the deployment directory:
   ```bash
   cd deployment
   ```

2. Create `.env` file:
   ```bash
   # On Windows PowerShell
   Copy-Item .env.example .env
   
   # On Linux/Mac
   cp .env.example .env
   ```

3. Edit `.env` file with your actual values:
   ```env
   # Database Configuration (Get these from Neon dashboard)
   SPRING_DATASOURCE_URL=jdbc:postgresql://your-neon-host:5432/neondb?sslmode=require
   SPRING_DATASOURCE_USERNAME=your_username
   SPRING_DATASOURCE_PASSWORD=your_password
   
   # Application Ports (defaults are fine)
   BACKEND_PORT=8080
   FRONTEND_PORT=3000
   
   # Frontend Configuration
   NEXT_PUBLIC_BASE_URL=http://localhost:8080
   
   # JWT Secret Key (generate a random string)
   APP_SECURITY_JWT_SECRET_KEY=YourSecureRandomSecretKeyHere123456789
   
   # CORS (defaults are fine)
   APP_SECURITY_CORS_ALLOWED_ORIGINS=http://localhost:3000
   
   # JPA Configuration
   SPRING_JPA_HIBERNATE_DDL_AUTO=update
   ```

### Step 2: Build and Test Locally

1. Build the Docker images:
   ```bash
   docker-compose build
   ```
   This will take several minutes the first time.

2. Start the services:
   ```bash
   docker-compose up -d
   ```

3. Check service status:
   ```bash
   docker-compose ps
   ```
   Both services should show "Up" status.

4. View logs to ensure everything is working:
   ```bash
   # Backend logs
   docker-compose logs -f backend
   
   # Frontend logs (in another terminal)
   docker-compose logs -f frontend
   ```

5. Test the application:
   - Frontend: Open http://localhost:3000 in your browser
   - Backend Health: Open http://localhost:8080/actuator/health
   - Swagger UI: Open http://localhost:8080/swagger-ui.html

6. If everything works, stop the services:
   ```bash
   docker-compose down
   ```

---

## Phase 2: Prepare Images for Kubernetes

### Step 3: Login to Docker Hub

1. Login to Docker Hub:
   ```bash
   docker login
   ```
   Enter your Docker Hub username and password.

### Step 4: Build Production Images

1. Build backend image:
   ```bash
   cd ../backend
   docker build -t YOUR_DOCKERHUB_USERNAME/automobile-backend:latest .
   ```
   Replace `YOUR_DOCKERHUB_USERNAME` with your actual Docker Hub username.

2. Build frontend image:
   ```bash
   cd ../frontend
   docker build -t YOUR_DOCKERHUB_USERNAME/automobile-frontend:latest --build-arg NEXT_PUBLIC_BASE_URL=http://automobile-backend-service:8080 .
   ```

### Step 5: Push Images to Docker Hub

1. Push backend image:
   ```bash
   docker push YOUR_DOCKERHUB_USERNAME/automobile-backend:latest
   ```

2. Push frontend image:
   ```bash
   docker push YOUR_DOCKERHUB_USERNAME/automobile-frontend:latest
   ```

**Note**: This may take several minutes depending on your internet speed.

---

## Phase 3: Configure Kubernetes Manifests

### Step 6: Update Image References

1. Navigate to k8s directory:
   ```bash
   cd ../deployment/k8s
   ```

2. Update `backend-deployment.yaml`:
   - Open the file
   - Find line 19: `image: yourusername/automobile-backend:latest`
   - Replace `yourusername` with your Docker Hub username
   - Save the file

3. Update `frontend-deployment.yaml`:
   - Open the file
   - Find line 19: `image: yourusername/automobile-frontend:latest`
   - Replace `yourusername` with your Docker Hub username
   - Save the file

### Step 7: Update Database Credentials

1. Update `neon-configmap.yaml`:
   - Open the file
   - Update the `SPRING_DATASOURCE_URL` with your Neon PostgreSQL URL
   - Save the file

2. Update `neon-secret.yaml`:
   - Open the file
   - Update `SPRING_DATASOURCE_USERNAME` with your database username
   - Update `SPRING_DATASOURCE_PASSWORD` with your database password
   - Save the file

3. Update `frontend-configmap.yaml`:
   - Verify `NEXT_PUBLIC_BASE_URL` is set to: `http://automobile-backend-service:8080`
   - This should already be correct, but double-check

---

## Phase 4: Enable Kubernetes

### Step 8: Enable Kubernetes in Docker Desktop

1. Open Docker Desktop
2. Click on the **Settings** icon (gear icon)
3. Go to **Kubernetes** in the left sidebar
4. Check **Enable Kubernetes**
5. Click **Apply & Restart**
6. Wait for Kubernetes to start (green indicator in bottom right)

### Step 9: Verify Kubernetes Installation

1. Open a new terminal/PowerShell
2. Verify kubectl is working:
   ```bash
   kubectl version --client
   ```

3. Check Kubernetes nodes:
   ```bash
   kubectl get nodes
   ```
   You should see `docker-desktop` node.

---

## Phase 5: Deploy to Kubernetes

### Step 10: Apply Kubernetes Manifests

1. Navigate to deployment/k8s directory:
   ```bash
   cd deployment/k8s
   ```

2. Apply all manifests in order:
   ```bash
   # Apply ConfigMaps first
   kubectl apply -f neon-configmap.yaml
   kubectl apply -f frontend-configmap.yaml
   
   # Apply Secrets
   kubectl apply -f neon-secret.yaml
   
   # Apply Deployments
   kubectl apply -f backend-deployment.yaml
   kubectl apply -f frontend-deployment.yaml
   
   # Apply Services
   kubectl apply -f backend-service.yaml
   kubectl apply -f frontend-service.yaml
   
   # Apply Ingress (optional)
   kubectl apply -f ingress.yaml
   ```

   **OR apply all at once:**
   ```bash
   kubectl apply -f .
   ```

### Step 11: Verify Deployment

1. Check pods status:
   ```bash
   kubectl get pods
   ```
   Wait until all pods show `Running` status (may take 1-2 minutes).

2. Check services:
   ```bash
   kubectl get svc
   ```

3. Check deployments:
   ```bash
   kubectl get deployments
   ```

4. View pod logs if needed:
   ```bash
   # Backend logs
   kubectl logs -f deployment/automobile-backend
   
   # Frontend logs
   kubectl logs -f deployment/automobile-frontend
   ```

### Step 12: Access the Application

**Option 1: Port Forwarding (Recommended for Testing)**

1. Forward frontend port:
   ```bash
   kubectl port-forward service/automobile-frontend-service 3000:3000
   ```
   Keep this terminal open.

2. In another terminal, forward backend port:
   ```bash
   kubectl port-forward service/automobile-backend-service 8080:8080
   ```

3. Access the application:
   - Frontend: http://localhost:3000
   - Backend: http://localhost:8080
   - Swagger: http://localhost:8080/swagger-ui.html

**Option 2: LoadBalancer (Docker Desktop)**

1. Get the external IP:
   ```bash
   kubectl get svc automobile-frontend-service
   ```
   Note the EXTERNAL-IP (may show as `<pending>` initially).

2. Access via the external IP or use port forwarding if pending.

---

## Phase 6: Helm Deployment (Optional Bonus)

### Step 13: Install Helm (if not installed)

**Windows (Chocolatey):**
```powershell
choco install kubernetes-helm
```

**Mac (Homebrew):**
```bash
brew install helm
```

**Linux:**
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### Step 14: Update Helm Values

1. Navigate to helm directory:
   ```bash
   cd ../helm/automobile
   ```

2. Edit `values.yaml`:
   - Update `backend.image.repository` with your Docker Hub username
   - Update `frontend.image.repository` with your Docker Hub username
   - Update `database.config.url` with your Neon PostgreSQL URL
   - Update `database.secret.username` and `database.secret.password`

### Step 15: Deploy with Helm

1. Install the Helm chart:
   ```bash
   cd ../..
   helm install automobile ./helm/automobile
   ```

2. Check status:
   ```bash
   helm status automobile
   ```

3. Verify deployment:
   ```bash
   kubectl get pods
   ```

4. Upgrade if needed:
   ```bash
   helm upgrade automobile ./helm/automobile
   ```

---

## Troubleshooting Common Issues

### Issue: Pods stuck in Pending

**Solution:**
```bash
# Check pod events
kubectl describe pod <pod-name>

# Check node resources
kubectl top nodes
```

### Issue: Image pull errors

**Solution:**
```bash
# Verify image exists
docker pull YOUR_DOCKERHUB_USERNAME/automobile-backend:latest

# Check if you're logged in
docker login
```

### Issue: Database connection errors

**Solution:**
```bash
# Check ConfigMap
kubectl get configmap neon-db-config -o yaml

# Check Secret
kubectl get secret neon-db-secret -o yaml

# Verify credentials are correct
```

### Issue: Frontend can't reach backend

**Solution:**
```bash
# Check frontend ConfigMap
kubectl get configmap frontend-config -o yaml

# Verify NEXT_PUBLIC_BASE_URL is correct
# Should be: http://automobile-backend-service:8080
```

### Issue: Services not accessible

**Solution:**
```bash
# Check service endpoints
kubectl get endpoints

# Check service selector matches pod labels
kubectl get pods --show-labels
```

---

## Quick Reference Commands

### Docker Compose
```bash
# Start
docker-compose up -d

# Stop
docker-compose down

# View logs
docker-compose logs -f

# Rebuild
docker-compose build --no-cache
```

### Kubernetes
```bash
# Get all resources
kubectl get all

# Get pods
kubectl get pods

# Get services
kubectl get svc

# View logs
kubectl logs -f deployment/automobile-backend

# Delete everything
kubectl delete -f k8s/
```

### Helm
```bash
# Install
helm install automobile ./helm/automobile

# Upgrade
helm upgrade automobile ./helm/automobile

# Uninstall
helm uninstall automobile

# List releases
helm list
```

---

## Final Checklist

Before submitting, ensure:

- [ ] Docker Compose deployment works locally
- [ ] Images are pushed to Docker Hub
- [ ] Kubernetes manifests are updated with correct image names
- [ ] Database credentials are correct in Kubernetes secrets
- [ ] All pods are running (`kubectl get pods`)
- [ ] Services are accessible via port-forwarding
- [ ] Application is functional (can login, view data, etc.)
- [ ] Helm chart is tested (if using Helm)
- [ ] Documentation is complete

---

## Next Steps After Deployment

1. **Monitor the application:**
   ```bash
   kubectl get pods -w
   ```

2. **Set up monitoring** (optional):
   - Configure Prometheus/Grafana
   - Set up log aggregation

3. **Scale if needed:**
   ```bash
   kubectl scale deployment automobile-backend --replicas=3
   ```

4. **Update application:**
   - Build new images
   - Push to registry
   - Update Kubernetes manifests or Helm values
   - Apply changes

---

## Need Help?

If you encounter issues:

1. Check logs: `kubectl logs -f deployment/<deployment-name>`
2. Describe resources: `kubectl describe pod <pod-name>`
3. Check events: `kubectl get events --sort-by=.metadata.creationTimestamp`
4. Review the troubleshooting section above
5. Check the main README.md for detailed documentation

Good luck with your deployment! 🚀


