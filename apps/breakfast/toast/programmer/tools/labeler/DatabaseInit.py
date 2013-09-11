#!/usr/bin/env python

import sqlite3
import sys
import threading


#This class initializes the sqlite database file and creates xxx tables:
#- raw_table
#- meta_table
#- cookie_table
#- time_table
#If the file is not a sqlite db (corruption) a new file will be created.
#If the tables do not exist, they will be created.

#Exceptions thrown by sqlite
#
#StandardError
#|__Warning
#|__Error
#   |__InterfaceError
#   |__DatabaseError
#      |__DataError
#      |__OperationalError
#      |__IntegrityError
#      |__InternalError
#      |__ProgrammingError
#      |__NotSupportedError


class DatabaseInit(object):

    # constants 
    FILE_RETRIES = 10
    NO_OF_TABLES = 3

    # final name for db in use
    dbName = None

    # Table creation strings
    BACON_TABLE_SQL = '''CREATE TABLE bacon_table
                           (bacon_id TEXT NOT NULL, 
                            time REAL NOT NULL,
                            manufacture_id TEXT NOT NULL,
                            gain INTEGER,
                            offset INTEGER,
                            c15t30 INTEGER,
                            c15t85 INTEGER,
                            c20t30 INTEGER,
                            c20t85 INTEGER,
                            c25t30 INTEGER,
                            c25t85 INTEGER,
                            c15vref INTEGER,
                            c20vref INTEGER,
                            c25vref INTEGER,
                            CHECK(bacon_id <> "" and manufacture_id <> ""));'''

    TOAST_TABLE_SQL = '''CREATE TABLE toast_table
                           (toast_id TEXT NOT NULL,
                            time REAL NOT NULL,
                            gain INTEGER,
                            offset INTEGER,
                            c15t30 INTEGER,
                            c15t85 INTEGER,
                            c25t30 INTEGER,
                            c25t85 INTEGER,
                            c15vref INTEGER,
                            c25vref INTEGER,
                            CHECK(toast_id <> ""));'''

    SENSOR_TABLE_SQL = '''CREATE TABLE sensor_table
                           (sensor_id INTEGER NOT NULL,
                            type INTEGER NOT NULL,
                            time REAL NOT NULL,
                            detached REAL,
                            toast_id TEXT NOT NULL,
                            channel INTEGER NOT NULL,
                            CHECK(sensor_id <> 0 and toast_id <> ""));'''


    # class finds suitable filename for DB and creates tables if needed
    def __init__(self, rootName):

        # retry multiple filenames by incrementing counter in filename
        # a filename is accepted if either tables exists in it or 
        # tables can be created
        for fileCounter in range(0, DatabaseInit.FILE_RETRIES):
            dbFile = rootName + str(fileCounter) + '.sqlite'

            try:
                connection = sqlite3.connect(dbFile)

                cursor = connection.cursor()
                cursor.execute('''SELECT name FROM sqlite_master WHERE name LIKE '%_table';''')

                if len(cursor.fetchall()) != DatabaseInit.NO_OF_TABLES:
                    sys.stderr.write("Tables do not exist, create tables\n")

                    cursor.execute(DatabaseInit.BACON_TABLE_SQL);
                    cursor.execute(DatabaseInit.TOAST_TABLE_SQL);
                    cursor.execute(DatabaseInit.SENSOR_TABLE_SQL);
                    connection.commit();
 
                # only set name if no exceptions thrown
                self.dbName = dbFile

            except sqlite3.Error:
                sys.stderr.write("Error reading file: " + dbFile + "\n")
                continue
            finally:
                cursor.close()
                connection.close()
            break
            
        if self.dbName is None:
            raise IOError

        print "DatabaseInit()", threading.current_thread().name

    def getName(self):
        return self.dbName

# class test function
if __name__ == '__main__':

    try:
        db = DatabaseInit('database')
        print db.getName()
    except IOError:
        print "caught error"
    
    


