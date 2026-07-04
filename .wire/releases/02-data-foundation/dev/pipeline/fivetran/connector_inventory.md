# Fivetran Connector Inventory
## Core Dynamics Data Platform Modernisation

**Date**: 2026-03-24
**Fivetran Account**: Core Dynamics (Business Critical — to be provisioned)
**BigQuery Destination**: core-dynamics-analytics-prod

---

## Connector Summary

| # | Source | Connector Type | Sync Frequency | Destination Dataset | Credentials Owner | Status |
|---|--------|---------------|----------------|--------------------|--------------------|--------|
| 1 | Salesforce | Standard | Every 6 hours | raw_salesforce | Greg Fontaine / Ben Tran | [PENDING CREDENTIALS] |
| 2 | HubSpot | Standard | Every 1 hour | raw_hubspot | Niamh Collins | [PENDING CREDENTIALS] |
| 3 | Google Ads | Standard | Daily (3am UTC) | raw_google_ads | Owen Brady | [PENDING CREDENTIALS] |
| 4 | LinkedIn Ads | Standard | Daily (3am UTC) | raw_linkedin_ads | Owen Brady | [PENDING CREDENTIALS] |
| 5 | Meta Ads | Standard | Daily (3am UTC) | raw_meta_ads | Owen Brady | [PENDING CREDENTIALS] |
| 6 | Outreach.io | Standard | Every 6 hours | raw_outreach | Niamh Collins | [PENDING CREDENTIALS] |
| 7 | CoreFM PostgreSQL | Log-based CDC | 15 min (near real-time) | raw_corefm_db | Amara Diallo | [IN PROGRESS — Cloud SQL Auth Proxy] |
| 8 | Mixpanel | Standard | Daily (4am UTC) | raw_mixpanel | Leon Yip | [PENDING CREDENTIALS] |
| 9 | Intercom | Standard | Every 6 hours | raw_intercom | Julia Mercer | [PENDING CREDENTIALS] |
| 10 | Zendesk | Standard | Every 1 hour | raw_zendesk | Carlos Vega | [PENDING CREDENTIALS — CSAT access required] |
| 11 | NetSuite | Standard | Daily (5am UTC) | raw_netsuite | Sandra Kowalski | [IN PROGRESS — integration role creation, 2–3 weeks] |
| 12 | PagerDuty | Standard | Every 1 hour | raw_pagerduty | Sean Murphy | [PENDING CREDENTIALS — check enterprise API restrictions] |
| 13 | BambooHR | Standard | Daily (5am UTC) | raw_bamboohr | Mei Lin | [PENDING CREDENTIALS] |
| 14 | ChurnZero | **Custom Cloud Function** | Daily (6am UTC) | raw_churnzero | Ben Tran | [Custom build — see cloud_functions/churnzero_sync/] |
| 15 | Clearbit | **Custom Cloud Function** | On-demand (webhook) | raw_hubspot (clearbit schema) | Niamh Collins | [Custom build — see cloud_functions/clearbit_enrichment/] |
| 16 | Segment | BigQuery Destination (Segment-managed) | Streaming | raw_segment | Leon Yip | [PENDING SEGMENT DESTINATION CONFIG] |
| 17 | GCP Billing | Native BigQuery Export | Daily (T+1) | raw_gcp_billing | Sean Murphy | [IN PROGRESS — formalise existing export] |

---

## Connector Configuration Notes

### Salesforce
- Create a dedicated Fivetran API user in Salesforce with read-only access to all objects
- Objects to sync: Account, Contact, Lead, Opportunity, OpportunityLineItem, Campaign, CampaignMember, Contract, Task, Event
- Enable history tracking on Opportunity.StageName for funnel analysis
- **Risk**: `Renewal_Date__c` null/incorrect for ~15% of pre-2023 accounts — document in data quality notes

### HubSpot
- Use OAuth 2.0 Private App (not API key — deprecated)
- Required scopes: contacts, companies, deals, emails, forms, analytics, marketing-events
- **Risk**: 12% contact mismatch rate with Salesforce — fuzzy matching at staging layer

### CoreFM PostgreSQL
- Use Fivetran PostgreSQL log-based CDC connector
- Requires read-only service account on the PostgreSQL read-only replica
- Network access via Cloud SQL Auth Proxy (Kofi Asante + Sean Murphy to configure)
- Tables to sync: accounts, users, sessions, feature_events, work_orders, assets, reports, feature_taxonomy
- **PII**: user table contains email and name — pseudonymisation at Dataform staging layer; requires Priya Nair + legal sign-off first

### Zendesk
- Fivetran standard connector
- **Important**: Carlos Vega must ensure CSAT score export is accessible to the Fivetran connector (enterprise Zendesk may restrict this)

### NetSuite
- Requires a dedicated integration role in NetSuite (not a standard user)
- Role creation can take 2–3 weeks via NetSuite admin
- **Action required**: Sandra Kowalski to start integration role creation immediately

### ChurnZero (Custom)
See `cloud_functions/churnzero_sync/` for full implementation.
- REST API with API key authentication (Ben Tran to provide)
- Incremental sync via `updated_at` filter
- Objects: AccountHealth, NpsScore, HealthEvent, AccountSegment

### Clearbit (Custom)
See `cloud_functions/clearbit_enrichment/` for full implementation.
- Triggered by HubSpot new contact webhook
- Clearbit Company Enrichment API (domain-based lookup)
- Results written to raw_hubspot dataset, clearbit_enrichment table

---

## Fivetran BigQuery Destination Setup

```
Destination Type: BigQuery
Project ID: core-dynamics-analytics-prod
Dataset Location: us-central1 [To confirm with Amara Diallo]
Service Account: fivetran@core-dynamics-analytics-prod.iam.gserviceaccount.com
Table Prefix: (none — use source-specific dataset names)
Sync mode: Upsert (Fivetran default)
```

## Credential Request Template

Use the following template when requesting credentials from system owners:

```
Subject: Fivetran Connector Setup — [Source System] — Action Required

Hi [Name],

As part of the Core Dynamics Data Platform engagement, we need to configure a Fivetran
connector to sync data from [Source System] to BigQuery.

We need:
1. [Specific credential type — e.g., API key, OAuth app, service account]
2. [Required permissions — e.g., read-only access to Opportunities, Contacts]
3. [Any specific configuration — e.g., dedicated API user, not personal account]

Please provide credentials by [DATE — 5 business days].

If you have questions, please contact Kofi Asante (kofi@rittmananalytics.com).

Thank you,
Daniel Osei
```
