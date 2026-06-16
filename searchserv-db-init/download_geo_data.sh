#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "v3"

GEO_DATA_DIR=${GEO_DATA_DIR:-/workspace/searchserv/geo_data}
API_URL="https://ogd.swisstopo.admin.ch/services/swiseld/services/collections/ch.swisstopo.swissnames3d/assets"

echo "Querying Swisstopo API for the latest swissnames3d dataset..."

# 1. Fetch JSON from the API, extract the .csv.zip URLs, sort them, and grab the newest one
DOWNLOAD_URL=$(
    curl -fsSL "$API_URL" \
    | tr '"' '\n' \
    | grep -E '^https://.*swissnames3d_[0-9]{4}_2056\.csv\.zip$' \
    | sort \
    | tail -n1
)

if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "ERROR: No download URL found."
    exit 1
fi

FILENAME=$(basename "$DOWNLOAD_URL")

# Safety check
if [[ ! "$FILENAME" =~ ^swissnames3d_[0-9]{4}_2056\.csv\.zip$ ]]; then
    echo "ERROR: Unexpected filename: $FILENAME"
    exit 1
fi

mkdir -p "$GEO_DATA_DIR"

TARGET_FILE="$GEO_DATA_DIR/$FILENAME"

echo "Downloading $DOWNLOAD_URL"
curl -fL --retry 3 -o "$TARGET_FILE" "$DOWNLOAD_URL"

echo "Validating ZIP archive..."
unzip -t "$TARGET_FILE" >/dev/null

echo "Extracting CSV files..."
unzip -o "$TARGET_FILE" -d "$GEO_DATA_DIR"

echo "Cleaning up..."
rm -f "$TARGET_FILE"

echo "Successfully updated dataset: $FILENAME"