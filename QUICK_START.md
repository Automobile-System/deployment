# Quick Start Guide

## Docker Compose (Fastest Way)

1. **Create `.env` file:**
   ```bash
   cd deployment
   cp .env.example .env
   # Edit .env with your database credentials
   ```

2. **Start services:**
   ```bash
   docker-compose up -d
   ```

3. **Access:**
   - Frontend: http://localhost:3000
   - Backend: http://localhost:8080

## Kubernetes (Production)

1. **Build and push images:**
   ```bash
   docker build -t yourusername/automobile-backend:latest ../backend
   docker build -t yourusername/automobile-frontend:latest ../frontend
   docker push yourusername/automobile-backend:latest
   docker push yourusername/automobile-frontend:latest
   ```

2. **Update manifests:**
   - Edit `k8s/backend-deployment.yaml` and `k8s/frontend-deployment.yaml`
   - Replace `yourusername` with your Docker Hub username
   - Update `k8s/neon-secret.yaml` with your database credentials

3. **Deploy:**
   ```bash
   kubectl apply -f k8s/
   ```

4. **Access:**
   ```bash
   kubectl port-forward service/automobile-frontend-service 3000:3000
   # Open http://localhost:3000
   ```

## Helm (Bonus)

1. **Update `helm/automobile/values.yaml`** with your image names and credentials

2. **Install:**
   ```bash
   helm install automobile ./helm/automobile
   ```

## Troubleshooting

- **Services won't start**: Check logs with `docker-compose logs` or `kubectl logs`
- **Database connection errors**: Verify credentials in `.env` or Kubernetes secrets
- **Frontend can't reach backend**: Check `NEXT_PUBLIC_BASE_URL` environment variable

For detailed instructions, see [README.md](./README.md).

