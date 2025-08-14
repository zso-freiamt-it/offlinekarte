import psycopg as db
from time import sleep

# try to get a connection to the db going
def db_connect():
    tries = 0
    while tries < 10:
        try:
            conn = db.connect()
            break;
        except db.OperationalError as ex:
            print(ex)
            tries += 1
            sleep(0.5)
    if tries == 10:
        print("Couldn't connect to database, exiting")
        exit(1)
    curs = conn.cursor()
    return conn, curs
