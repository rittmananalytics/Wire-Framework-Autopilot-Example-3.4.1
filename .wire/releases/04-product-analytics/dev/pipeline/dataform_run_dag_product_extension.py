"""
Cloud Composer DAG Extension — Product Analytics
Release: 04-product-analytics
Core Dynamics Data Platform Modernisation

This file replaces .wire/releases/03-marketing-analytics/dev/pipeline/dataform_run_dag_marketing_extension.py
in the Cloud Composer dags/ bucket. It adds two new product analytics phases to the existing pipeline.

Full pipeline execution order:
  1. run_staging_models               (02-data-foundation)
  2. staging_complete_sensor
  3. run_integration_models           (02-data-foundation)
  4. integration_complete_sensor
  5. run_warehouse_models             (02-data-foundation)
  6. warehouse_complete_sensor
  7a. run_intermediate_marketing_models  (03-marketing-analytics) ─┐
  7b. run_intermediate_product_models    (04-product-analytics)    ├─ parallel
  8a. intermediate_marketing_complete_sensor                       │
  8b. intermediate_product_complete_sensor                        ─┘
  9a. run_warehouse_marketing_models  (03-marketing-analytics)
  9b. run_warehouse_product_models    (04-product-analytics)
  10a. warehouse_marketing_complete_sensor
  10b. warehouse_product_complete_sensor
"""

import datetime
from airflow import DAG
from airflow.providers.google.cloud.operators.dataform import (
    DataformCreateWorkflowInvocationOperator,
)
from airflow.providers.google.cloud.sensors.dataform import (
    DataformWorkflowInvocationStateSensor,
)
from airflow.utils.dates import days_ago

PROJECT_ID = "core-dynamics-analytics-prod"
REGION = "us-central1"
REPOSITORY_ID = "core-dynamics-dataform"

DEFAULT_ARGS = {
    "owner": "rittman-analytics",
    "depends_on_past": False,
    "email_on_failure": True,
    "email": ["data-alerts@coredynamics.io"],
    "retries": 1,
    "retry_delay": datetime.timedelta(minutes=5),
}

