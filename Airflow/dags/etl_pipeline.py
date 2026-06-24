from datetime import datetime

from airflow import DAG
from airflow.operators.bash import BashOperator


with DAG(
    dag_id="ecommerce_etl_pipeline",
    start_date=datetime(2025, 1, 1),
    schedule="@daily",
    catchup=False,
    tags=["etl", "sqlserver", "powerbi"]
) as dag:

    start = BashOperator(
        task_id="start",
        bash_command="echo ETL Started"
    )

    run_etl = BashOperator(
        task_id="run_etl",
        bash_command="echo Running Python ETL"
    )

    refresh_warehouse = BashOperator(
        task_id="refresh_warehouse",
        bash_command="echo Refreshing Warehouse"
    )

    end = BashOperator(
        task_id="end",
        bash_command="echo ETL Finished"
    )

    start >> run_etl >> refresh_warehouse >> end