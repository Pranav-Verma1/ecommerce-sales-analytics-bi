import os
from db_connection import get_connection
from datetime import datetime


def file_changed(file_name, file_path):

    current_modified = datetime.fromtimestamp(
        os.path.getmtime(file_path)
    )

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT Last_Modified
        FROM etl_file_tracking
        WHERE File_Name = ?
    """, file_name)

    row = cursor.fetchone()

    conn.close()

    if row is None:
        return True

    last_modified = row[0]

    if last_modified is None:
        return True

    print(f"\nChecking {file_name}")
    print(f"Current Modified : {current_modified}")
    print(f"Last Modified    : {last_modified}")

    time_diff = abs(
        (current_modified - last_modified).total_seconds()
        )

    return time_diff > 2

def update_file_tracking(file_name, file_path):

    current_modified = datetime.fromtimestamp(
        os.path.getmtime(file_path)
    )

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        UPDATE etl_file_tracking
        SET
            Last_Modified = ?,
            Last_Loaded = GETDATE(),
            Status = 'Success'
        WHERE File_Name = ?
    """,
    current_modified,
    file_name)

    conn.commit()
    conn.close()