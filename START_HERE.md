# 🚀 START HERE - Quick Deployment Guide

## What You Need Right Now

1. **Docker Desktop** - Make sure it's running
2. **Docker Hub Account** - Sign up at https://hub.docker.com (free)
3. **Neon PostgreSQL Credentials** - From your Neon dashboard

---

## Immediate Next Steps (5 minutes)

### Step 1: Create Environment File

Open PowerShell/Terminal in the `deployment` folder and run:

```powershell
# Windows PowerShell
Copy-Item .env.example .env

# Or manually create .env file
```

### Step 2: Edit `.env` File

Open `.env` file and update these values:

```env
# REQUIRED: Get from Neon Dashboard
SPRING_DATASOURCE_URL=jdbc:postgresql://YOUR-NEON-HOST:5432/neondb?sslmode=require
SPRING_DATASOURCE_USERNAME=your_neon_username
SPRING_DATASOURCE_PASSWORD=your_neon_password

# REQUIRED: Your Docker Hub username
# (We'll use this later, but set it now)
# Example: DOCKERHUB_USERNAME=johnsmith

# OPTIONAL: Generate a random string for JWT secret
APP_SECURITY_JWT_SECRET_KEY=GenerateARandomStringHere123456789
```

**How to get Neon credentials:**
1. Go to https://console.neon.tech
2. Select your project
3. Go to "Connection Details"
4. Copy the connection string and extract:
   - Host (e.g., `ep-holy-river-a8f0y6nq-pooler.eastus2.azure.neon.tech`)
   - Database name (usually `neondb`)
   - Username (e.g., `neondb_owner`)
   - Password (shown in connection string)

### Step 3: Test Locally First

```powershell
# Build images (takes 5-10 minutes first time)
docker-compose build

# Start services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f backend
```

**Expected Result:**
- Both `automobile-backend` and `automobile-frontend` show "Up"
- Backend logs show "Started AutomobileApplication"
- No database connection errors

**Test the application:**
- Open http://localhost:3000
- Open http://localhost:8080/actuator/health (should show `{"status":"UP"}`)

If everything works, proceed to next steps!

---

## Full Deployment Path

Choose your path:

### Path A: Docker Compose Only (Simplest)
✅ **Good for**: Local testing, development, quick demo
- Follow: `STEP_BY_STEP_GUIDE.md` → Phase 1 & 2 only
- Time: ~15 minutes

### Path B: Kubernetes Deployment (Required)
✅ **Good for**: Production-like environment, meeting requirements
- Follow: `STEP_BY_STEP_GUIDE.md` → All phases
- Time: ~30-45 minutes

### Path C: Helm Deployment (Bonus Points)
✅ **Good for**: Maximum marks, professional deployment
- Follow: `STEP_BY_STEP_GUIDE.md` → All phases including Helm
- Time: ~45-60 minutes

---

## Recommended Order

1. ✅ **Start Here** (this file) - 5 min
2. ✅ **Test Locally** (`STEP_BY_STEP_GUIDE.md` Phase 1-2) - 15 min
3. ✅ **Deploy to Kubernetes** (`STEP_BY_STEP_GUIDE.md` Phase 3-6) - 30 min
4. ✅ **Helm Bonus** (`STEP_BY_STEP_GUIDE.md` Phase 6) - 15 min

---

## Quick Commands Cheat Sheet

```powershell
# === LOCAL TESTING ===
docker-compose build          # Build images
docker-compose up -d          # Start services
docker-compose logs -f        # View logs
docker-compose down           # Stop services

# === DOCKER HUB ===
docker login                  # Login to Docker Hub
docker build -t YOUR_USERNAME/automobile-backend:latest ../backend
docker build -t YOUR_USERNAME/automobile-frontend:latest ../frontend
docker push YOUR_USERNAME/automobile-backend:latest
docker push YOUR_USERNAME/automobile-frontend:latest

# === KUBERNETES ===
kubectl apply -f k8s/         # Deploy everything
kubectl get pods              # Check pods
kubectl logs -f deployment/automobile-backend
kubectl port-forward service/automobile-frontend-service 3000:3000

# === HELM ===
helm install automobile ./helm/automobile
helm status automobile
```

---

## Common First-Time Issues

### Issue: "docker-compose: command not found"
**Solution**: Make sure Docker Desktop is running and restart terminal

### Issue: "Cannot connect to database"
**Solution**: 
- Check `.env` file has correct Neon credentials
- Verify Neon database is accessible
- Check connection string format

### Issue: "Image pull errors in Kubernetes"
**Solution**: 
- Make sure you've pushed images to Docker Hub
- Verify image names match in Kubernetes manifests
- Check you're logged into Docker Hub

### Issue: "Kubernetes not enabled"
**Solution**: 
- Docker Desktop → Settings → Kubernetes → Enable Kubernetes
- Wait for green indicator

---

## Need Help?

1. Check `STEP_BY_STEP_GUIDE.md` for detailed instructions
2. Check `README.md` for comprehensive documentation
3. Check `CHECKLIST.md` to track your progress
4. Review logs: `docker-compose logs` or `kubectl logs`

---

## Ready to Start?

1. ✅ Open `.env` file and add your Neon credentials
2. ✅ Run `docker-compose build`
3. ✅ Run `docker-compose up -d`
4. ✅ Test http://localhost:3000
5. ✅ If it works, proceed to `STEP_BY_STEP_GUIDE.md`

**Good luck! 🎉**

