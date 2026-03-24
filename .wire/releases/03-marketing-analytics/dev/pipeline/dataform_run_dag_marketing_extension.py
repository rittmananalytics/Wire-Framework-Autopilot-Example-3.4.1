"""
dataform_run_dag.py — Updated for marketing analytics release (03-marketing-analytics)
Core Dynamics Data Platform Modernisation

Extends the existing dataform_run_dag with two new phases:
  - intermediate_marketing (runs after staging completes)
  - warehouse_marketing (runs after intermediate_marketing completes)

Deploy by replacing the existing dataform_run_dag.py in the Cloud Composer GCS bucket.
"""

import os
from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.google.cloud.operators.dataform import (
    DataformCreateWorkflowInvocationOperator,
    DataformGetWorkflowInvocationOperator,
)
from airflow.providers.google.cloud.sensors.dataform import DataformWorkflowInvocationStateSensor
from airflow.sensors.external_task import ExternalTaskSensor
from airflow.utils.state import TaskInstanceState

PROJECT_ID = os.environ.get("GCP_PROJECT", "core-dynamics-analytics-prod")
LOCATION = "us-central1"
REPOSITORY_ID = "core-dynamics-dataform"

default_args = {
    "owner": "rittman-analytics",
    "depends_on_past": False,
    "email_on_failure": True,
    "email_on_retry": False,
    "email": ["data-alerts@rittmananalytics.com"],
    "retries": 1,
    "retry_delay": timedelta(minutes=10),
}

