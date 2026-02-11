#!/bin/bash

# Dancee Server - Fly.io Deployment Script
# Fully automated deployment with minimal user interaction

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="dancee-server"
SERVICE_ACCOUNT_FILE="secrets/dancee-b5c0d-firebase-adminsdk-fbsvc-1584be4511.json"
DEFAULT_SWAGGER_USER="admin"

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Dancee Server - Fly.io Deployment   ║${NC}"
echo -e "${BLUE}║        Automated Setup & Deploy        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Check if fly CLI is installed
echo -e "${CYAN}[1/8]${NC} Checking Fly CLI..."
if ! command -v fly &> /dev/null; then
    echo -e "${RED}✗ Fly CLI is not installed${NC}"
    echo ""
    echo "Install it with:"
    echo "  curl -L https://fly.io/install.sh | sh"
    echo ""
    exit 1
fi
echo -e "${GREEN}✓ Fly CLI is installed${NC}"

# Check if logged in
echo -e "${CYAN}[2/8]${NC} Checking Fly.io authentication..."
if ! fly auth whoami &> /dev/null; then
    echo -e "${YELLOW}⚠ Not logged in to Fly.io${NC}"
    echo -e "${BLUE}→ Opening login page...${NC}"
    fly auth login
    
    # Verify login succeeded
    if ! fly auth whoami &> /dev/null; then
        echo -e "${RED}✗ Login failed${NC}"
        exit 1
    fi
fi
echo -e "${GREEN}✓ Logged in to Fly.io as $(fly auth whoami 2>/dev/null)${NC}"

# Check if service account file exists
echo -e "${CYAN}[3/8]${NC} Checking Firebase service account..."
if [ ! -f "$SERVICE_ACCOUNT_FILE" ]; then
    echo -e "${RED}✗ Service account file not found: $SERVICE_ACCOUNT_FILE${NC}"
    echo ""
    echo "Please ensure your Firebase service account key is in the secrets/ folder"
    exit 1
fi
echo -e "${GREEN}✓ Service account file found${NC}"

# Check if app exists, create if not
echo -e "${CYAN}[4/8]${NC} Checking Fly.io app..."
if ! fly apps list 2>/dev/null | grep -q "^$APP_NAME"; then
    echo -e "${YELLOW}⚠ App '$APP_NAME' does not exist${NC}"
    echo -e "${BLUE}→ Creating app automatically...${NC}"
    
    if fly apps create "$APP_NAME" --org personal 2>/dev/null; then
        echo -e "${GREEN}✓ App '$APP_NAME' created successfully${NC}"
    else
        echo -e "${RED}✗ Failed to create app${NC}"
        echo "You may need to choose a different app name or organization"
        exit 1
    fi
else
    echo -e "${GREEN}✓ App '$APP_NAME' exists${NC}"
fi

# Check and set Firebase credentials
echo -e "${CYAN}[5/8]${NC} Configuring Firebase credentials..."
FIREBASE_SECRET_EXISTS=$(fly secrets list --app "$APP_NAME" 2>/dev/null | grep -c "FIREBASE_SERVICE_ACCOUNT_JSON" || true)

if [ "$FIREBASE_SECRET_EXISTS" -eq 0 ]; then
    echo -e "${YELLOW}⚠ Firebase credentials not set${NC}"
    echo -e "${BLUE}→ Setting Firebase credentials automatically...${NC}"
    
    fly secrets set FIREBASE_SERVICE_ACCOUNT_JSON="$(cat $SERVICE_ACCOUNT_FILE)" --app "$APP_NAME" > /dev/null 2>&1
    fly secrets set FIREBASE_SERVICE_ACCOUNT_PATH="" --app "$APP_NAME" > /dev/null 2>&1
    
    echo -e "${GREEN}✓ Firebase credentials configured${NC}"
else
    echo -e "${GREEN}✓ Firebase credentials already configured${NC}"
fi

