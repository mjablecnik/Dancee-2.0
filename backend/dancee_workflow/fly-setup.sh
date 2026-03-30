#!/bin/sh

# Sets up Fly.io app and secrets from .env file.
# Creates the app if it doesn't exist, then sets secrets.
# Keys already defined in fly.toml [env] are skipped automatically.
#
# Usage:
#   cd backend/dancee_workflow
#   chmod +x fly-setup.sh
#   ./fly-setup.sh

set -e

ENV_FILE=".env"
TOML_FILE="fly.toml"

if [ ! -f "$TOML_FILE" ]; then
  echo "Error: $TOML_FILE not found. Run this script from the service directory."
  exit 1
fi

APP_NAME=$(grep '^app\s*=' "$TOML_FILE" | sed 's/^app\s*=\s*"\(.*\)"/\1/' | tr -d '\r')

if [ -z "$APP_NAME" ]; then
  echo "Error: Could not parse app name from $TOML_FILE"
  exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
  echo "Error: $ENV_FILE not found. Copy from .env.example and fill in values."
  exit 1
fi

if ! command -v fly > /dev/null 2>&1; then
  echo "Error: fly CLI not found. Install it: https://fly.io/docs/hands-on/install-flyctl/"
  exit 1
fi

# Create app on Fly.io if it doesn't exist yet
if ! fly apps list --json 2>/dev/null | grep -q "\"$APP_NAME\""; then
  echo "Creating app $APP_NAME on Fly.io..."
  fly launch --no-deploy --copy-config --name "$APP_NAME" --yes
else
  echo "App $APP_NAME already exists, skipping creation."
fi

# Keys managed in fly.toml [env] — not secrets
SKIP_KEYS="APP_PORT NOMINATIM_BASE_URL CORS_ORIGINS DIRECTUS_TIMEOUT_MS SCRAPER_TIMEOUT_MS NOMINATIM_TIMEOUT_MS LLM_TEMPERATURE"

secrets=""

while IFS= read -r line || [ -n "$line" ]; do
  # Skip empty lines and comments
  case "$line" in
    ""|\#*) continue ;;
  esac

  key="${line%%=*}"
  value="${line#*=}"

  # Skip keys managed in fly.toml
  skip=false
  for sk in $SKIP_KEYS; do
    if [ "$key" = "$sk" ]; then
      skip=true
      break
    fi
  done

  if [ "$skip" = true ]; then
    echo "Skipping $key (managed in fly.toml)"
    continue
  fi

  # Skip empty values
  if [ -z "$value" ]; then
    echo "Skipping $key (empty value)"
    continue
  fi

  secrets="$secrets $key=$value"
done < "$ENV_FILE"

if [ -z "$secrets" ]; then
  echo "No secrets to set."
  exit 0
fi

echo "Setting secrets on $APP_NAME..."
eval fly secrets set $secrets --app "$APP_NAME"
echo "Done. Run 'fly deploy' to deploy."