with DAG(
    dag_id="dataform_run_dag",
    default_args=DEFAULT_ARGS,
    description="Core Dynamics full pipeline: staging → integration → warehouse → marketing + product",
    schedule_interval="0 2 * * *",  # 2am UTC daily
    start_date=days_ago(1),
    catchup=False,
    tags=["core-dynamics", "dataform", "marketing", "product"],
) as dag:

    # ── Phase 1: Staging ────────────────────────────────────────────────────
    run_staging = DataformCreateWorkflowInvocationOperator(
        task_id="run_staging_models",
        project_id=PROJECT_ID,
        region=REGION,
        repository_id=REPOSITORY_ID,
        workflow_invocation={
            "compilation_result": "{{ var.value.latest_compilation_result }}",
            "invocation_config": {
                "included_tags": ["staging"],
                "transitive_dependencies_included": True,
            },
        },
    )

    staging_sensor = DataformWorkflowInvocationStateSensor(
        task_id="staging_complete_sensor",
        project_id=PROJECT_ID,
        region=REGION,
        repository_id=REPOSITORY_ID,
        workflow_invocation_id="{{ task_instance.xcom_pull('run_staging_models', key='workflow_invocation_id') }}",
        expected_statuses=["SUCCEEDED"],
        timeout=3600,
        poke_interval=60,
    )

    # ── Phase 2: Integration ────────────────────────────────────────────────
    run_integration = DataformCreateWorkflowInvocationOperator(
        task_id="run_integration_models",
        project_id=PROJECT_ID,
        region=REGION,
        repository_id=REPOSITORY_ID,
        workflow_invocation={
            "compilation_result": "{{ var.value.latest_compilation_result }}",
            "invocation_config": {
                "included_tags": ["integration"],
                "transitive_dependencies_included": True,
            },
        },
    )

    integration_sensor = DataformWorkflowInvocationStateSensor(
        task_id="integration_complete_sensor",
        project_id=PROJECT_ID,
        region=REGION,
        repository_id=REPOSITORY_ID,
        workflow_invocation_id="{{ task_instance.xcom_pull('run_integration_models', key='workflow_invocation_id') }}",
        expected_statuses=["SUCCEEDED"],
        timeout=3600,
        poke_interval=60,
    )

    # ── Phase 3: Warehouse (core) ───────────────────────────────────────────
    run_warehouse = DataformCreateWorkflowInvocationOperator(
        task_id="run_warehouse_models",
        project_id=PROJECT_ID,
        region=REGION,
        repository_id=REPOSITORY_ID,
        workflow_invocation={
            "compilation_result": "{{ var.value.latest_compilation_result }}",
            "invocation_config": {
                "included_tags": ["warehouse"],
                "transitive_dependencies_included": True,
            },
        },
    )

    warehouse_sensor = DataformWorkflowInvocationStateSensor(
        task_id="warehouse_complete_sensor",
        project_id=PROJECT_ID,
        region=REGION,
        repository_id=REPOSITORY_ID,
        workflow_invocation_id="{{ task_instance.xcom_pull('run_warehouse_models', key='workflow_invocation_id') }}",
        expected_statuses=["SUCCEEDED"],
        timeout=3600,
        poke_interval=60,
    )

    # ── Phase 4a: Intermediate Marketing (parallel with product) ───────────
    run_intermediate_marketing = DataformCreateWorkflowInvocationOperator(
        task_id="run_intermediate_marketing_models",
        project_id=PROJECT_ID,
        region=REGION,
        repository_id=REPOSITORY_ID,
        workflow_invocation={
            "compilation_result": "{{ var.value.latest_compilation_result }}",
            "invocation_config": {
                "included_tags": ["intermediate_marketing"],
                "transitive_dependencies_included": True,
            },
        },
    )

    intermediate_marketing_sensor = DataformWorkflowInvocationStateSensor(
        task_id="intermediate_marketing_complete_sensor",
        project_id=PROJECT_ID,
        region=REGION,
        repository_id=REPOSITORY_ID,
        workflow_invocation_id="{{ task_instance.xcom_pull('run_intermediate_marketing_models', key='workflow_invocation_id') }}",
        expected_statuses=["SUCCEEDED"],
        timeout=1800,
        poke_interval=60,
    )

    # ── Phase 4b: Intermediate Product (parallel with marketing) ───────────
    run_intermediate_product = DataformCreateWorkflowInvocationOperator(
        task_id="run_intermediate_product_models",
        project_id=PROJECT_ID,
        region=REGION,
        repository_id=REPOSITORY_ID,
        workflow_invocation={
            "compilation_result": "{{ var.value.latest_compilation_result }}",
            "invocation_config": {
                "included_tags": ["intermediate_product"],
                "transitive_dependencies_included": True,
            },
        },
    )

    intermediate_product_sensor = DataformWorkflowInvocationStateSensor(
        task_id="intermediate_product_complete_sensor",
        project_id=PROJECT_ID,
        region=REGION,
        repository_id=REPOSITORY_ID,
        workflow_invocation_id="{{ task_instance.xcom_pull('run_intermediate_product_models', key='workflow_invocation_id') }}",
        expected_statuses=["SUCCEEDED"],
        timeout=1800,
        poke_interval=60,
    )

    # ── Phase 5a: Warehouse Marketing ──────────────────────────────────────
    run_warehouse_marketing = DataformCreateWorkflowInvocationOperator(
        task_id="run_warehouse_marketing_models",
        project_id=PROJECT_ID,
        region=REGION,
        repository_id=REPOSITORY_ID,
        workflow_invocation={
            "compilation_result": "{{ var.value.latest_compilation_result }}",
            "invocation_config": {
                "included_tags": ["warehouse_marketing"],
                "transitive_dependencies_included": True,
            },
        },
    )

    warehouse_marketing_sensor = DataformWorkflowInvocationStateSensor(
        task_id="warehouse_marketing_complete_sensor",
        project_id=PROJECT_ID,
        region=REGION,
        repository_id=REPOSITORY_ID,
        workflow_invocation_id="{{ task_instance.xcom_pull('run_warehouse_marketing_models', key='workflow_invocation_id') }}",
        expected_statuses=["SUCCEEDED"],
        timeout=2400,
        poke_interval=60,
    )

    # ── Phase 5b: Warehouse Product ─────────────────────────────────────────
    run_warehouse_product = DataformCreateWorkflowInvocationOperator(
        task_id="run_warehouse_product_models",
        project_id=PROJECT_ID,
        region=REGION,
        repository_id=REPOSITORY_ID,
        workflow_invocation={
            "compilation_result": "{{ var.value.latest_compilation_result }}",
            "invocation_config": {
                "included_tags": ["warehouse_product"],
                "transitive_dependencies_included": True,
            },
        },
    )

    warehouse_product_sensor = DataformWorkflowInvocationStateSensor(
        task_id="warehouse_product_complete_sensor",
        project_id=PROJECT_ID,
        region=REGION,
        repository_id=REPOSITORY_ID,
        workflow_invocation_id="{{ task_instance.xcom_pull('run_warehouse_product_models', key='workflow_invocation_id') }}",
        expected_statuses=["SUCCEEDED"],
        timeout=3600,  # fct_feature_usage incremental + dim_account_product_score full rebuild
        poke_interval=60,
    )

    # ── Dependency Chain ────────────────────────────────────────────────────
    # staging → integration → warehouse
    run_staging >> staging_sensor >> run_integration >> integration_sensor
    integration_sensor >> run_warehouse >> warehouse_sensor

    # warehouse → intermediate marketing AND intermediate product (parallel)
    warehouse_sensor >> run_intermediate_marketing >> intermediate_marketing_sensor
    warehouse_sensor >> run_intermediate_product >> intermediate_product_sensor

    # intermediate marketing → warehouse marketing
    intermediate_marketing_sensor >> run_warehouse_marketing >> warehouse_marketing_sensor

    # intermediate product → warehouse product
    intermediate_product_sensor >> run_warehouse_product >> warehouse_product_sensor
