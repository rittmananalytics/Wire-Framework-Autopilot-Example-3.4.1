# Glossary — Marketing Analytics
## Release: 03-marketing-analytics
## Core Dynamics Data Platform Modernisation

---

## Business Terms

**Attribution**
The process of assigning credit to marketing touchpoints that contributed to an opportunity or closed deal. Attribution answers the question: "Which marketing activities drove this pipeline?"

**Attribution Model**
A rule set that determines how credit is distributed across touchpoints in a customer journey. Core Dynamics uses five models: first-touch, last-touch, linear, time-decay, and U-shaped. See individual model definitions below.

**Attribution Window**
The lookback period during which marketing touches are considered for attribution. Core Dynamics uses a 180-day window — only touches within 180 days before opportunity creation are attributed. Touches older than 180 days are excluded.

**CAC (Customer Acquisition Cost)**
Total marketing spend divided by the number of new customers acquired in a given period. Expressed in dollars. Formula: `total_marketing_spend / new_customers`.

**Content Asset**
A piece of marketing content that a contact interacted with — e.g., a whitepaper, webinar, case study, or product demo. Content assets are mapped from HubSpot form submissions.

**First-Touch Attribution**
An attribution model that gives 100% of credit to the first marketing touch in a contact's journey. Good for measuring brand awareness channel effectiveness.

**Funnel Stage**
A defined point in the buyer journey: Subscriber → Lead → MQL → SAL → SQL → Opportunity. Each stage represents a progression of engagement and qualification.

**Lead**
A contact that has reached the "Lead" lifecycle stage in HubSpot — the first formal stage in the Core Dynamics funnel.

**Lead Conversion Touch**
In U-shaped attribution, the marketing touch closest in time to when a contact became a Sales Accepted Lead (SAL). This touch receives 40% of the attribution credit.

**Linear Attribution**
An attribution model that divides credit equally across all marketing touches in the journey. Good for understanding total channel involvement.

**LTV (Lifetime Value)**
The total revenue expected from a customer over their entire relationship. LTV data is not yet available — it will be in Release 05 (Customer Analytics, Q3 2026).

**LTV:CAC Ratio**
Customer Lifetime Value divided by Customer Acquisition Cost. A ratio of 3:1 or higher is typically considered healthy for B2B SaaS. Currently a placeholder in MA-03; LTV data available in Q3 2026.

**Marketing-Influenced**
An opportunity or revenue figure where at least one marketing touch occurred within 180 days before opportunity creation. Marketing-Influenced is always ≥ Marketing-Sourced.

**Marketing ROI**
Pipeline generated divided by marketing spend. Also expressed as a ratio (e.g., 4:1 means $4 of pipeline created per $1 spent).

**Marketing-Sourced**
An opportunity or revenue figure where the *first ever contact touch* was a marketing touch (e.g., a LinkedIn ad, Google Ads click, form fill) — before any SDR outreach. Marketing generated the lead.

**Middle Touch**
In U-shaped attribution, any touch that is neither the first touch nor the lead conversion (SAL) touch. Middle touches collectively receive 20% of attribution credit, split equally.

**MQL (Marketing Qualified Lead)**
A contact that has met the lead score threshold defined in HubSpot. Indicates sufficient engagement to be reviewed by the SDR team.

**Opportunity**
A qualified sales opportunity in Salesforce. Created after a contact is passed from SDR to Account Executive.

**Pipeline**
The total value of open or closed-won opportunities in Salesforce.

**SAL (Sales Accepted Lead)**
A Core Dynamics-specific lifecycle stage in HubSpot. An SDR has reviewed and accepted the lead for active follow-up. This is the marketing-to-sales handoff event.

**Sales-Sourced**
An opportunity where the first touch was an SDR outreach (e.g., cold email, LinkedIn InMail from a rep). No prior marketing touch is recorded.

**SQL (Sales Qualified Lead)**
A contact that has been qualified by an SDR and passed to an Account Executive. The SDR has confirmed fit against qualification criteria.

**Time-Decay Attribution**
An attribution model that gives more credit to touches closer in time to the opportunity creation date. Uses a 30-day half-life: a touch 30 days before opportunity creation gets half the weight of a touch on the day of creation.

**Touch (Marketing Touch)**
A recorded interaction between a prospect and a marketing asset or channel — e.g., a LinkedIn ad click, a Google Ads click-through, a HubSpot form fill, or a webinar registration.

**U-Shaped Attribution**
The recommended default attribution model for Core Dynamics. Distributes credit as: 40% to the first touch + 40% to the lead conversion touch (closest to SAL) + 20% split equally among middle touches. Also called "position-based" attribution.

