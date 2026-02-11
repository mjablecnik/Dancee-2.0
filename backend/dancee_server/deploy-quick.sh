#!/bin/bash

# Dancee Server - Quick Deploy Script
# Fast deployment without prompts (uses defaults)

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

cd "$(dirname "${BASH_SOURCE[0]}")"

echo -e "${BLUE}🚀 Quick Deploy to Fly.io${NC}"
echo ""

# Check prerequisites
if ! command -v fly &> /dev/null; then
    echo "Error: Fly CLI not installed"
    exit 1
fi

if ! fly auth whoami &> /dev/null; then
    echo "Error: Not logged in to Fly.io"
    echo "Run: fly auth login"
    exit 1
fi

# Deploy
echo -e "${BLUE}Deploying...${NC}"
fly deploy --app dancee-server

echo ""
echo -e "${GREEN}✓ Deployment complete!${NC}"
echo ""
echo "View logs: fly logs"
echo "Check status: fly status"
