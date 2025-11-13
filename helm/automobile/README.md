# Automobile Helm Chart

This Helm chart deploys the Automobile application to Kubernetes.

## Important Note About Linter Warnings

**The YAML linter warnings you see are FALSE POSITIVES.**

These template files contain Helm/Go template syntax (e.g., `{{ include "automobile.fullname" . }}`), which the YAML linter doesn't understand. The templates are **valid and will work correctly** when Helm processes them.

### Why You See Errors

- YAML linters expect pure YAML
- Helm templates use Go template syntax: `{{ }}`
- The linter flags template expressions as errors
- **These are NOT real errors** - Helm will render them correctly

### How to Verify Templates

If you have Helm installed, you can verify the templates:

```bash
# Dry-run to see rendered output
helm template . --debug

# Validate chart
helm lint .

# Install with dry-run
helm install automobile . --dry-run --debug
```

### Template Files

All template files in this directory are valid Helm templates:
- `backend-deployment.yaml` - Backend Kubernetes Deployment
- `frontend-deployment.yaml` - Frontend Kubernetes Deployment
- `backend-service.yaml` - Backend Kubernetes Service
- `frontend-service.yaml` - Frontend Kubernetes Service
- `configmap.yaml` - ConfigMaps for database and frontend config
- `secret.yaml` - Secret for database credentials
- `ingress.yaml` - Ingress for external access
- `_helpers.tpl` - Helper template functions

## Usage

1. Update `values.yaml` with your configuration:
   - Docker Hub image names
   - Database credentials
   - Resource limits

2. Install the chart:
   ```bash
   helm install automobile .
   ```

3. Upgrade the chart:
   ```bash
   helm upgrade automobile .
   ```

4. Uninstall the chart:
   ```bash
   helm uninstall automobile
   ```

## Configuration

See `values.yaml` for all configurable values.