# Check and set Swagger credentials
echo -e "${CYAN}[6/8]${NC} Configuring Swagger authentication..."
SWAGGER_USER_EXISTS=$(fly secrets list --app "$APP_NAME" 2>/dev/null | grep -c "SWAGGER_USER" || true)
SWAGGER_PASS_EXISTS=$(fly secrets list --app "$APP_NAME" 2>/dev/null | grep -c "SWAGGER_PASSWORD" || true)

if [ "$SWAGGER_USER_EXISTS" -eq 0 ] || [ "$SWAGGER_PASS_EXISTS" -eq 0 ]; then
    echo -e "${YELLOW}⚠ Swagger credentials not set${NC}"
    echo ""
    echo -e "${BLUE}Please provide Swagger credentials for API documentation:${NC}"
    
    # Get username
    read -p "Swagger username (default: admin): " SWAGGER_USER
    SWAGGER_USER=${SWAGGER_USER:-$DEFAULT_SWAGGER_USER}
    
    # Get password (hidden input)
    while true; do
        read -sp "Swagger password: " SWAGGER_PASSWORD
        echo
        
        if [ -z "$SWAGGER_PASSWORD" ]; then
            echo -e "${RED}✗ Password cannot be empty${NC}"
            continue
        fi
        
        read -sp "Confirm password: " SWAGGER_PASSWORD_CONFIRM
        echo
        
        if [ "$SWAGGER_PASSWORD" = "$SWAGGER_PASSWORD_CONFIRM" ]; then
            break
        else
            echo -e "${RED}✗ Passwords do not match. Try again.${NC}"
        fi
    done
    
    echo -e "${BLUE}→ Setting Swagger credentials...${NC}"
    fly secrets set SWAGGER_USER="$SWAGGER_USER" --app "$APP_NAME" > /dev/null 2>&1
    fly secrets set SWAGGER_PASSWORD="$SWAGGER_PASSWORD" --app "$APP_NAME" > /dev/null 2>&1
    
    echo -e "${GREEN}✓ Swagger credentials configured${NC}"
else
    echo -e "${GREEN}✓ Swagger credentials already configured${NC}"
fi

# Show current configuration
echo ""
echo -e "${CYAN}[7/8]${NC} Current configuration:"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
fly secrets list --app "$APP_NAME" 2>/dev/null | head -n 10
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo ""

# Deploy
echo -e "${CYAN}[8/8]${NC} Deploying to Fly.io..."
echo -e "${BLUE}→ Starting deployment...${NC}"
echo ""

if fly deploy --app "$APP_NAME"; then
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     Deployment Successful! 🚀          ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    
    # Get app URL
    APP_URL=$(fly info --app "$APP_NAME" 2>/dev/null | grep "Hostname" | awk '{print $3}')
    
    echo -e "${GREEN}✓ Your app is live!${NC}"
    echo ""
    echo -e "${BLUE}URLs:${NC}"
    echo -e "  ${CYAN}API:${NC}     https://$APP_URL/"
    echo -e "  ${CYAN}Swagger:${NC} https://$APP_URL/api"
    echo -e "  ${CYAN}Events:${NC}  https://$APP_URL/events/list"
    echo ""
    echo -e "${BLUE}Useful commands:${NC}"
    echo -e "  ${YELLOW}task deploy-logs${NC}     - View live logs"
    echo -e "  ${YELLOW}task deploy-status${NC}   - Check app status"
    echo -e "  ${YELLOW}task deploy-open${NC}     - Open in browser"
    echo -e "  ${YELLOW}task deploy-restart${NC}  - Restart app"
    echo ""
    
    # Ask if user wants to view logs
    read -p "View deployment logs? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${BLUE}Showing logs (Ctrl+C to exit):${NC}"
        echo ""
        fly logs --app "$APP_NAME"
    fi
else
    echo ""
    echo -e "${RED}╔════════════════════════════════════════╗${NC}"
    echo -e "${RED}║      Deployment Failed ✗               ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Troubleshooting:${NC}"
    echo "  1. Check logs: task deploy-logs"
    echo "  2. Check status: task deploy-status"
    echo "  3. Try again: task deploy"
    echo ""
    exit 1
fi
