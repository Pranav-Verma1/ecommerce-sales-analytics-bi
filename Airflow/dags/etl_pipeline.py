from datetime import datetime

from airflow import DAG
from airflow.operators.bash import BashOperator


with DAG(
    dag_id="ecommerce_etl_pipeline",
    start_date=datetime(2026, 6, 24),
    schedule=None,
    catchup=False,
    tags=["etl", "sqlserver", "powerbi"]
) as dag:

    start = BashOperator(
        task_id="start",
        bash_command="echo ETL Started"
    )

    run_etl = BashOperator(
        task_id="run_etl",
        bash_command="python /opt/airflow/project/Python/run_etl.py"
    )

    end = BashOperator(
        task_id="end",
        bash_command="echo ETL Finished"
    )

    start >> run_etl >> end