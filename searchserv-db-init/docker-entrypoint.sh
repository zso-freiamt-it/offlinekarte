#!/bin/sh
set -eu

WORKDIR=/workspace/searchserv
INPUT_DIR=${INPUT_DIR:-/input}
OUTPUT_DIR=${OUTPUT_DIR:-/out}
GEO_DATA_DIR=${GEO_DATA_DIR:-$WORKDIR/geo_data}
DB_HOST=${PGHOST:-db}
DB_PORT=${PGPORT:-5432}
DB_USER=${PGUSER:-postgres}
DB_NAME=${PGDATABASE:-postgres}

mkdir -p "$GEO_DATA_DIR"

ln -sf "$INPUT_DIR/AMTOVZ_CSV_WGS84.csv" "$GEO_DATA_DIR/AMTOVZ_CSV_WGS84.csv"
ln -sf "$INPUT_DIR/amtliches-strassenverzeichnis_ch_2056.csv" "$GEO_DATA_DIR/amtliches-strassenverzeichnis_ch_2056.csv"
ln -sf "$INPUT_DIR/amtliches-gebaeudeadressverzeichnis_ch_2056.csv" "$GEO_DATA_DIR/amtliches-gebaeudeadressverzeichnis_ch_2056.csv"

GEO_DATA_DIR="$GEO_DATA_DIR" ./download_geo_data.sh

until pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" >/dev/null 2>&1; do
    sleep 1
done

cd "$WORKDIR"
sed 's/\r$//' load_db.sh | bash

if [ -d "$OUTPUT_DIR" ]; then
    cp db.sql "$OUTPUT_DIR/db.sql"
fi
