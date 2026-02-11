#!/bin/bash

# Deployment script for Fly.io
# This script deploys the dancee_events service to Fly.io

set -e

echo "🚀 Deploying dancee_events to Fly.io..."

# Check if fly CLI is installed
if ! command -v fly &> /dev/null; then
    echo "❌ Fly CLI is not installed. Please install it first:"
    echo "   curl -L https://fly.io/install.sh | sh"
    exit 1
fi

# Check if logged in to Fly.io
if ! fly auth whoami &> /dev/null; then
    echo "❌ Not logged in to Fly.io. Please run: fly auth login"
    exit 1
fi

# Check if Firebase credentials file exists
if [ ! -f "secrets/dancee-b5c0d-firebase-adminsdk-fbsvc-1584be4511.json" ]; then
    echo "❌ Firebase credentials file not found!"
    echo "   Expected: secrets/dancee-b5c0d-firebase-adminsdk-fbsvc-1584be4511.json"
    exit 1
fi

# Set Firebase credentials as secret (if not already set)
echo "📝 Setting Firebase credentials as Fly.io secret..."
fly secrets set FIREBASE_SERVICE_ACCOUNT_JSON="$(cat secrets/dancee-b5c0d-firebase-adminsdk-fbsvc-1584be4511.json)" --app dancee-events

# Deploy to Fly.io
echo "🚢 Deploying application..."
fly deploy --app dancee-events

echo "✅ Deployment complete!"
echo "🌐 Your app is available at: https://dancee-events.fly.dev"
echo ""
echo "📊 Useful commands:"
echo "   fly logs --app dancee-events          # View logs"
echo "   fly status --app dancee-events        # Check status"
echo "   fly ssh console --app dancee-events   # SSH into machine"
