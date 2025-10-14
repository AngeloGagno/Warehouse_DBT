from airflow.decorators import dag
from cosmos import DbtDag, ProjectConfig, ProfileConfig, ExecutionConfig
from cosmos.profiles import PostgresUserPasswordProfileMapping
from datetime import datetime



profile_dbt = ProfileConfig(
    profile_name='Warehouse_vendas',
    target_name='dev',
    profile_mapping=PostgresUserPasswordProfileMapping(
        conn_id='Postgres_render',
        profile_args={'schema': 'public'},
    ),
)

dbt_dag = DbtDag(
    project_config=ProjectConfig(
        dbt_project_path='/usr/local/airflow/dbt/warehouse_dbt',  # caminho do projeto (tem dbt_project.yml)
        project_name='warehouse_dbt',
    ),
    profile_config=profile_dbt, 
    execution_config=ExecutionConfig(
        dbt_executable_path='/usr/local/airflow/dbt_venv/bin/dbt',  # caminho do binário do dbt
    ),
    operator_args={
        "install_deps": True,
        "target": profile_dbt.target_name,
    },
    schedule="@daily",
    start_date=datetime(2025, 5, 30),
    catchup=False,
    dag_id="dag_warehouse_dbt",
    default_args={"retries": 2},
)

