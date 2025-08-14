sudo -u postgres ./venv/bin/python3 ./clean_db.py
load_csv() {
    sudo -u postgres ./venv/bin/python3 load_csv.py $@
}
echo "loading orts"
load_csv ortschaften './AMTOVZ_CSV_WGS84/AMTOVZ_CSV_WGS84.csv' Ortschaftsname PLZ E N
# delete street w/o coords
sed '/;;.*;.*;.*$/d; /;;.*;.*$/d' ./pure_str.csv > ./str_clean.csv
sed 's/ swisstopo//g' './csv_LV95_LN02/swissNAMES3D_PKT.csv' > ./names_clean.csv
echo "loading strassen"
load_csv strassen ./str_clean.csv STN_LABEL ZIP_LABEL STR_EASTING STR_NORTHING
rm ./str_clean.csv
echo "loading adressen"
load_csv adressen ./pure_adr.csv STN_LABEL ADR_NUMBER ZIP_LABEL ADR_EASTING ADR_NORTHING
echo "loading names3D points"
load_csv namen ./names_clean.csv OBJEKTART NAME E N
echo "post processing"
sudo -u postgres ./venv/bin/python3 post_process_db.py

