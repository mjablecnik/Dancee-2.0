@echo off
REM Dancee Server - Fly.io Deployment Script for Windows
REM Fully automated deployment with minimal user interaction

setlocal enabledelayedexpansion

echo ╔════════════════════════════════════════╗
echo ║   Dancee Server - Fly.io Deployment   ║
echo ║        Automated Setup ^& Deploy        ║
echo ╚════════════════════════════════════════╝
echo.

set APP_NAME=dancee-server
set SERVICE_ACCOUNT_FILE=secrets\dancee-b5c0d-firebase-adminsdk-fbsvc-1584be4511.json
set DEFAULT_SWAGGER_USER=admin

REM Check if fly CLI is installed
echo [1/8] Checking Fly CLI...
where fly >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Fly CLI is not installed
    echo.
    echo Install it from: https://fly.io/docs/hands-on/install-flyctl/
    echo.
    pause
    exit /b 1
)
echo [OK] Fly CLI is installed

REM Check if logged in
echo [2/8] Checking Fly.io authentication...
fly auth whoami >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] Not logged in to Fly.io
    echo [INFO] Opening login page...
    fly auth login
    
    REM Verify login succeeded
    fly auth whoami >nul 2>nul
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Login failed
        pause
        exit /b 1
    )
)
for /f "tokens=*" %%i in ('fly auth whoami 2^>nul') do set FLY_USER=%%i
echo [OK] Logged in to Fly.io as !FLY_USER!

REM Check if service account file exists
echo [3/8] Checking Firebase service account...
if not exist "%SERVICE_ACCOUNT_FILE%" (
    echo [ERROR] Service account file not found: %SERVICE_ACCOUNT_FILE%
    echo.
    echo Please ensure your Firebase service account key is in the secrets\ folder
    pause
    exit /b 1
)
echo [OK] Service account file found

REM Check if app exists, create if not
echo [4/8] Checking Fly.io app...
fly apps list 2>nul | findstr /C:"%APP_NAME%" >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] App '%APP_NAME%' does not exist
    echo [INFO] Creating app automatically...
    
    fly apps create %APP_NAME% --org personal >nul 2>nul
    if %ERRORLEVEL% EQU 0 (
        echo [OK] App '%APP_NAME%' created successfully
    ) else (
        echo [ERROR] Failed to create app
        echo You may need to choose a different app name or organization
        pause
        exit /b 1
    )
) else (
    echo [OK] App '%APP_NAME%' exists
)

REM Check and set Firebase credentials
echo [5/8] Configuring Firebase credentials...
fly secrets list --app %APP_NAME% 2>nul | findstr /C:"FIREBASE_SERVICE_ACCOUNT_JSON" >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] Firebase credentials not set
    echo [INFO] Setting Firebase credentials automatically...
    
    set FIREBASE_JSON=
    for /f "delims=" %%i in ('type "%SERVICE_ACCOUNT_FILE%"') do set FIREBASE_JSON=!FIREBASE_JSON!%%i
    fly secrets set FIREBASE_SERVICE_ACCOUNT_JSON="!FIREBASE_JSON!" --app %APP_NAME% >nul 2>nul
    fly secrets set FIREBASE_SERVICE_ACCOUNT_PATH="" --app %APP_NAME% >nul 2>nul
    
    echo [OK] Firebase credentials configured
) else (
    echo [OK] Firebase credentials already configured
)

REM Check and set Swagger credentials
echo [6/8] Configuring Swagger authentication...
fly secrets list --app %APP_NAME% 2>nul | findstr /C:"SWAGGER_USER" >nul 2>nul
set SWAGGER_USER_EXISTS=%ERRORLEVEL%
fly secrets list --app %APP_NAME% 2>nul | findstr /C:"SWAGGER_PASSWORD" >nul 2>nul
set SWAGGER_PASS_EXISTS=%ERRORLEVEL%

if %SWAGGER_USER_EXISTS% NEQ 0 (
    echo [WARNING] Swagger credentials not set
    echo.
    echo Please provide Swagger credentials for API documentation:
    
    set /p SWAGGER_USER="Swagger username (default: admin): "
    if "!SWAGGER_USER!"=="" set SWAGGER_USER=%DEFAULT_SWAGGER_USER%
    
    :password_loop
    set /p SWAGGER_PASSWORD="Swagger password: "
    if "!SWAGGER_PASSWORD!"=="" (
        echo [ERROR] Password cannot be empty
        goto password_loop
    )
    
    set /p SWAGGER_PASSWORD_CONFIRM="Confirm password: "
    if not "!SWAGGER_PASSWORD!"=="!SWAGGER_PASSWORD_CONFIRM!" (
        echo [ERROR] Passwords do not match. Try again.
        goto password_loop
    )
    
    echo [INFO] Setting Swagger credentials...
    fly secrets set SWAGGER_USER=!SWAGGER_USER! --app %APP_NAME% >nul 2>nul
    fly secrets set SWAGGER_PASSWORD=!SWAGGER_PASSWORD! --app %APP_NAME% >nul 2>nul
    
    echo [OK] Swagger credentials configured
) else (
    echo [OK] Swagger credentials already configured
)

REM Show current configuration
echo.
echo [7/8] Current configuration:
echo ═══════════════════════════════════════
fly secrets list --app %APP_NAME% 2>nul | findstr /N "^" | findstr "^[1-9]:"
echo ═══════════════════════════════════════
echo.

REM Deploy
echo [8/8] Deploying to Fly.io...
echo [INFO] Starting deployment...
echo.

fly deploy --app %APP_NAME%
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ╔════════════════════════════════════════╗
    echo ║     Deployment Successful! 🚀          ║
    echo ╚════════════════════════════════════════╝
    echo.
    
    REM Get app URL
    for /f "tokens=3" %%i in ('fly info --app %APP_NAME% 2^>nul ^| findstr "Hostname"') do set APP_URL=%%i
    
    echo [OK] Your app is live!
    echo.
    echo URLs:
    echo   API:     https://!APP_URL!/
    echo   Swagger: https://!APP_URL!/api
    echo   Events:  https://!APP_URL!/events/list
    echo.
    echo Useful commands:
    echo   task deploy-logs     - View live logs
    echo   task deploy-status   - Check app status
    echo   task deploy-open     - Open in browser
    echo   task deploy-restart  - Restart app
    echo.
    
    set /p VIEW_LOGS="View deployment logs? (y/n): "
    if /i "!VIEW_LOGS!"=="y" (
        echo.
        echo Showing logs (Ctrl+C to exit):
        echo.
        fly logs --app %APP_NAME%
    )
) else (
    echo.
    echo ╔════════════════════════════════════════╗
    echo ║      Deployment Failed ✗               ║
    echo ╚════════════════════════════════════════╝
    echo.
    echo Troubleshooting:
    echo   1. Check logs: task deploy-logs
    echo   2. Check status: task deploy-status
    echo   3. Try again: task deploy
    echo.
    pause
    exit /b 1
)

pause
