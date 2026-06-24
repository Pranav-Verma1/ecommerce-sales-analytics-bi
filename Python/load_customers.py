import pandas as pd

from config import DATA_PATH
from db_connection import get_connection
from logger import write_log


def load_customers():

    from file_tracker import (
        file_changed,
        update_file_tracking
    )

    file_path = f"{DATA_PATH}\\dim_customers.csv"

    if not file_changed(
        "dim_customers.csv",
        file_path
    ):
        print("dim_customers.csv unchanged. Skipping.")
        return False

    print("\nLoading stg_customers...")

    df = pd.read_csv(file_path, low_memory=False)

    df = df.loc[:, ~df.columns.str.contains("^Unnamed")]

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("TRUNCATE TABLE stg_customers")
    conn.commit()

    columns = ",".join(df.columns)
    placeholders = ",".join(["?"] * len(df.columns))

    insert_sql = (
        f"INSERT INTO stg_customers ({columns}) "
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
            "stg_customers",
            len(df),
            "Success"
        )
        update_file_tracking(
            "dim_customers.csv",
            file_path
        )
        print(f"Loaded {len(df):,} rows into stg_customers")

    except Exception as e:

        write_log(
            "stg_customers",
            0,
            "Failed"
        )

        print(f"Error: {e}")

        raise

    finally:
        conn.close()
    return True