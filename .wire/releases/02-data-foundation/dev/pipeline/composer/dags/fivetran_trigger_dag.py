"""
Fivetran Trigger DAG — Core Dynamics Data Platform
Triggers Fivetran syncs in dependency order.

Dependency order:
1. Core foundation sources: Salesforce, HubSpot, Zendesk (needed by multiple workstreams)
2. Product sources: CoreFM PostgreSQL, Mixpanel, Segment, Intercom
3. Marketing sources: Google Ads, LinkedIn Ads, Meta Ads, Outreach
4. Finance/Ops sources: NetSuite, PagerDuty, GCP Billing, BambooHR
5. Custom sources: ChurnZero (Cloud Function trigger)

Author: Kofi Asante, Rittman Analytics
Date: 2026-03-24
"""

from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.google.cloud.operators.functions import (
    CloudFunctionInvokeFunctionOperator,
)
from airflow.providers.http.operators.http import SimpleHttpOperator

default_args = {
    "owner": "rittman-analytics",
    "depends_on_past": False,
    "start_date": datetime(2026, 3, 25),
    "email": ["data-alerts@rittmananalytics.com", "amara.diallo@coredynamics.io"],
    "email_on_failure": True,
    "email_on_retry": False,
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
}

FIVETRAN_CONNECTOR_IDS = {
    # To be populated with actual Fivetran connector IDs during setup
    "salesforce": "CONNECTOR_ID_SALESFORCE",  # [To configure with Amara Diallo]
    "hubspot": "CONNECTOR_ID_HUBSPOT",
    "zendesk": "CONNECTOR_ID_ZENDESK",
    "corefm_postgresql": "CONNECTOR_ID_COREFM_DB",
    "mixpanel": "CONNECTOR_ID_MIXPANEL",
    "intercom": "CONNECTOR_ID_INTERCOM",
    "google_ads": "CONNECTOR_ID_GOOGLE_ADS",
    "linkedin_ads": "CONNECTOR_ID_LINKEDIN_ADS",
    "meta_ads": "CONNECTOR_ID_META_ADS",
    "outreach": "CONNECTOR_ID_OUTREACH",
    "netsuite": "CONNECTOR_ID_NETSUITE",
    "pagerduty": "CONNECTOR_ID_PAGERDUTY",
    "bamboohr": "CONNECTOR_ID_BAMBOOHR",
}

GCP_PROJECT = "core-dynamics-analytics-prod"
GCP_REGION = "us-central1"


def trigger_fivetran_sync(connector_id: str, **context) -> None:
    """Trigger a Fivetran connector sync via API and wait for completion."""
    import time

    import requests
    from google.cloud import secretmanager

    secret_client = secretmanager.SecretManagerServiceClient()
    secret_name = f"projects/{GCP_PROJECT}/secrets/fivetran-api-credentials/versions/latest"
    creds_json = secret_client.access_secret_version(request={"name": secret_name})
    creds = __import__("json").loads(creds_json.payload.data.decode("UTF-8"))

    api_key = creds["api_key"]
    api_secret = creds["api_secret"]

    # Trigger sync
    trigger_resp = requests.post(
        f"https://api.fivetran.com/v1/connectors/{connector_id}/sync",
        auth=(api_key, api_secret),
        timeout=30,
    )
    trigger_resp.raise_for_status()

    # Poll for completion (max 30 minutes)
    for _ in range(180):
        time.sleep(10)
        status_resp = requests.get(
            f"https://api.fivetran.com/v1/connectors/{connector_id}",
            auth=(api_key, api_secret),
            timeout=30,
        )
        status_resp.raise_for_status()
        status = status_resp.json()["data"]["status"]["sync_state"]
        if status == "scheduled":
            return
        if status in ("failed", "broken"):
            raise RuntimeError(f"Fivetran sync failed for connector {connector_id}: {status}")


