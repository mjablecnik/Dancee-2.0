#!/bin/bash

# Deploy script for dancee-event-service to Fly.io
# Usage: ./deploy.sh

set -e  # Exit on error

APP_NAME="dancee-event-service"
IMAGE_NAME="dancee-event-service"
FLY_REGISTRY="registry.fly.io"

echo "🚀 Starting deployment process for $APP_NAME"
echo ""

# Step 1: Build Docker image from root directory
echo "📦 Building Docker image..."
cd ../..
docker build -f backend/dancee_event_service/Dockerfile -t $IMAGE_NAME:latest .
echo "✅ Docker image built successfully"
echo ""

# Step 2: Authenticate with Fly.io Docker registry
echo "🔐 Authenticating with Fly.io Docker registry..."
fly auth docker
echo "✅ Authentication successful"
echo ""

# Step 3: Tag image for Fly.io registry
echo "🏷️  Tagging image for Fly.io registry..."
docker tag $IMAGE_NAME:latest $FLY_REGISTRY/$APP_NAME:latest
echo "✅ Image tagged: $FLY_REGISTRY/$APP_NAME:latest"
echo ""

# Step 4: Push image to Fly.io registry
echo "⬆️  Pushing image to Fly.io registry..."
docker push $FLY_REGISTRY/$APP_NAME:latest
echo "✅ Image pushed successfully"
echo ""

# Step 5: Deploy to Fly.io
echo "🚢 Deploying to Fly.io..."
fly deploy --image $FLY_REGISTRY/$APP_NAME:latest --config backend/dancee_event_service/fly.toml
echo ""
echo "✅ Deployment complete!"
echo "🌐 Your app is available at: https://$APP_NAME.fly.dev"
