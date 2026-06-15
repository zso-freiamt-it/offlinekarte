import psycopg as db
from time import sleep
import os

# try to get a connection to the db going
def db_connect():
    tries = 0
    max_tries = int(os.getenv("DB_CONNECT_TRIES", "10"))
    delay = float(os.getenv("DB_CONNECT_DELAY", "0.5"))
    while tries < max_tries:
        try:
            conn = db.connect()
            break;
        except db.OperationalError as ex:
            print(ex)
            tries += 1
            sleep(delay)
    if tries == max_tries:
        print("Couldn't connect to database, exiting")
        exit(1)
    curs = conn.cursor()
    return conn, curs
