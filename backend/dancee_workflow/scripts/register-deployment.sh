#!/bin/sh
# Wait for Restate server to be healthy, then start the app.
# Registration is handled by the app itself after startup.

retries=0
until curl -sf http://localhost:9070/health > /dev/null 2>&1; do
  retries=$((retries+1))
  if [ $retries -ge 60 ]; then
    echo "Restate server did not become healthy after 60 retries, exiting"
    exit 1
  fi
  echo "Waiting for Restate server..."
  sleep 1
done

echo "Restate server is healthy, starting app..."
exec node /app/dist/index.js
