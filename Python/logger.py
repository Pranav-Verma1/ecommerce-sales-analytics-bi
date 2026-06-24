from db_connection import get_connection

def write_log(process_name, rows_loaded, status):

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        INSERT INTO etl_log
        (
            Process_Name,
            Rows_Loaded,
            Status
        )
        VALUES (?, ?, ?)
    """,
    process_name,
    rows_loaded,
    status)

    conn.commit()
    conn.close()