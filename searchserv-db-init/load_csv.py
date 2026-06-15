import psycopg as db
from db_connect import db_connect
from sys import argv
from itertools import compress
import csv

conn, curs = db_connect()
_, tblname, filename, *fields = argv
curs.execute(f"create table import.{tblname} ();")
header, *lines = open(filename).readlines()
cols = header.strip("\ufeff\n").split(";")
fieldmask = [(c in fields) for c in cols]
used_cols = list(compress(cols, fieldmask))
for col in used_cols:
    curs.execute(f"alter table import.{tblname} add {col} varchar;")
conn.commit()
colnames = f"({','.join(used_cols)})"
i = 0
# batch inserts for perf
def run_ls(ls):
    if not ls: return
    t = tuple(i for l in ls for i in compress(l, fieldmask))
    curs.execute(f"""
    insert into import.{tblname} {colnames} 
    values """ + ",".join(f"({','.join('%s' for _ in used_cols)})" for l in ls)
    , t)
ls = []

for l in csv.reader(lines, delimiter=';'):
    ls.append(l)
    if len(ls) >= 1000:
        run_ls(ls)
        ls = []
    if i % 10000 == 0:
        print("processed ", i)
        conn.commit()
    i += 1
run_ls(ls)
conn.commit()
curs.close()
conn.close()
