#!/usr/bin/env bash

set -euo pipefail

GEO_DATA_DIR=${GEO_DATA_DIR:-/workspace/searchserv/geo_data}
API_URL="https://ogd.swisstopo.admin.ch/services/swiseld/services/collections/ch.swisstopo.swissnames3d/assets"

mkdir -p "$GEO_DATA_DIR"

download_and_extract() {
    local url="$1"
    local filename
    local target_file

    filename=$(basename "$url")
    target_file="$GEO_DATA_DIR/$filename"

    echo "Downloading $filename ..."
    curl -fL --retry 3 -o "$target_file" "$url"

    echo "Validating $filename ..."
    unzip -t "$target_file" >/dev/null

    echo "Extracting $filename ..."
    unzip -o "$target_file" -d "$GEO_DATA_DIR"

    echo "Cleaning up $filename ..."
    rm -f "$target_file"
}

echo "Querying Swisstopo API for latest swissnames3d dataset..."

DOWNLOAD_URL=$(
    curl -fsSL "$API_URL" \
    | tr '"' '\n' \
    | grep -E '^https://.*swissnames3d_[0-9]{4}_2056\.csv\.zip$' \
    | sort \
    | tail -n1
)

if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "ERROR: No swissnames3d download URL found."
    exit 1
fi

# Download latest SwissNames3D dataset
download_and_extract "$DOWNLOAD_URL"

# Download additional static datasets
download_and_extract \
    "https://data.geo.admin.ch/ch.swisstopo.amtliches-strassenverzeichnis/amtliches-strassenverzeichnis_ch/amtliches-strassenverzeichnis_ch_2056.csv.zip"

download_and_extract \
    "https://data.geo.admin.ch/ch.swisstopo-vd.ortschaftenverzeichnis_plz/ortschaftenverzeichnis_plz/ortschaftenverzeichnis_plz_4326.csv.zip"

download_and_extract \
    "https://data.geo.admin.ch/ch.swisstopo.amtliches-gebaeudeadressverzeichnis/amtliches-gebaeudeadressverzeichnis_ch/amtliches-gebaeudeadressverzeichnis_ch_2056.csv.zip"

echo "All datasets successfully updated."