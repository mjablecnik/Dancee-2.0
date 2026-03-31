#!/bin/sh
#
# Clears all items from Directus collections used by dancee_workflow.
# Requires DIRECTUS_BASE_URL and DIRECTUS_ACCESS_TOKEN env vars,
# or reads them from .env in the project root.
#
# Usage:
#   ./scripts/clear-directus.sh                  # clears events, venues, errors
#   ./scripts/clear-directus.sh --include-groups  # also clears groups
#   ./scripts/clear-directus.sh --all             # clears everything including languages

set -e

# Help
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "Usage: ./scripts/clear-directus.sh [OPTION]"
  echo ""
  echo "Clears all items from Directus collections used by dancee_workflow."
  echo "Reads DIRECTUS_BASE_URL and DIRECTUS_ACCESS_TOKEN from .env or environment."
  echo ""
  echo "Options:"
  echo "  (no flag)          Clear events, venues, errors"
  echo "  --include-groups   Also clear groups"
  echo "  --all              Clear everything including groups and languages"
  echo "  -h, --help         Show this help"
  exit 0
fi

# Load .env if present
SCRIPT_DIR="$(dirname "$0")"
ENV_FILE="$SCRIPT_DIR/../.env"
if [ -f "$ENV_FILE" ]; then
  export $(grep -v '^#' "$ENV_FILE" | grep -v '^\s*$' | xargs)
fi

if [ -z "$DIRECTUS_BASE_URL" ] || [ -z "$DIRECTUS_ACCESS_TOKEN" ]; then
  echo "Error: DIRECTUS_BASE_URL and DIRECTUS_ACCESS_TOKEN must be set."
  echo "Either export them or add them to .env"
  exit 1
fi

AUTH="Authorization: Bearer $DIRECTUS_ACCESS_TOKEN"

delete_all_items() {
  collection="$1"
  echo "Clearing $collection..."

  # Fetch all item IDs
  ids=$(curl -s -H "$AUTH" "$DIRECTUS_BASE_URL/items/$collection?fields=id&limit=-1" \
    | grep -o '"id":[^,}]*' \
    | sed 's/"id"://g; s/"//g')

  if [ -z "$ids" ]; then
    echo "  $collection: already empty"
    return
  fi

  count=0
  for id in $ids; do
    curl -s -o /dev/null -X DELETE -H "$AUTH" "$DIRECTUS_BASE_URL/items/$collection/$id"
    count=$((count + 1))
  done
  echo "  $collection: deleted $count item(s)"
}

# Always clear these
delete_all_items "events"
delete_all_items "venues"
delete_all_items "errors"

# Optional: groups (manually curated, skip by default)
if [ "$1" = "--include-groups" ] || [ "$1" = "--all" ]; then
  delete_all_items "groups"
else
  echo "Skipping groups (use --include-groups to clear)"
fi

# Optional: languages (reference data, skip by default)
if [ "$1" = "--all" ]; then
  delete_all_items "languages"
else
  echo "Skipping languages (use --all to clear)"
fi

echo "Done."
