import os
import pyodbc
from dotenv import load_dotenv

load_dotenv()

print("Starting SQL Server connection test...")

server = os.getenv("DB_SERVER")
database = os.getenv("DB_NAME")
driver = os.getenv("DB_DRIVER")

conn_str = (
    f"DRIVER={{{driver}}};"
    f"SERVER={server};"
    f"DATABASE={database};"
    "Trusted_Connection=yes;"
    "TrustServerCertificate=yes;"
)

try:
    conn = pyodbc.connect(conn_str)

    print("Connected successfully!")

    cursor = conn.cursor()
    cursor.execute("SELECT @@SERVERNAME, DB_NAME()")

    row = cursor.fetchone()

    print(f"Server: {row[0]}")
    print(f"Database: {row[1]}")

    conn.close()

except Exception as e:
    print("Connection Failed")
    print(e)