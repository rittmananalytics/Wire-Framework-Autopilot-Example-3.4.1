"""
Dataform Run DAG — Core Dynamics Data Platform
Runs Dataform pipelines after Fivetran sync completes.
Sequence: staging → intermediate → warehouse (all marts)

Author: Sophie Tanner, Rittman Analytics
Date: 2026-03-24
"""

from datetime import datetime, timedelta

from airflow import DAG
from airflow.providers.google.cloud.operators.dataform import (
    DataformCreateCompilationResultOperator,
    DataformCreateWorkflowInvocationOperator,
    DataformGetWorkflowInvocationOperator,
)
from airflow.sensors.external_task import ExternalTaskSensor

default_args = {
    "owner": "rittman-analytics",
    "depends_on_past": False,
    "start_date": datetime(2026, 3, 25),
    "email": ["data-alerts@rittmananalytics.com", "amara.diallo@coredynamics.io"],
    "email_on_failure": True,
    "retries": 1,
    "retry_delay": timedelta(minutes=10),
}

GCP_PROJECT = "core-dynamics-analytics-prod"
GCP_REGION = "us-central1"
DATAFORM_REPOSITORY = "core-dynamics-dataform"  # [To configure with repo ID]
DATAFORM_BRANCH = "main"

with DAG(
    dag_id="dataform_run_dag",
    default_args=default_args,
    description="Run Dataform transformation pipeline after Fivetran sync",
    schedule_interval=None,  # Triggered by fivetran_trigger_dag on success
    catchup=False,
    tags=["core-dynamics", "dataform", "transformation"],
) as dag:

    # Wait for Fivetran sync to complete
    wait_for_fivetran = ExternalTaskSensor(
        task_id="wait_for_fivetran_sync",
        external_dag_id="fivetran_trigger_dag",
        external_task_id=None,  # Wait for entire DAG to complete
        mode="reschedule",
        timeout=7200,  # 2 hours max wait
        poke_interval=300,  # Check every 5 minutes
    )

    # Compile Dataform project
    compile_dataform = DataformCreateCompilationResultOperator(
        task_id="compile_dataform",
        project_id=GCP_PROJECT,
        region=GCP_REGION,
        repository_id=DATAFORM_REPOSITORY,
        compilation_result={
            "git_commitish": DATAFORM_BRANCH,
            "code_compilation_config": {
                "default_database": GCP_PROJECT,
                "default_schema": "staging",
                "vars": {"env": "prod"},
            },
        },
    )

    # Run staging layer
    run_staging = DataformCreateWorkflowInvocationOperator(
        task_id="run_staging_layer",
        project_id=GCP_PROJECT,
        region=GCP_REGION,
        repository_id=DATAFORM_REPOSITORY,
        workflow_invocation={
            "compilation_result": "{{ task_instance.xcom_pull('compile_dataform') }}",
            "invocation_config": {
                "included_tags": ["staging"],
                "fully_refresh_incremental_tables_enabled": False,
            },
        },
        asynchronous=False,
    )

    # Run intermediate layer
    run_intermediate = DataformCreateWorkflowInvocationOperator(
        task_id="run_intermediate_layer",
        project_id=GCP_PROJECT,
        region=GCP_REGION,
        repository_id=DATAFORM_REPOSITORY,
        workflow_invocation={
            "compilation_result": "{{ task_instance.xcom_pull('compile_dataform') }}",
            "invocation_config": {
                "included_tags": ["intermediate"],
                "fully_refresh_incremental_tables_enabled": False,
            },
        },
        asynchronous=False,
    )

    # Run warehouse/mart layer
    run_warehouse = DataformCreateWorkflowInvocationOperator(
        task_id="run_warehouse_layer",
        project_id=GCP_PROJECT,
        region=GCP_REGION,
        repository_id=DATAFORM_REPOSITORY,
        workflow_invocation={
            "compilation_result": "{{ task_instance.xcom_pull('compile_dataform') }}",
            "invocation_config": {
                "included_tags": ["warehouse"],
                "fully_refresh_incremental_tables_enabled": False,
            },
        },
        asynchronous=False,
    )

    # DAG flow
    wait_for_fivetran >> compile_dataform >> run_staging >> run_intermediate >> run_warehouse
