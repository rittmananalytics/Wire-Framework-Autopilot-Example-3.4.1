"""
Clearbit Enrichment Cloud Function — Core Dynamics Data Platform
Triggered by HubSpot webhook on new contact creation.
Calls Clearbit Company Enrichment API and stores firmographic data in BigQuery.

Author: Kofi Asante, Rittman Analytics
Date: 2026-03-24
"""

import json
import logging
import os
from datetime import datetime, timezone

import functions_framework
import requests
from google.cloud import bigquery, secretmanager

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

PROJECT_ID = os.environ.get("GCP_PROJECT", "core-dynamics-analytics-prod")
DATASET_ID = "raw_hubspot"
TABLE_ID = "clearbit_enrichment"
CLEARBIT_SECRET = f"projects/{PROJECT_ID}/secrets/clearbit-api-key/versions/latest"
CLEARBIT_API_URL = "https://company.clearbit.com/v2/companies/find"


def get_clearbit_key() -> str:
    client = secretmanager.SecretManagerServiceClient()
    response = client.access_secret_version(request={"name": CLEARBIT_SECRET})
    return response.payload.data.decode("UTF-8").strip()


def enrich_company(api_key: str, domain: str) -> dict | None:
    """Call Clearbit Company Enrichment API for a given domain."""
    headers = {"Authorization": f"Bearer {api_key}"}
    params = {"domain": domain}
    response = requests.get(CLEARBIT_API_URL, headers=headers, params=params, timeout=10)
    if response.status_code == 404:
        logger.info("Clearbit: no company found for domain %s", domain)
        return None
    response.raise_for_status()
    return response.json()


def write_to_bigquery(record: dict) -> None:
    client = bigquery.Client(project=PROJECT_ID)
    table_ref = f"{PROJECT_ID}.{DATASET_ID}.{TABLE_ID}"
    errors = client.insert_rows_json(table_ref, [record])
    if errors:
        logger.error("BigQuery insert errors: %s", errors)
        raise RuntimeError(f"BigQuery insert failed: {errors}")
    logger.info("Clearbit enrichment written to BigQuery for domain %s", record.get("domain"))


@functions_framework.http
def enrich_contact(request):
    """
    HubSpot webhook handler. Expects JSON payload with contact data.
    Extracts company domain and calls Clearbit for enrichment.
    """
    payload = request.get_json(silent=True)
    if not payload:
        return {"error": "Empty payload"}, 400

    # HubSpot webhook sends an array of events
    events = payload if isinstance(payload, list) else [payload]

    api_key = get_clearbit_key()
    bq_client = bigquery.Client(project=PROJECT_ID)
    enriched_count = 0

    for event in events:
        contact_id = event.get("objectId") or event.get("contactId")
        properties = event.get("properties", {})
        email = properties.get("email", {}).get("value", "")
        domain = email.split("@")[-1] if "@" in email else properties.get("domain", {}).get("value", "")

        if not domain:
            logger.info("No domain found for contact %s, skipping", contact_id)
            continue

        enrichment = enrich_company(api_key, domain)
        if enrichment:
            record = {
                "hubspot_contact_id": str(contact_id),
                "domain": domain,
                "clearbit_company_name": enrichment.get("name"),
                "clearbit_industry": enrichment.get("category", {}).get("industry"),
                "clearbit_sub_industry": enrichment.get("category", {}).get("subIndustry"),
                "clearbit_sector": enrichment.get("category", {}).get("sector"),
                "clearbit_employees": enrichment.get("metrics", {}).get("employees"),
                "clearbit_employees_range": enrichment.get("metrics", {}).get("employeesRange"),
                "clearbit_annual_revenue": enrichment.get("metrics", {}).get("annualRevenue"),
                "clearbit_raised": enrichment.get("metrics", {}).get("raised"),
                "clearbit_country_code": enrichment.get("geo", {}).get("countryCode"),
                "clearbit_state_code": enrichment.get("geo", {}).get("stateCode"),
                "clearbit_city": enrichment.get("geo", {}).get("city"),
                "clearbit_linkedin_handle": enrichment.get("linkedin", {}).get("handle"),
                "clearbit_tech_stack": json.dumps(enrichment.get("tech", [])),
                "clearbit_tags": json.dumps(enrichment.get("tags", [])),
                "clearbit_raw": json.dumps(enrichment),
                "_sync_timestamp": datetime.now(timezone.utc).isoformat(),
            }
            write_to_bigquery(record)
            enriched_count += 1

    return {"status": "success", "enriched": enriched_count}, 200
