# Ingress Setup Guide

## ✅ What's Been Done

1. ✅ NGINX Ingress Controller installed
2. ✅ Frontend ConfigMap updated to use relative URLs (`NEXT_PUBLIC_BASE_URL: ""`)
3. ✅ Ingress resource already applied

## 🔧 Next Steps Required

### Step 1: Rebuild Frontend Image (REQUIRED)

Since `NEXT_PUBLIC_BASE_URL` is embedded at build time, you need to rebuild the frontend:

```powershell
# Navigate to frontend directory
cd ..\frontend

# Rebuild with empty BASE_URL (relative URLs)
docker build -t adithyahewage/automobile-frontend:latest --build-arg NEXT_PUBLIC_BASE_URL="" .

# Push to Docker Hub
docker push adithyahewage/automobile-frontend:latest

# Restart frontend deployment to pull new image
cd ..\deployment
kubectl rollout restart deployment/automobile-frontend

# Wait for rollout to complete
kubectl rollout status deployment/automobile-frontend
```

### Step 2: Configure Hosts File

Add the Ingress hostname to your hosts file so `automobile.local` resolves to localhost.

**Windows (Run PowerShell as Administrator):**

```powershell
# Check if entry already exists
Select-String -Path "C:\Windows\System32\drivers\etc\hosts" -Pattern "automobile.local"

# If not found, add it
Add-Content -Path "C:\Windows\System32\drivers\etc\hosts" -Value "`n127.0.0.1    automobile.local"
```

**Or manually edit:**
1. Open `C:\Windows\System32\drivers\etc\hosts` as Administrator
2. Add this line:
   ```
   127.0.0.1    automobile.local
   ```
3. Save the file

### Step 3: Access the Application

After rebuilding and configuring hosts:

- **Frontend**: http://automobile.local
- **Backend API**: http://automobile.local/api
- **Swagger UI**: http://automobile.local/swagger-ui
- **Health Check**: http://automobile.local/actuator/health

## 🔍 Verify Setup

```powershell
# Check Ingress Controller is running
kubectl get pods -n ingress-nginx

# Check Ingress status
kubectl get ingress

# Check frontend pods are using new config
kubectl get pods -l app=automobile-frontend

# View frontend logs
kubectl logs -f deployment/automobile-frontend
```

## 🎯 How It Works

1. Browser requests: `http://automobile.local/api/auth/login`
2. Ingress Controller receives request
3. Routes `/api/*` → `automobile-backend-service:8080`
4. Backend pod handles request
5. ✅ Works because frontend uses relative URLs (`/api/auth/login`)

## 🐛 Troubleshooting

### Issue: Can't access automobile.local

**Solution:**
- Verify hosts file entry: `ping automobile.local` should resolve to 127.0.0.1
- Check Ingress Controller: `kubectl get pods -n ingress-nginx`
- Check Ingress: `kubectl describe ingress automobile-ingress`

### Issue: Frontend still uses old BASE_URL

**Solution:**
- Verify ConfigMap: `kubectl get configmap frontend-config -o yaml`
- Rebuild frontend image with `NEXT_PUBLIC_BASE_URL=""`
- Restart deployment: `kubectl rollout restart deployment/automobile-frontend`

### Issue: 404 errors on /api routes

**Solution:**
- Check Ingress routing: `kubectl describe ingress automobile-ingress`
- Verify backend service: `kubectl get svc automobile-backend-service`
- Check backend pods: `kubectl get pods -l app=automobile-backend`

## 📝 Summary

- ✅ Ingress Controller: Installed
- ✅ ConfigMap: Updated to relative URLs
- ⏳ Frontend: Needs rebuild with empty BASE_URL
- ⏳ Hosts file: Needs configuration
- ✅ Ingress: Already applied

After completing the steps above, access via `http://automobile.local` and everything should work!

