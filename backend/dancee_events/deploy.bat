@echo off
REM Deployment script for Fly.io (Windows)
REM This script deploys the dancee_events service to Fly.io

echo Deploying dancee_events to Fly.io...

REM Check if fly CLI is installed
where fly >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Fly CLI is not installed. Please install it first:
    echo    https://fly.io/docs/hands-on/install-flyctl/
    exit /b 1
)

REM Check if Firebase credentials file exists
if not exist "secrets\dancee-b5c0d-firebase-adminsdk-fbsvc-1584be4511.json" (
    echo Firebase credentials file not found!
    echo Expected: secrets\dancee-b5c0d-firebase-adminsdk-fbsvc-1584be4511.json
    exit /b 1
)

REM Set Firebase credentials as secret
echo Setting Firebase credentials as Fly.io secret...
for /f "delims=" %%i in ('type secrets\dancee-b5c0d-firebase-adminsdk-fbsvc-1584be4511.json') do set FIREBASE_JSON=%%i
fly secrets set FIREBASE_SERVICE_ACCOUNT_JSON="%FIREBASE_JSON%" --app dancee-events

REM Deploy to Fly.io
echo Deploying application...
fly deploy --app dancee-events

echo Deployment complete!
echo Your app is available at: https://dancee-events.fly.dev
echo.
echo Useful commands:
echo    fly logs --app dancee-events          # View logs
echo    fly status --app dancee-events        # Check status
echo    fly ssh console --app dancee-events   # SSH into machine
