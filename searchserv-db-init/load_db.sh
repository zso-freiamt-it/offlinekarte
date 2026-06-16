AMTOVZ_CSV=${AMTOVZ_CSV:-./geo_data/AMTOVZ_CSV_WGS84/AMTOVZ_CSV_WGS84.csv}
AMTOVZ_CSV_NORMALIZED=${AMTOVZ_CSV_NORMALIZED:-./geo_data/AMTOVZ_CSV_WGS84_plz.csv}
PURE_STR_CSV=${PURE_STR_CSV:-./geo_data/amtliches-strassenverzeichnis_ch_2056.csv}
PURE_ADR_CSV=${PURE_ADR_CSV:-./geo_data/amtliches-gebaeudeadressverzeichnis_ch_2056.csv}
SWISSNAMES_CSV=${SWISSNAMES_CSV:-./geo_data/swissNAMES3D_PKT.csv}

trap 'rm -f "$AMTOVZ_CSV_NORMALIZED"' EXIT

sed '1 s/PLZ4/PLZ/' "$AMTOVZ_CSV" > "$AMTOVZ_CSV_NORMALIZED"

sudo -u postgres ./venv/bin/python3 ./clean_db.py
load_csv() {
    sudo -u postgres ./venv/bin/python3 load_csv.py $@
}
echo "loading orts"
load_csv ortschaften "$AMTOVZ_CSV_NORMALIZED" Ortschaftsname PLZ E N
# delete street w/o coords
sed '/;;.*;.*;.*$/d; /;;.*;.*$/d' "$PURE_STR_CSV" > ./str_clean.csv
sed 's/ swisstopo//g' "$SWISSNAMES_CSV" > ./names_clean.csv
echo "loading strassen"
load_csv strassen ./str_clean.csv STN_LABEL ZIP_LABEL STR_EASTING STR_NORTHING
rm ./str_clean.csv
echo "loading adressen"
load_csv adressen "$PURE_ADR_CSV" STN_LABEL ADR_NUMBER ZIP_LABEL ADR_EASTING ADR_NORTHING
echo "loading names3D points"
load_csv namen ./names_clean.csv OBJEKTART NAME E N
echo "post processing"
sudo -u postgres ./venv/bin/python3 post_process_db.py
echo "dumping to file"
sudo -u postgres pg_dump postgres | sed '/^\\restrict/d;/^\\unrestrict/d' > db.sql
printf '\nVACUUM FULL ANALYZE;\n' >> db.sql
