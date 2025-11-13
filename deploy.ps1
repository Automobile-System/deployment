# Automobile Project Deployment Script (PowerShell)
# This script helps deploy the application using Docker Compose or Kubernetes

param(
    [Parameter(Position=0)]
    [ValidateSet("compose", "k8s", "helm")]
    [string]$DeploymentType = "compose",
    
    [Parameter(Position=1)]
    [string]$Action = "up"
)

$ErrorActionPreference = "Stop"

switch ($DeploymentType) {
    "compose" {
        Write-Host "🚀 Deploying with Docker Compose..." -ForegroundColor Cyan
        
        if (-not (Test-Path ".env")) {
            Write-Host "⚠️  .env file not found. Creating from .env.example..." -ForegroundColor Yellow
            if (Test-Path ".env.example") {
                Copy-Item ".env.example" ".env"
                Write-Host "✅ Created .env file. Please update it with your credentials." -ForegroundColor Green
                exit 1
            } else {
                Write-Host "❌ .env.example not found. Please create .env file manually." -ForegroundColor Red
                exit 1
            }
        }
        
        switch ($Action) {
            { $_ -in "up", "start" } {
                Write-Host "📦 Building and starting services..." -ForegroundColor Cyan
                docker-compose up -d --build
                Write-Host "✅ Services started!" -ForegroundColor Green
                Write-Host "📊 View logs: docker-compose logs -f" -ForegroundColor Yellow
                Write-Host "🌐 Frontend: http://localhost:3000" -ForegroundColor Yellow
                Write-Host "🌐 Backend: http://localhost:8080" -ForegroundColor Yellow
            }
            { $_ -in "down", "stop" } {
                Write-Host "🛑 Stopping services..." -ForegroundColor Cyan
                docker-compose down
                Write-Host "✅ Services stopped!" -ForegroundColor Green
            }
            "restart" {
                Write-Host "🔄 Restarting services..." -ForegroundColor Cyan
                docker-compose restart
                Write-Host "✅ Services restarted!" -ForegroundColor Green
            }
            "logs" {
                docker-compose logs -f
            }
            { $_ -in "ps", "status" } {
                docker-compose ps
            }
            default {
                Write-Host "Usage: .\deploy.ps1 compose [up|down|restart|logs|ps]" -ForegroundColor Yellow
                exit 1
            }
        }
    }
    
    "k8s" {
        Write-Host "🚀 Deploying to Kubernetes..." -ForegroundColor Cyan
        
        # Check if kubectl is available
        if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
            Write-Host "❌ kubectl not found. Please install kubectl." -ForegroundColor Red
            exit 1
        }
        
        switch ($Action) {
            { $_ -in "apply", "deploy" } {
                Write-Host "📦 Applying Kubernetes manifests..." -ForegroundColor Cyan
                kubectl apply -f k8s/
                Write-Host "✅ Manifests applied!" -ForegroundColor Green
                Write-Host "⏳ Waiting for pods to be ready..." -ForegroundColor Yellow
                kubectl wait --for=condition=ready pod -l app=automobile-backend --timeout=120s 2>$null
                kubectl wait --for=condition=ready pod -l app=automobile-frontend --timeout=120s 2>$null
                Write-Host "📊 Check status: kubectl get pods" -ForegroundColor Yellow
            }
            { $_ -in "delete", "remove" } {
                Write-Host "🗑️  Removing Kubernetes resources..." -ForegroundColor Cyan
                kubectl delete -f k8s/
                Write-Host "✅ Resources removed!" -ForegroundColor Green
            }
            "status" {
                kubectl get pods,svc,deployments
            }
            "logs" {
                Write-Host "📋 Backend logs:" -ForegroundColor Cyan
                kubectl logs -f deployment/automobile-backend
            }
            default {
                Write-Host "Usage: .\deploy.ps1 k8s [apply|delete|status|logs]" -ForegroundColor Yellow
                exit 1
            }
        }
    }
    
    "helm" {
        Write-Host "🚀 Deploying with Helm..." -ForegroundColor Cyan
        
        # Check if helm is available
        if (-not (Get-Command helm -ErrorAction SilentlyContinue)) {
            Write-Host "❌ helm not found. Please install Helm." -ForegroundColor Red
            exit 1
        }
        
        $ReleaseName = if ($args.Count -gt 0) { $args[0] } else { "automobile" }
        
        switch ($Action) {
            "install" {
                Write-Host "📦 Installing Helm chart..." -ForegroundColor Cyan
                helm install $ReleaseName ./helm/automobile
                Write-Host "✅ Chart installed!" -ForegroundColor Green
            }
            "upgrade" {
                Write-Host "🔄 Upgrading Helm chart..." -ForegroundColor Cyan
                helm upgrade $ReleaseName ./helm/automobile
                Write-Host "✅ Chart upgraded!" -ForegroundColor Green
            }
            "uninstall" {
                Write-Host "🗑️  Uninstalling Helm chart..." -ForegroundColor Cyan
                helm uninstall $ReleaseName
                Write-Host "✅ Chart uninstalled!" -ForegroundColor Green
            }
            "status" {
                helm status $ReleaseName
            }
            default {
                Write-Host "Usage: .\deploy.ps1 helm [install|upgrade|uninstall|status] [release-name]" -ForegroundColor Yellow
                exit 1
            }
        }
    }
}


