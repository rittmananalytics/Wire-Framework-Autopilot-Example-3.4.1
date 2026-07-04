"""
ChurnZero Incremental Sync — Cloud Function
Core Dynamics Data Platform Modernisation

Syncs health scores, NPS scores, health events, and account segments
from ChurnZero REST API to BigQuery (raw_churnzero dataset).

Triggered by Cloud Scheduler daily at 06:00 UTC.

Author: Kofi Asante, Rittman Analytics
Date: 2026-03-24
"""

import json
import logging
import os
from datetime import datetime, timedelta, timezone

import functions_framework
import requests
from google.cloud import bigquery, secretmanager

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

PROJECT_ID = os.environ.get("GCP_PROJECT", "core-dynamics-analytics-prod")
DATASET_ID = "raw_churnzero"
SECRET_NAME = f"projects/{PROJECT_ID}/secrets/churnzero-api-key/versions/latest"

CHURNZERO_BASE_URL = "https://analytics.churnzero.net/api/v1"

OBJECTS_TO_SYNC = [
    {
        "name": "account_health_scores",
        "endpoint": "/accounts",
        "table": "account_health_scores",
        "updated_at_field": "modifiedDate",
    },
    {
        "name": "nps_scores",
        "endpoint": "/nps",
        "table": "nps_scores",
        "updated_at_field": "responseDate",
    },
    {
        "name": "account_segments",
        "endpoint": "/segments/accounts",
        "table": "account_segments",
        "updated_at_field": "modifiedDate",
    },
]


def get_api_key() -> str:
    """Retrieve ChurnZero API key from Secret Manager."""
    client = secretmanager.SecretManagerServiceClient()
    response = client.access_secret_version(request={"name": SECRET_NAME})
    return response.payload.data.decode("UTF-8").strip()


def get_last_sync_watermark(bq_client: bigquery.Client, table_id: str) -> str:
    """
    Get the last sync watermark from BigQuery for incremental sync.
    Returns ISO format datetime string; defaults to 30 days ago if table is empty.
    """
    table_ref = f"{PROJECT_ID}.{DATASET_ID}.{table_id}"
    query = f"SELECT MAX(_sync_timestamp) as last_sync FROM `{table_ref}`"
    try:
        result = list(bq_client.query(query).result())
        if result and result[0].last_sync:
            return result[0].last_sync.isoformat()
    except Exception:
        pass
    # Default: 30 days ago (or full history on first run)
    return (datetime.now(timezone.utc) - timedelta(days=30)).isoformat()


def fetch_churnzero_records(
    api_key: str,
    endpoint: str,
    updated_since: str,
    page_size: int = 1000,
) -> list[dict]:
    """Paginate through ChurnZero API and return all records updated since watermark."""
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
    }
    params = {
        "modifiedAfter": updated_since,
        "pageSize": page_size,
        "page": 1,
    }
    all_records: list[dict] = []
    url = f"{CHURNZERO_BASE_URL}{endpoint}"

    while True:
        response = requests.get(url, headers=headers, params=params, timeout=30)
        response.raise_for_status()
        data = response.json()

        records = data.get("data", data) if isinstance(data, dict) else data
        if not records:
            break

        all_records.extend(records)
        logger.info(
            "Fetched %d records from %s (page %d)",
            len(records),
            endpoint,
            params["page"],
        )

        if len(records) < page_size:
            break
        params["page"] += 1

    return all_records


def enrich_records(records: list[dict], object_name: str) -> list[dict]:
    """Add pipeline metadata to each record."""
    sync_ts = datetime.now(timezone.utc).isoformat()
    return [
        {
            **record,
            "_sync_timestamp": sync_ts,
            "_source_object": object_name,
        }
        for record in records
    ]


def load_to_bigquery(
    bq_client: bigquery.Client,
    records: list[dict],
    table_id: str,
) -> int:
    """Load records to BigQuery using streaming inserts (upsert via MERGE handled by Dataform)."""
    if not records:
        logger.info("No records to load for %s", table_id)
        return 0

    table_ref = f"{PROJECT_ID}.{DATASET_ID}.{table_id}"
    job_config = bigquery.LoadJobConfig(
        write_disposition=bigquery.WriteDisposition.WRITE_APPEND,
        source_format=bigquery.SourceFormat.NEWLINE_DELIMITED_JSON,
        autodetect=True,
    )

    import io
    ndjson = "\n".join(json.dumps(r) for r in records)
    load_job = bq_client.load_table_from_file(
        io.StringIO(ndjson),
        table_ref,
        job_config=job_config,
    )
    load_job.result()
    logger.info("Loaded %d rows to %s", len(records), table_ref)
    return len(records)


@functions_framework.http
def sync_churnzero(request):
    """HTTP-triggered Cloud Function entry point (also used by Cloud Scheduler)."""
    logger.info("ChurnZero sync started at %s", datetime.now(timezone.utc).isoformat())

    api_key = get_api_key()
    bq_client = bigquery.Client(project=PROJECT_ID)

    total_loaded = 0
    errors = []

    for obj in OBJECTS_TO_SYNC:
        try:
            watermark = get_last_sync_watermark(bq_client, obj["table"])
            logger.info("Syncing %s updated since %s", obj["name"], watermark)

            records = fetch_churnzero_records(api_key, obj["endpoint"], watermark)
            enriched = enrich_records(records, obj["name"])
            loaded = load_to_bigquery(bq_client, enriched, obj["table"])
            total_loaded += loaded
            logger.info("Synced %d records for %s", loaded, obj["name"])

        except Exception as exc:
            logger.error("Error syncing %s: %s", obj["name"], exc, exc_info=True)
            errors.append({"object": obj["name"], "error": str(exc)})

    if errors:
        logger.error("Sync completed with %d errors: %s", len(errors), errors)
        return {"status": "partial", "loaded": total_loaded, "errors": errors}, 500

    logger.info(
        "ChurnZero sync complete. Total records loaded: %d", total_loaded
    )
    return {"status": "success", "loaded": total_loaded}, 200
