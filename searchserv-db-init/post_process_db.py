import psycopg as db
from db_connect import db_connect

conn, curs = db_connect()

# looks like autovac got more aggressive in v15, resulting in failed autovac attempts
# during post processing
print("disabling autovacuum")
curs.execute("alter table import.ortschaften set (autovacuum_enabled = false);")
curs.execute("alter table import.strassen set (autovacuum_enabled = false);")
curs.execute("alter table import.adressen set (autovacuum_enabled = false);")
curs.execute("alter table import.namen set (autovacuum_enabled = false);")
conn.commit()

print("adding new columns")
curs.execute("alter table import.strassen add wgs_point geometry")
curs.execute("alter table import.strassen add full_str_lower varchar")

curs.execute("alter table import.adressen add wgs_point geometry")
curs.execute("alter table import.adressen add full_addr_lower varchar")

curs.execute("alter table import.namen add wgs_point geometry")
curs.execute("alter table import.namen add closest_town varchar")
curs.execute("alter table import.namen add closest_town_plz varchar")
curs.execute("alter table import.namen add full_name_lower varchar")
conn.commit()

# create a geo index on ortschaften to speed up upcoming nearest-ort queries for namen
print("ort idx")
curs.execute("""
create index ix_ort_geo on import.ortschaften
using gist (ST_POINT(E :: float, N :: float, 4326));
""")

# reformat coordinates to LAT/LON 
# keep it as a single geometry point for distance ordering
print("changing strassen coords to WGS points")
curs.execute("""
update import.strassen 
set wgs_point = 
    ST_Transform(
        ST_SetSRID(
            ST_MakePoint(STR_EASTING :: float, STR_NORTHING :: float), 
            2056), 
        4326);
""")
conn.commit()

print("changing adressen coords to WGS points")
curs.execute("""
update import.adressen
set wgs_point = 
    ST_Transform(
        ST_SetSRID(
            ST_MakePoint(ADR_EASTING :: float, ADR_NORTHING :: float), 
            2056), 
        4326);
""")

print("changing namen coords to WGS points")
curs.execute("""
update import.namen
set wgs_point = 
    ST_Transform(
        ST_SetSRID(
            ST_MakePoint(E :: float, N :: float), 
            2056), 
        4326);
""")
conn.commit()

# remove rows that are far away, lowers space requirements and speeds up queries
print("removing faraway adressen")
curs.execute("""
delete from import.adressen 
where ST_DistanceSphere(wgs_point, ST_Point(8.30882407298, 47.3038127715, 4326)) > 60000; 
""")

print("removing faraway names")
curs.execute("""
delete from import.namen 
where ST_DistanceSphere(wgs_point, ST_Point(8.30882407298, 47.3038127715, 4326)) > 60000; 
""")
conn.commit()

# augment namen table with nearby towns for more useful search results
print("adding closest towns to namen")
curs.execute("""
update import.namen
set (closest_town, closest_town_plz) = (
    select ortschaftsname, PLZ from import.ortschaften
    order by import.namen.wgs_point <-> ST_POINT(E :: float, N :: float, 4326)
    limit 1
);
""")
conn.commit()

# add a single text field to search against
print("adding search field for strassen")
curs.execute("""
update import.strassen
set full_str_lower = lower(concat(STN_LABEL, ' ', trim(leading '0987654321 ' from ZIP_LABEL)));
""")

print("adding search field for adressen")
curs.execute("""
update import.adressen
set full_addr_lower = lower(concat(STN_LABEL, ' ', ADR_NUMBER, ' ', 
    trim(leading '0987654321 ' from ZIP_LABEL)));
""")

print("adding search field for namen")
curs.execute("""
update import.namen
set full_name_lower = lower(concat(NAME, ' ', closest_town));
""")
conn.commit()

# don't need these anymore
print("dropping redundant columns")
curs.execute("alter table import.namen drop column E, drop column N;")
curs.execute("alter table import.strassen drop column STR_EASTING, drop column STR_NORTHING;")
curs.execute("alter table import.adressen drop column ADR_EASTING, drop column ADR_NORTHING;")
conn.commit()

# create btree indices to help text search, and geo indices to speed up ordering by distance
print("creating indices")
curs.execute("""
create index ix_ort on import.ortschaften
using btree (lower(ortschaftsname) text_pattern_ops);
""")
curs.execute("""
create index ix_ort_plz on import.ortschaften
using btree (PLZ text_pattern_ops);
""")
curs.execute("""
create index ix_str on import.strassen
using btree (full_str_lower text_pattern_ops);
""")
curs.execute("""
create index ix_adr on import.adressen 
using btree (full_addr_lower text_pattern_ops);
""")
curs.execute("""
create index ix_nam on import.namen
using btree (full_name_lower text_pattern_ops);
""")
conn.commit()

curs.execute("""
create index ix_str_geo on import.strassen
using gist (wgs_point);
""")
curs.execute("""
create index ix_adr_geo on import.adressen 
using gist (wgs_point);
""")
curs.execute("""
create index ix_nam_geo on import.namen
using gist (wgs_point);
""")
conn.commit();

# vacuum tables and analyze. have to mess around with the setting because you can't vacuum
# in a transaction
print("vacuuming and analyzing")
old = conn.autocommit
conn.autocommit = True
curs.execute("vacuum full analyze;")
conn.autocommit = old
conn.commit();
curs.close()
conn.close()
