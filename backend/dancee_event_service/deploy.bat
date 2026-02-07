@echo off
REM Deploy script for dancee-event-service to Fly.io (Windows)
REM Usage: deploy.bat

setlocal enabledelayedexpansion

set APP_NAME=dancee-event-service
set IMAGE_NAME=dancee-event-service
set FLY_REGISTRY=registry.fly.io

echo.
echo 🚀 Starting deployment process for %APP_NAME%
echo.

REM Step 1: Build Docker image from root directory
echo 📦 Building Docker image...
cd ..\..
docker build -f backend/dancee_event_service/Dockerfile -t %IMAGE_NAME%:latest .
if errorlevel 1 (
    echo ❌ Docker build failed
    exit /b 1
)
echo ✅ Docker image built successfully
echo.

REM Step 2: Authenticate with Fly.io Docker registry
echo 🔐 Authenticating with Fly.io Docker registry...
fly auth docker
if errorlevel 1 (
    echo ❌ Authentication failed
    exit /b 1
)
echo ✅ Authentication successful
echo.

REM Step 3: Tag image for Fly.io registry
echo 🏷️  Tagging image for Fly.io registry...
docker tag %IMAGE_NAME%:latest %FLY_REGISTRY%/%APP_NAME%:latest
if errorlevel 1 (
    echo ❌ Tagging failed
    exit /b 1
)
echo ✅ Image tagged: %FLY_REGISTRY%/%APP_NAME%:latest
echo.

REM Step 4: Push image to Fly.io registry
echo ⬆️  Pushing image to Fly.io registry...
docker push %FLY_REGISTRY%/%APP_NAME%:latest
if errorlevel 1 (
    echo ❌ Push failed
    exit /b 1
)
echo ✅ Image pushed successfully
echo.

REM Step 5: Deploy to Fly.io
echo 🚢 Deploying to Fly.io...
fly deploy --image %FLY_REGISTRY%/%APP_NAME%:latest --config backend/dancee_event_service/fly.toml
if errorlevel 1 (
    echo ❌ Deployment failed
    exit /b 1
)
echo.
echo ✅ Deployment complete!
echo 🌐 Your app is available at: https://%APP_NAME%.fly.dev

endlocal
