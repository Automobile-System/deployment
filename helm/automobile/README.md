# Automobile Helm Chart

This Helm chart deploys the Automobile Enterprise System on Kubernetes.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Docker images pushed to a container registry

## Installation

1. Update `values.yaml` with your image repository and database credentials:

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

2. Install the chart:

```bash
helm install automobile ./helm/automobile
```

3. Upgrade the chart:

```bash
helm upgrade automobile ./helm/automobile
```

4. Uninstall the chart:

```bash
helm uninstall automobile
```

## Configuration

See `values.yaml` for all configurable parameters.

## Accessing the Application

- Frontend: `http://automobile.local` (if ingress is enabled)
- Backend API: `http://automobile.local/api`
- Health Check: `http://automobile.local/actuator/health`
- Swagger UI: `http://automobile.local/swagger-ui`

## Troubleshooting

```bash
# Check pod status
kubectl get pods

# View logs
kubectl logs -f deployment/automobile-backend
kubectl logs -f deployment/automobile-frontend

# Describe resources
kubectl describe deployment automobile-backend
kubectl describe service automobile-backend-service
```

