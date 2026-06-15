#!/bin/sh
set -eu

WORKDIR=/workspace/searchserv
INPUT_DIR=${INPUT_DIR:-/input}
OUTPUT_DIR=${OUTPUT_DIR:-/out}
DB_HOST=${PGHOST:-db}
DB_PORT=${PGPORT:-5432}
DB_USER=${PGUSER:-postgres}
DB_NAME=${PGDATABASE:-postgres}

mkdir -p "$WORKDIR/AMTOVZ_CSV_WGS84" "$WORKDIR/csv_LV95_LN02"

ln -sf "$INPUT_DIR/AMTOVZ_CSV_WGS84.csv" "$WORKDIR/AMTOVZ_CSV_WGS84/AMTOVZ_CSV_WGS84.csv"
ln -sf "$INPUT_DIR/amtliches-strassenverzeichnis_ch_2056.csv" "$WORKDIR/pure_str.csv"
ln -sf "$INPUT_DIR/amtliches-gebaeudeadressverzeichnis_ch_2056.csv" "$WORKDIR/pure_adr.csv"
ln -sf "$INPUT_DIR/swissNAMES3D_PKT.csv" "$WORKDIR/csv_LV95_LN02/swissNAMES3D_PKT.csv"

until pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" >/dev/null 2>&1; do
    sleep 1
done

cd "$WORKDIR"
sed 's/\r$//' load_db.sh | bash

if [ -d "$OUTPUT_DIR" ]; then
    cp db.sql "$OUTPUT_DIR/db.sql"
fi
