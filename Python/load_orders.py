import pandas as pd
import os
from config import DATA_PATH
from db_connection import get_connection
from logger import write_log

def load_orders():

    from file_tracker import (
        file_changed,
        update_file_tracking
    )

    file_path = os.path.join(DATA_PATH, "fact_orders.csv")

    if not file_changed(
        "fact_orders.csv",
        file_path
    ):
        print("fact_orders.csv unchanged. Skipping.")
        return False

    print("\nLoading stg_orders...")
    print(f"Reading: {file_path}")

    df = pd.read_csv(file_path, low_memory=False)

    # Remove unwanted columns
    df = df.loc[:, ~df.columns.str.contains("^Unnamed")]

    if "ws" in df.columns:
        df = df.drop(columns=["ws"])

    # Convert date
    df["Order_Date"] = pd.to_datetime(
        df["Order_Date"],
        format="%m/%d/%Y",
        errors="coerce"
    )

    print("Invalid Dates:", df["Order_Date"].isna().sum())

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("TRUNCATE TABLE stg_orders")
    conn.commit()

    columns = ",".join(df.columns)
    placeholders = ",".join(["?"] * len(df.columns))

    insert_sql = (
        f"INSERT INTO stg_orders ({columns}) "
        f"VALUES ({placeholders})"
    )

    cursor.fast_executemany = True

    try:

        cursor.executemany(
            insert_sql,
            df.values.tolist()
        )

        conn.commit()

        write_log(
            "stg_orders",
            len(df),
            "Success"
        )
        update_file_tracking(
            "fact_orders.csv",
            file_path
        )

        print(f"Loaded {len(df):,} rows into stg_orders")

    except Exception as e:

        write_log(
            "stg_orders",
            0,
            "Failed"
        )

        print(f"Error: {e}")

        raise

    finally:
        conn.close()
    return True