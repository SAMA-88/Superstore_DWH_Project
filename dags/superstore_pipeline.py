from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta

# إعدادات الـ DAG الأساسية
default_args = {
    'owner': 'sama',
    'depends_on_past': False,
    'start_date': datetime(2023, 1, 1),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# تعريف الـ DAG
with DAG(
    'superstore_elt_pipeline',
    default_args=default_args,
    description='Automated ELT Pipeline for Superstore (Python + dbt + DuckDB)',
    schedule_interval='@daily',
    catchup=False,
) as dag:

    extract_and_load = BashOperator(
        task_id='extract_and_load',
        bash_command='python /opt/airflow/scripts/load_to_ods.py',
    )

    transform_data = BashOperator(
        task_id='transform_data',
        bash_command='cd /opt/airflow/dbt_project1 && dbt run --profiles-dir .',
    )

    data_quality_check = BashOperator(
        task_id='data_quality_check',
        bash_command='cd /opt/airflow/dbt_project1 && dbt test --profiles-dir .',
    )

    extract_and_load >> transform_data >> data_quality_check