with DAG(
    dag_id="dataform_run_dag",
    default_args=default_args,
    description="Run Dataform transformations: staging → integration → warehouse → marketing analytics",
    schedule_interval="30 7 * * *",  # 07:30 UTC — after Fivetran syncs complete
    start_date=datetime(2026, 3, 24),
    catchup=False,
    tags=["dataform", "core-dynamics"],
    max_active_runs=1,
) as dag:

    # Wait for Fivetran trigger DAG to complete all syncs
    wait_for_fivetran = ExternalTaskSensor(
        task_id="wait_for_fivetran_dag",
        external_dag_id="fivetran_trigger_dag",
        external_task_id="sync_clearbit_enrichment",  # Last task in fivetran DAG
        timeout=7200,  # 2 hours max wait
        poke_interval=120,
        mode="reschedule",
        allowed_states=[TaskInstanceState.SUCCESS],
        failed_states=[TaskInstanceState.FAILED],
    )

    # ─────────────────────────────────────────────────────────────────────────
    # Phase 1: Staging layer (all staging models from 02-data-foundation)
    # ─────────────────────────────────────────────────────────────────────────

    run_staging = DataformCreateWorkflowInvocationOperator(
        task_id="run_staging_models",
        project_id=PROJECT_ID,
        region=LOCATION,
        repository_id=REPOSITORY_ID,
        workflow_invocation={
            "compilation_result": "{{ task_instance.xcom_pull('compile_dataform') }}",
            "invocation_config": {
                "included_tags": ["staging"],
                "fully_refresh_incremental_tables_enabled": False,
            },
        },
    )

    staging_complete_sensor = DataformWorkflowInvocationStateSensor(
        task_id="staging_complete_sensor",
        project_id=PROJECT_ID,
        region=LOCATION,
        repository_id=REPOSITORY_ID,
        workflow_invocation_id="{{ task_instance.xcom_pull('run_staging_models', key='workflow_invocation_id') }}",
        expected_statuses={"SUCCEEDED"},
        failure_statuses={"FAILED", "CANCELLING", "CANCELLED"},
        timeout=3600,
        poke_interval=60,
    )

    # ─────────────────────────────────────────────────────────────────────────
    # Phase 2: Integration layer (cross-source intermediate models)
    # ─────────────────────────────────────────────────────────────────────────

    run_integration = DataformCreateWorkflowInvocationOperator(
        task_id="run_integration_models",
        project_id=PROJECT_ID,
        region=LOCATION,
        repository_id=REPOSITORY_ID,
        workflow_invocation={
            "compilation_result": "{{ task_instance.xcom_pull('compile_dataform') }}",
            "invocation_config": {
                "included_tags": ["integration"],
                "fully_refresh_incremental_tables_enabled": False,
            },
        },
    )

    integration_complete_sensor = DataformWorkflowInvocationStateSensor(
        task_id="integration_complete_sensor",
        project_id=PROJECT_ID,
        region=LOCATION,
        repository_id=REPOSITORY_ID,
        workflow_invocation_id="{{ task_instance.xcom_pull('run_integration_models', key='workflow_invocation_id') }}",
        expected_statuses={"SUCCEEDED"},
        failure_statuses={"FAILED", "CANCELLING", "CANCELLED"},
        timeout=1800,
        poke_interval=60,
    )

    # ─────────────────────────────────────────────────────────────────────────
    # Phase 3: Warehouse layer (customer analytics, product analytics, etc.)
    # ─────────────────────────────────────────────────────────────────────────

    run_warehouse = DataformCreateWorkflowInvocationOperator(
        task_id="run_warehouse_models",
        project_id=PROJECT_ID,
        region=LOCATION,
        repository_id=REPOSITORY_ID,
        workflow_invocation={
            "compilation_result": "{{ task_instance.xcom_pull('compile_dataform') }}",
            "invocation_config": {
                "included_tags": ["warehouse"],
                "fully_refresh_incremental_tables_enabled": False,
            },
        },
    )

    warehouse_complete_sensor = DataformWorkflowInvocationStateSensor(
        task_id="warehouse_complete_sensor",
        project_id=PROJECT_ID,
        region=LOCATION,
        repository_id=REPOSITORY_ID,
        workflow_invocation_id="{{ task_instance.xcom_pull('run_warehouse_models', key='workflow_invocation_id') }}",
        expected_statuses={"SUCCEEDED"},
        failure_statuses={"FAILED", "CANCELLING", "CANCELLED"},
        timeout=3600,
        poke_interval=60,
    )

    # ─────────────────────────────────────────────────────────────────────────
    # Phase 4a: Marketing intermediate models (NEW — 03-marketing-analytics)
    # int__contacts__unified, int__marketing_touches__all_channels,
    # int__campaign_spend__normalised, int__opportunities__attributed,
    # int__funnel_events__staged
    # ─────────────────────────────────────────────────────────────────────────

    run_intermediate_marketing = DataformCreateWorkflowInvocationOperator(
        task_id="run_intermediate_marketing_models",
        project_id=PROJECT_ID,
        region=LOCATION,
        repository_id=REPOSITORY_ID,
        workflow_invocation={
            "compilation_result": "{{ task_instance.xcom_pull('compile_dataform') }}",
            "invocation_config": {
                "included_tags": ["intermediate_marketing"],
                "fully_refresh_incremental_tables_enabled": False,
            },
        },
    )

    intermediate_marketing_complete_sensor = DataformWorkflowInvocationStateSensor(
        task_id="intermediate_marketing_complete_sensor",
        project_id=PROJECT_ID,
        region=LOCATION,
        repository_id=REPOSITORY_ID,
        workflow_invocation_id="{{ task_instance.xcom_pull('run_intermediate_marketing_models', key='workflow_invocation_id') }}",
        expected_statuses={"SUCCEEDED"},
        failure_statuses={"FAILED", "CANCELLING", "CANCELLED"},
        timeout=1800,
        poke_interval=60,
    )

    # ─────────────────────────────────────────────────────────────────────────
    # Phase 4b: Marketing warehouse models (NEW — 03-marketing-analytics)
    # fct_lead_funnel_events, fct_campaign_spend, fct_attribution_touches,
    # fct_opportunity_attribution, dim_campaign, dim_contact
    # ─────────────────────────────────────────────────────────────────────────

    run_warehouse_marketing = DataformCreateWorkflowInvocationOperator(
        task_id="run_warehouse_marketing_models",
        project_id=PROJECT_ID,
        region=LOCATION,
        repository_id=REPOSITORY_ID,
        workflow_invocation={
            "compilation_result": "{{ task_instance.xcom_pull('compile_dataform') }}",
            "invocation_config": {
                "included_tags": ["warehouse_marketing"],
                "fully_refresh_incremental_tables_enabled": False,
            },
        },
    )

    warehouse_marketing_complete_sensor = DataformWorkflowInvocationStateSensor(
        task_id="warehouse_marketing_complete_sensor",
        project_id=PROJECT_ID,
        region=LOCATION,
        repository_id=REPOSITORY_ID,
        workflow_invocation_id="{{ task_instance.xcom_pull('run_warehouse_marketing_models', key='workflow_invocation_id') }}",
        expected_statuses={"SUCCEEDED"},
        failure_statuses={"FAILED", "CANCELLING", "CANCELLED"},
        timeout=2400,  # fct_opportunity_attribution is a large full-refresh table
        poke_interval=60,
    )

    # ─────────────────────────────────────────────────────────────────────────
    # DAG dependency chain
    # ─────────────────────────────────────────────────────────────────────────

    (
        wait_for_fivetran
        >> run_staging
        >> staging_complete_sensor
        >> run_integration
        >> integration_complete_sensor
        >> run_warehouse
        >> warehouse_complete_sensor
        >> run_intermediate_marketing       # NEW: depends on staging
        >> intermediate_marketing_complete_sensor
        >> run_warehouse_marketing          # NEW: depends on intermediate_marketing
        >> warehouse_marketing_complete_sensor
    )
