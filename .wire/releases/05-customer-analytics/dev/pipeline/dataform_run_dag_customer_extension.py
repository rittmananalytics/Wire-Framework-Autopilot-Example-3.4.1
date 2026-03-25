"""
Cloud Composer DAG — Customer Analytics Extension
Release: 05-customer-analytics
Core Dynamics Data Platform Modernisation

Extends the existing dataform_run_dag.py to add customer analytics phases.
Customer phases run AFTER product phases (sequential — requires dim_account_product_score).
BQML training task runs conditionally on the 1st of each month.
BQML inference runs daily after customer warehouse models are built.

Deploy: Replace existing dataform_run_dag.py in Cloud Composer DAGs bucket.
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.google.cloud.operators.dataform import (
    DataformCreateWorkflowInvocationOperator,
)
from airflow.providers.google.cloud.operators.bigquery import BigQueryInsertJobOperator
from airflow.sensors.external_task import ExternalTaskSensor
from airflow.operators.python import BranchPythonOperator
from airflow.operators.empty import EmptyOperator

PROJECT_ID = "core-dynamics-analytics-prod"
REPOSITORY_ID = "core-dynamics-dataform"
REGION = "us-central1"

default_args = {
    "owner": "data-platform",
    "depends_on_past": False,
    "email": ["data-platform-alerts@coredynamics.io"],
    "email_on_failure": True,
    "email_on_retry": False,
    "retries": 2,
    "retry_delay": timedelta(minutes=10),
    "execution_timeout": timedelta(hours=2),
}

with DAG(
    dag_id="dataform_run_dag",
    default_args=default_args,
    description=(
        "Core Dynamics full platform DAG: staging → warehouse → "
        "marketing (parallel) → product (parallel) → customer → BQML"
    ),
    schedule_interval="0 5 * * *",  # 05:00 UTC daily
    start_date=datetime(2026, 3, 1),
    catchup=False,
    tags=["data-platform", "dataform", "bqml"],
) as dag:

    # ─────────────────────────────────────────
    # PHASE 1: STAGING
    # ─────────────────────────────────────────
    run_staging_models = DataformCreateWorkflowInvocationOperator(
        task_id="run_staging_models",
        project_id=PROJECT_ID,
        region=REGION,
        repository_id=REPOSITORY_ID,
        workflow_invocation={
            "compilation_result": "{{ var.value.latest_compilation_result }}",
            "invocation_config": {
                "included_tags": ["staging"],
                "fully_refresh_incremental_tables_enabled": False,
            },
        },
    )

    # ─────────────────────────────────────────
    # PHASE 2: WAREHOUSE (shared dims/facts)
    # ─────────────────────────────────────────
    run_warehouse_models = DataformCreateWorkflowInvocationOperator(
        task_id="run_warehouse_models",
        project_id=PROJECT_ID,
        region=REGION,
        repository_id=REPOSITORY_ID,
        workflow_invocation={
            "compilation_result": "{{ var.value.latest_compilation_result }}",
            "invocation_config": {
                "included_tags": ["warehouse_shared"],
                "fully_refresh_incremental_tables_enabled": False,
            },
        },
    )

    # Sensor: wait for warehouse completion before parallel phases
    warehouse_sensor = ExternalTaskSensor(
        task_id="warehouse_sensor",
        external_dag_id="dataform_run_dag",
        external_task_id="run_warehouse_models",
        timeout=3600,
        poke_interval=60,
        mode="reschedule",
    )

    # ─────────────────────────────────────────
    # PHASE 3A: MARKETING (parallel with product)
    # ─────────────────────────────────────────
    run_intermediate_marketing_models = DataformCreateWorkflowInvocationOperator(
        task_id="run_intermediate_marketing_models",
        project_id=PROJECT_ID,
        region=REGION,
        repository_id=REPOSITORY_ID,
        workflow_invocation={
            "compilation_result": "{{ var.value.latest_compilation_result }}",
            "invocation_config": {
                "included_tags": ["intermediate_marketing"],
                "fully_refresh_incremental_tables_enabled": False,
            },
        },
    )

    run_warehouse_marketing_models = DataformCreateWorkflowInvocationOperator(
        task_id="run_warehouse_marketing_models",
        project_id=PROJECT_ID,
        region=REGION,
        repository_id=REPOSITORY_ID,
        workflow_invocation={
            "compilation_result": "{{ var.value.latest_compilation_result }}",
            "invocation_config": {
                "included_tags": ["warehouse_marketing"],
                "fully_refresh_incremental_tables_enabled": False,
            },
        },
    )

    # ─────────────────────────────────────────
    # PHASE 3B: PRODUCT (parallel with marketing)
    # ─────────────────────────────────────────
    run_intermediate_product_models = DataformCreateWorkflowInvocationOperator(
        task_id="run_intermediate_product_models",
        project_id=PROJECT_ID,
        region=REGION,
        repository_id=REPOSITORY_ID,
        workflow_invocation={
            "compilation_result": "{{ var.value.latest_compilation_result }}",
            "invocation_config": {
                "included_tags": ["intermediate_product"],
                "fully_refresh_incremental_tables_enabled": False,
            },
        },
    )

    run_warehouse_product_models = DataformCreateWorkflowInvocationOperator(
        task_id="run_warehouse_product_models",
        project_id=PROJECT_ID,
        region=REGION,
        repository_id=REPOSITORY_ID,
        workflow_invocation={
            "compilation_result": "{{ var.value.latest_compilation_result }}",
            "invocation_config": {
                "included_tags": ["warehouse_product"],
                "fully_refresh_incremental_tables_enabled": False,
            },
        },
    )

    # Sensor: wait for product warehouse before customer phase (needs dim_account_product_score)
    product_sensor = ExternalTaskSensor(
        task_id="product_sensor",
        external_dag_id="dataform_run_dag",
        external_task_id="run_warehouse_product_models",
        timeout=3600,
        poke_interval=60,
        mode="reschedule",
    )

    # ─────────────────────────────────────────
    # PHASE 4: CUSTOMER (sequential after product)
    # ─────────────────────────────────────────
    run_intermediate_customer_models = DataformCreateWorkflowInvocationOperator(
        task_id="run_intermediate_customer_models",
        project_id=PROJECT_ID,
        region=REGION,
        repository_id=REPOSITORY_ID,
        workflow_invocation={
            "compilation_result": "{{ var.value.latest_compilation_result }}",
            "invocation_config": {
                "included_tags": ["intermediate_customer"],
                "fully_refresh_incremental_tables_enabled": False,
            },
        },
    )

    run_warehouse_customer_models = DataformCreateWorkflowInvocationOperator(
        task_id="run_warehouse_customer_models",
        project_id=PROJECT_ID,
        region=REGION,
        repository_id=REPOSITORY_ID,
        workflow_invocation={
            "compilation_result": "{{ var.value.latest_compilation_result }}",
            "invocation_config": {
                "included_tags": ["warehouse_customer"],
                "fully_refresh_incremental_tables_enabled": False,
            },
        },
    )

    # ─────────────────────────────────────────
    # PHASE 5: BQML
    # ─────────────────────────────────────────

    def is_first_of_month(**context):
        """Branch: return training task on 1st of month, else skip to inference."""
        execution_date = context["execution_date"]
        if execution_date.day == 1:
            return "bqml_train_churn_model"
        return "skip_bqml_training"

    bqml_branch = BranchPythonOperator(
        task_id="bqml_branch",
        python_callable=is_first_of_month,
    )

    skip_bqml_training = EmptyOperator(
        task_id="skip_bqml_training",
    )

    bqml_train_churn_model = BigQueryInsertJobOperator(
        task_id="bqml_train_churn_model",
        project_id=PROJECT_ID,
        configuration={
            "query": {
                "query": """
                    CREATE OR REPLACE MODEL `core-dynamics-analytics-prod.ml_models.customer_churn_logistic_reg`
                    OPTIONS (
                        model_type = 'logistic_reg',
                        input_label_cols = ['is_churned'],
                        max_iterations = 20,
                        learn_rate = 0.1,
                        l1_reg = 0.01,
                        l2_reg = 0.01,
                        data_split_method = 'random',
                        data_split_eval_fraction = 0.2
                    )
                    AS
                    SELECT
                        health_score,
                        product_component,
                        support_component,
                        financial_component,
                        relationship_component,
                        nps_component,
                        score_trend_7d,
                        COALESCE(score_change_7d, 0) AS score_change_7d,
                        is_churned
                    FROM `core-dynamics-analytics-prod.ml_models.customer_churn_training_set`
                    WHERE training_month >= DATE_SUB(CURRENT_DATE(), INTERVAL 24 MONTH)
                """,
                "useLegacySql": False,
                "location": REGION,
            }
        },
    )

    bqml_predict_churn = BigQueryInsertJobOperator(
        task_id="bqml_predict_churn",
        project_id=PROJECT_ID,
        configuration={
            "query": {
                "query": """
                    CREATE OR REPLACE TABLE `core-dynamics-analytics-prod.ml_models.customer_churn_predictions`
                    AS
                    SELECT
                        account_pk,
                        CURRENT_DATE() AS prediction_date,
                        predicted_is_churned_probs[OFFSET(1)].prob AS churn_probability,
                        CASE
                            WHEN predicted_is_churned_probs[OFFSET(1)].prob >= 0.65 THEN 'Critical'
                            WHEN predicted_is_churned_probs[OFFSET(1)].prob >= 0.40 THEN 'High'
                            WHEN predicted_is_churned_probs[OFFSET(1)].prob >= 0.20 THEN 'Medium'
                            ELSE 'Low'
                        END AS churn_risk_band,
                        'customer_churn_logistic_reg' AS model_version
                    FROM ML.PREDICT(
                        MODEL `core-dynamics-analytics-prod.ml_models.customer_churn_logistic_reg`,
                        (
                            SELECT *
                            FROM `core-dynamics-analytics-prod.mart_customer.dim_account_health`
                            WHERE score_date = CURRENT_DATE() - 1
                        )
                    )
                """,
                "useLegacySql": False,
                "location": REGION,
            }
        },
        trigger_rule="none_failed_or_skipped",  # runs whether training happened or not
    )

    # ─────────────────────────────────────────
    # DAG DEPENDENCIES
    # ─────────────────────────────────────────
    # Staging → Warehouse (shared)
    run_staging_models >> run_warehouse_models >> warehouse_sensor

    # Warehouse → Marketing + Product in PARALLEL
    warehouse_sensor >> run_intermediate_marketing_models >> run_warehouse_marketing_models
    warehouse_sensor >> run_intermediate_product_models >> run_warehouse_product_models

    # Product warehouse completion → Customer phase (sequential)
    run_warehouse_product_models >> product_sensor
    product_sensor >> run_intermediate_customer_models >> run_warehouse_customer_models

    # Customer warehouse → BQML branch → train (monthly) or skip → inference
    run_warehouse_customer_models >> bqml_branch
    bqml_branch >> bqml_train_churn_model >> bqml_predict_churn
    bqml_branch >> skip_bqml_training >> bqml_predict_churn
