import psycopg as db
from time import sleep
import os

# try to get a connection to the db going
def db_connect():
    tries = 0
    while tries < 100:
        try:
            conn = db.connect("host=offlinekarte-search-db port=5432 user=postgres password=postgres")
            break;
        except db.OperationalError as ex:
            print(ex)
            tries += 1
            sleep(0.5)
    if tries == 100:
        print("Couldn't connect to database, exiting")
        exit(1)
    curs = conn.cursor()
    return conn, curs
