#!/bin/bash

# Automobile Project Deployment Script
# This script helps deploy the application using Docker Compose or Kubernetes

set -e

DEPLOYMENT_TYPE=${1:-compose}
ACTION=${2:-up}

case "$DEPLOYMENT_TYPE" in
  compose|docker-compose)
    echo "🚀 Deploying with Docker Compose..."
    
    if [ ! -f .env ]; then
      echo "⚠️  .env file not found. Creating from .env.example..."
      if [ -f .env.example ]; then
        cp .env.example .env
        echo "✅ Created .env file. Please update it with your credentials."
        exit 1
      else
        echo "❌ .env.example not found. Please create .env file manually."
        exit 1
      fi
    fi
    
    case "$ACTION" in
      up|start)
        echo "📦 Building and starting services..."
        docker-compose up -d --build
        echo "✅ Services started!"
        echo "📊 View logs: docker-compose logs -f"
        echo "🌐 Frontend: http://localhost:3000"
        echo "🌐 Backend: http://localhost:8080"
        ;;
      down|stop)
        echo "🛑 Stopping services..."
        docker-compose down
        echo "✅ Services stopped!"
        ;;
      restart)
        echo "🔄 Restarting services..."
        docker-compose restart
        echo "✅ Services restarted!"
        ;;
      logs)
        docker-compose logs -f
        ;;
      ps|status)
        docker-compose ps
        ;;
      *)
        echo "Usage: ./deploy.sh compose [up|down|restart|logs|ps]"
        exit 1
        ;;
    esac
    ;;
    
  k8s|kubernetes)
    echo "🚀 Deploying to Kubernetes..."
    
    # Check if kubectl is available
    if ! command -v kubectl &> /dev/null; then
      echo "❌ kubectl not found. Please install kubectl."
      exit 1
    fi
    
    case "$ACTION" in
      apply|deploy)
        echo "📦 Applying Kubernetes manifests..."
        kubectl apply -f k8s/
        echo "✅ Manifests applied!"
        echo "⏳ Waiting for pods to be ready..."
        kubectl wait --for=condition=ready pod -l app=automobile-backend --timeout=120s || true
        kubectl wait --for=condition=ready pod -l app=automobile-frontend --timeout=120s || true
        echo "📊 Check status: kubectl get pods"
        ;;
      delete|remove)
        echo "🗑️  Removing Kubernetes resources..."
        kubectl delete -f k8s/
        echo "✅ Resources removed!"
        ;;
      status)
        kubectl get pods,svc,deployments
        ;;
      logs)
        echo "📋 Backend logs:"
        kubectl logs -f deployment/automobile-backend
        ;;
      *)
        echo "Usage: ./deploy.sh k8s [apply|delete|status|logs]"
        exit 1
        ;;
    esac
    ;;
    
  helm)
    echo "🚀 Deploying with Helm..."
    
    # Check if helm is available
    if ! command -v helm &> /dev/null; then
      echo "❌ helm not found. Please install Helm."
      exit 1
    fi
    
    RELEASE_NAME=${3:-automobile}
    
    case "$ACTION" in
      install)
        echo "📦 Installing Helm chart..."
        helm install $RELEASE_NAME ./helm/automobile
        echo "✅ Chart installed!"
        ;;
      upgrade)
        echo "🔄 Upgrading Helm chart..."
        helm upgrade $RELEASE_NAME ./helm/automobile
        echo "✅ Chart upgraded!"
        ;;
      uninstall)
        echo "🗑️  Uninstalling Helm chart..."
        helm uninstall $RELEASE_NAME
        echo "✅ Chart uninstalled!"
        ;;
      status)
        helm status $RELEASE_NAME
        ;;
      *)
        echo "Usage: ./deploy.sh helm [install|upgrade|uninstall|status] [release-name]"
        exit 1
        ;;
    esac
    ;;
    
  *)
    echo "Usage: ./deploy.sh [compose|k8s|helm] [action]"
    echo ""
    echo "Examples:"
    echo "  ./deploy.sh compose up          # Start with Docker Compose"
    echo "  ./deploy.sh k8s apply           # Deploy to Kubernetes"
    echo "  ./deploy.sh helm install        # Install Helm chart"
    exit 1
    ;;
esac


