from db_connection import get_connection


def refresh_warehouse():

    conn = get_connection()
    cursor = conn.cursor()

    print("\nRefreshing Warehouse...")

    cursor.execute("EXEC sp_refresh_warehouse")

    conn.commit()
    conn.close()

    print("Warehouse Refresh Completed")