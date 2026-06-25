import pyodbc
from config import (DB_SERVER, 
DB_NAME, 
DB_DRIVER,
DB_USER,
DB_PASSWORD)
def get_connection():

    conn_str = (
        f"DRIVER={{{DB_DRIVER}}};"
        f"SERVER={DB_SERVER};"
        f"DATABASE={DB_NAME};"
        f"UID={DB_USER};"
        f"PWD={DB_PASSWORD};"
        "TrustServerCertificate=yes;"
    )

    return pyodbc.connect(conn_str)