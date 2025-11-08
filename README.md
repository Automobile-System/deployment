# Automobile Project Deployment

This repository coordinates local container orchestration and Kubernetes rollout
for the Automobile application. It assumes the frontend and backend source
trees live alongside this `deployment/` directory (as siblings `../frontend` and
`../backend`). Update paths if you embed the sources differently.

## Prerequisites

- Docker Desktop (with Kubernetes support enabled)
- Docker Hub (or another container registry) account
- `kubectl` CLI (bundled with Docker Desktop)
- (Optional) `helm` CLI if you plan to package the manifests later

## 1. Local Verification with Docker Compose

From `deployment/`:

```bash
docker-compose build
docker-compose up
```

- Backend responds on `http://localhost:8080`
- Frontend responds on `http://localhost:3000` and should reach the backend at
  `http://localhost:8080`

Press `Ctrl+C` to stop the stack when finished.

> If you prefer not to execute the build, at least validate that the contexts
> in `docker-compose.yml` point at the correct source folders.

## 2. Publish Images to Docker Hub

Kubernetes clusters pull images from a registry. Replace
`yourusername` with your Docker Hub handle (or adjust for another registry).

```bash
docker login

# Tag images built by docker-compose
docker tag deployment_backend yourusername/automobile-backend:latest
docker tag deployment_frontend yourusername/automobile-frontend:latest

# Push to Docker Hub
docker push yourusername/automobile-backend:latest
docker push yourusername/automobile-frontend:latest
```

If you change the `image:` value inside the manifests, keep the registry and tag
in sync.

## 3. Enable Kubernetes (Docker Desktop)

1. Docker Desktop → Settings → Kubernetes → **Enable Kubernetes**
2. Wait for the Kubernetes indicator to turn green.
3. Verify:
   ```bash
   kubectl version --client
   kubectl get nodes
   ```

You should see a single node named `docker-desktop`.

## 4. Kubernetes Manifests

The manifest set lives under `deployment/k8s/`:

- `neon-secret.yaml` – Credentials for Neon database (replace with your real
  username/password in secure workflows).
- `neon-configmap.yaml` – Connection URL for the Neon PostgreSQL instance.
- `backend-deployment.yaml` / `backend-service.yaml`
- `frontend-deployment.yaml` / `frontend-service.yaml`
- `ingress.yaml` (optional) – Routes `automobile.local` to the frontend service.

Update container image references before applying if you pushed to a custom tag.

## 5. Apply to the Cluster

```bash
kubectl apply -f k8s/
kubectl get pods
kubectl get svc
```

You should see one pod and one service each for frontend and backend.

## 6. Access the Application

- For `LoadBalancer` service (Docker Desktop automatically forwards):
  ```bash
  kubectl get svc automobile-frontend-service
  ```
- If the external IP is pending, port-forward:
  ```bash
  kubectl port-forward service/automobile-frontend-service 3000:3000
  ```

Open `http://localhost:3000`. The frontend contacts the backend through the
ClusterIP service `automobile-backend-service`.

## 7. Monitor and Troubleshoot

```bash
kubectl logs -f deployment/automobile-backend
kubectl logs -f deployment/automobile-frontend
kubectl describe pod <pod-name>
```

## 8. Optional Helm Packaging (+5 Marks)

```bash
mkdir -p helm
cd helm
helm create automobile
# replace templates/ contents with files from ../k8s/
helm install automobile ./automobile
```

## 9. Documentation Checklist

Include in your project report/presentation:

- Architecture & networking overview diagram
- Compose vs. Kubernetes deployment instructions
- Explanation of ConfigMap, Secret, Service, and Ingress roles
- Notes on registry usage and image tagging
- Lessons learned / troubleshooting notes