with DAG(
    dag_id="fivetran_trigger_dag",
    default_args=default_args,
    description="Trigger Fivetran syncs in dependency order for Core Dynamics",
    schedule_interval="0 6 * * *",  # Daily at 06:00 UTC (after daily sources)
    catchup=False,
    tags=["core-dynamics", "fivetran", "ingestion"],
) as dag:

    # Group 1: Foundation sources (parallel)
    sync_salesforce = PythonOperator(
        task_id="sync_salesforce",
        python_callable=trigger_fivetran_sync,
        op_kwargs={"connector_id": FIVETRAN_CONNECTOR_IDS["salesforce"]},
    )
    sync_hubspot = PythonOperator(
        task_id="sync_hubspot",
        python_callable=trigger_fivetran_sync,
        op_kwargs={"connector_id": FIVETRAN_CONNECTOR_IDS["hubspot"]},
    )
    sync_zendesk = PythonOperator(
        task_id="sync_zendesk",
        python_callable=trigger_fivetran_sync,
        op_kwargs={"connector_id": FIVETRAN_CONNECTOR_IDS["zendesk"]},
    )

    # Group 2: Product sources (depend on Salesforce for account join)
    sync_corefm_db = PythonOperator(
        task_id="sync_corefm_db",
        python_callable=trigger_fivetran_sync,
        op_kwargs={"connector_id": FIVETRAN_CONNECTOR_IDS["corefm_postgresql"]},
    )
    sync_mixpanel = PythonOperator(
        task_id="sync_mixpanel",
        python_callable=trigger_fivetran_sync,
        op_kwargs={"connector_id": FIVETRAN_CONNECTOR_IDS["mixpanel"]},
    )
    sync_intercom = PythonOperator(
        task_id="sync_intercom",
        python_callable=trigger_fivetran_sync,
        op_kwargs={"connector_id": FIVETRAN_CONNECTOR_IDS["intercom"]},
    )

    # Group 3: Marketing sources
    sync_google_ads = PythonOperator(
        task_id="sync_google_ads",
        python_callable=trigger_fivetran_sync,
        op_kwargs={"connector_id": FIVETRAN_CONNECTOR_IDS["google_ads"]},
    )
    sync_linkedin_ads = PythonOperator(
        task_id="sync_linkedin_ads",
        python_callable=trigger_fivetran_sync,
        op_kwargs={"connector_id": FIVETRAN_CONNECTOR_IDS["linkedin_ads"]},
    )
    sync_meta_ads = PythonOperator(
        task_id="sync_meta_ads",
        python_callable=trigger_fivetran_sync,
        op_kwargs={"connector_id": FIVETRAN_CONNECTOR_IDS["meta_ads"]},
    )
    sync_outreach = PythonOperator(
        task_id="sync_outreach",
        python_callable=trigger_fivetran_sync,
        op_kwargs={"connector_id": FIVETRAN_CONNECTOR_IDS["outreach"]},
    )

    # Group 4: Finance/Ops sources
    sync_netsuite = PythonOperator(
        task_id="sync_netsuite",
        python_callable=trigger_fivetran_sync,
        op_kwargs={"connector_id": FIVETRAN_CONNECTOR_IDS["netsuite"]},
    )
    sync_pagerduty = PythonOperator(
        task_id="sync_pagerduty",
        python_callable=trigger_fivetran_sync,
        op_kwargs={"connector_id": FIVETRAN_CONNECTOR_IDS["pagerduty"]},
    )
    sync_bamboohr = PythonOperator(
        task_id="sync_bamboohr",
        python_callable=trigger_fivetran_sync,
        op_kwargs={"connector_id": FIVETRAN_CONNECTOR_IDS["bamboohr"]},
    )

    # Group 5: Custom Cloud Function triggers
    trigger_churnzero = CloudFunctionInvokeFunctionOperator(
        task_id="trigger_churnzero_sync",
        function_id="churnzero_sync",
        location=GCP_REGION,
        project_id=GCP_PROJECT,
        input_data={},
    )

    # Dependencies: Product and marketing sources depend on Salesforce
    sync_salesforce >> [sync_corefm_db, sync_google_ads, sync_outreach]
    sync_hubspot >> [sync_google_ads, sync_linkedin_ads, sync_meta_ads]
    sync_zendesk >> sync_pagerduty

    # ChurnZero sync can run in parallel with Fivetran syncs
    [sync_salesforce, sync_hubspot] >> trigger_churnzero
