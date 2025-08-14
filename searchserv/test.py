import psycopg as db
from db_connect import db_connect
from sys import argv
from itertools import compress

conn, curs = db_connect()
old = conn.autocommit
#conn.autocommit = True
curs.execute("set autovacuum to false;")
#conn.autocommit = old
conn.commit()
curs.close()
conn.close()
