import os
from dotenv import load_dotenv

load_dotenv()

DB_SERVER = os.getenv("DB_SERVER")
DB_NAME = os.getenv("DB_NAME")
DB_DRIVER = os.getenv("DB_DRIVER")

if os.name == "nt":
    DATA_PATH = os.getenv("DATA_PATH")
else:
    DATA_PATH = "/opt/airflow/project/Data"