**Unattributed Touch**
A marketing touch that lacks UTM parameters, making it impossible to identify the specific campaign or channel. Shown as `channel = 'unattributed'`. Approximately 30% of Core Dynamics touches are currently unattributed.

**UTM Parameters**
Tags appended to URLs in marketing campaigns (e.g., `?utm_source=linkedin&utm_medium=paid&utm_campaign=q1-2026-top-of-funnel`) that allow analytics tools to identify the origin of web traffic. Required for accurate channel attribution.

---

## Technical Terms

**assert_ (Dataform Assertion)**
A SQL-based test that runs against warehouse tables to validate data quality. If an assertion fails, it triggers an alert to `#data-platform-alerts`. Examples: `assert_attribution_weights_sum_to_one`, `assert_marketing_no_plain_text_email`.

**BigQuery**
Google Cloud's serverless data warehouse. All Core Dynamics analytics data is stored in BigQuery. Production project: `core-dynamics-analytics-prod`.

**Cloud Composer**
Google Cloud's managed Apache Airflow service. Orchestrates the daily data pipeline DAG (`dataform_run_dag`).

**dbt (data build tool)**
The SQL transformation framework used to build warehouse models. dbt models are SQL SELECT statements that dbt compiles and runs against BigQuery.

**dbt Seed**
A CSV file managed by dbt that is loaded into BigQuery as a static lookup table. Used for configurable business logic (e.g., UTM channel mapping, attribution model weights).

**dbt Variable (var)**
A configurable parameter in the dbt project. Attribution model weights and the 180-day window are stored as dbt vars in `dbt/dbt_project.yml`. Changing these requires a developer and a pipeline rerun.

**Dataform**
Google Cloud's SQL workflow tool used for data quality assertions and some pipeline orchestration. Runs SQL-based tests (assertions) against BigQuery tables.

**dim_campaign**
The campaign dimension table in `mart_marketing`. Contains one row per campaign across all ad platforms (Google Ads, LinkedIn, Meta).

**dim_contact**
The contact dimension table in `mart_marketing`. Contains one row per unified contact (HubSpot + Salesforce joined). Email is stored as a pseudonymised hash — not plain text.

**fct_attribution_touches**
A warehouse fact table containing one row per marketing touch per contact. Includes channel, campaign, UTM parameters, and content asset information.

**fct_campaign_spend**
A warehouse fact table with one row per campaign per day per platform, containing spend, impressions, and clicks.

**fct_lead_funnel_events**
A warehouse fact table with one row per contact per funnel stage transition. Used for MA-01 funnel volume charts.

**fct_opportunity_attribution**
The core attribution warehouse table. Contains one row per opportunity × attribution model × marketing touch. Supports all 5 attribution models simultaneously.

**Fivetran**
The SaaS data integration platform that replicates raw data from HubSpot, Salesforce, Google Ads, LinkedIn, Meta, and Outreach into BigQuery. Managed by Rittman Analytics.

**Integration Layer**
dbt models in `dbt/models/integration/` that join and unify data from multiple source systems. Examples: `int__contacts__unified` (joins HubSpot and Salesforce contacts), `int__marketing_touches__all_channels` (unifies touches from all platforms).

**LookML**
Looker's modelling language. Defines the business logic (metrics, dimensions, relationships) that Looker uses to generate SQL queries. Marketing LookML is in `.wire/releases/03-marketing-analytics/dev/semantic_layer/`.

**Looker**
The BI platform used to build and serve the MA-01, MA-02, and MA-03 dashboards. All end-user interaction with marketing data happens in Looker.

**mart_marketing**
The BigQuery dataset containing all marketing warehouse models (facts and dimensions). Location: `core-dynamics-analytics-prod.mart_marketing`.

**PII (Personally Identifiable Information)**
Information that could identify a specific individual — for example, an email address or phone number. Core Dynamics stores email as a SHA-256 pseudonymised hash to comply with GDPR/CCPA requirements.

**SHA-256 Hash**
A one-way cryptographic hash function. Email addresses are hashed to `SHA-256(LOWER(TRIM(email)))` before storage in the warehouse. The result is a 64-character hexadecimal string. The original email cannot be recovered from the hash.

**Staging Layer**
dbt models in `dbt/models/staging/` that clean and standardise raw source data without joining across systems. Created in Release 02; not modified in this release.

**Warehouse Layer**
dbt models in `dbt/models/warehouse/core/` that produce the final fact and dimension tables for analytics and Looker. Also called the mart layer.
