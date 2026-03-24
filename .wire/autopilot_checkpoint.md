# Autopilot Checkpoint

## Configuration
- Engagement: data_platform_modernisation
- Client: Core Dynamics
- Lead: Mark Rittman
- SOW: sow.md
- Jira: WAEP
- Branch: feature/data_platform_modernisation

## SOW Summary
Core Dynamics, Inc. ($38.4M ARR, 312 enterprise accounts, Series C) sells CoreFM — a cloud-based facility and asset management SaaS — to enterprise customers in commercial real estate, manufacturing, healthcare, and higher education. Board target: improve NRR from 104% to 115% within 18 months.

Rittman Analytics will deliver a unified Google Cloud data platform (BigQuery, Dataform, Cloud Composer, Fivetran, Looker) over 22 weeks and $250,000. The platform serves four analytics domains: marketing, product, customer success, and operations, underpinned by a governed Looker semantic layer and a BigQuery ML churn risk model.

Key problems: no single source of truth; analyst bottleneck (James Petit spends 60% of time on manual exports); 8% MRR discrepancy between Sales/Finance/CS; no product usage visibility at account level; last-touch attribution only; operational data in spreadsheets.

Data sources (18): Salesforce, HubSpot, Google Ads, LinkedIn Ads, Meta Ads, Outreach.io, Clearbit, CoreFM PostgreSQL, Mixpanel, Segment, Intercom, ChurnZero, Zendesk, NetSuite, PagerDuty, GCP Billing, Cloud Monitoring, BambooHR.

Key constraints: PII pseudonymisation at staging layer (legal sign-off required from Diane Hooper); Looker RLS for CSM dashboards; Core Dynamics fiscal year starts 1 February; ChurnZero only 14 months of history (vs 24 needed for BQML — Salesforce opportunity data proposed as proxy).

Key stakeholder preferences from discovery docs:
- Tara Obinna: churn dashboard must show explainable signals (top 3 reasons), not just a score; prefer higher recall over precision for BQML (0.4 threshold); "what changed overnight" as default CS view
- Rachel Summers: U-shaped attribution as default model; 180-day marketing influence window (not 90-day); last 7 days as default date range on MA-01
- Leon Yip/Claire Ashworth: 3-level feature taxonomy (Module > Feature Group > Feature); SAL stage included in funnel; Segment as authoritative source for transactional events, Mixpanel for discovery/workflow events

## Engagement Structure
- Discovery release: .wire/releases/01-discovery/
- Delivery releases: (to be determined by sprint plan)

## Delivery Releases to Execute
| Release | Type | Scope |
|---------|------|-------|
| 02-data-foundation | pipeline_only | GCP setup, Fivetran connectors (18 sources), Dataform staging, Cloud Composer, data quality |
| 03-marketing-analytics | full_platform | Marketing warehouse models, LookML, MA-01/02/03 dashboards, multi-touch attribution |
| 04-product-analytics | full_platform | Product warehouse models (PII handling), product score, feature taxonomy, PB-01/02/03 dashboards |
| 05-customer-analytics | full_platform | Customer warehouse models, BQML churn model, RLS + Looker Actions, CA-01/02/03 dashboards |
| 06-operational-analytics | dbt_development | Operations warehouse models, LookML, DO-01/02/03 dashboards, documentation + KT |

## Completed Phases
- engagement_setup: complete
- discovery_sprint: complete (problem_definition, pitch, release_brief, sprint_plan — all approved)

## Current Phase
discovery_sprint: complete

## Key Context
- Data sources: Salesforce, HubSpot, Google Ads, LinkedIn Ads, Meta Ads, Outreach.io, Clearbit, CoreFM PostgreSQL, Mixpanel, Segment, Intercom, ChurnZero, Zendesk, NetSuite, PagerDuty, GCP Billing Export, Google Cloud Monitoring, BambooHR
- Key entities: Account, Contact/Lead, Opportunity, Campaign, Feature, Session, WorkOrder, Asset, SupportTicket, Incident
- Deliverables: 26 deliverables (D-01 to D-26) across Foundation, Marketing, Product, Customer, Operations, Semantic Layer
- Technologies: BigQuery, Dataform, Cloud Composer 2, Fivetran, Looker, BigQuery ML, GitHub, GCP
- SOW timeline: 22 weeks, 3 phases, $250,000

## Decisions Made
(none yet)

## Blocked Artifacts
(none)
