---
engagement_name: data_platform_modernisation
client_name: Core Dynamics
created_date: 2026-03-24
engagement_lead: Mark Rittman
repo_mode: combined
---

# Engagement Context

## Engagement
- **Name**: data_platform_modernisation
- **Client**: Core Dynamics
- **Engagement Lead**: Mark Rittman
- **Created**: 2026-03-24
- **Reference**: RA-2026-0041
- **Repo Mode**: combined

## Client Overview
Core Dynamics, Inc. is a mid-market B2B SaaS company (Series C, Austin TX) selling CoreFM — a cloud-based facility and asset management platform — to 312 enterprise accounts across commercial real estate, manufacturing, healthcare, and higher education. FY2025 ARR: $38.4M, ACV ~$123K, ~480 employees. Board target: improve NRR from 104% to 115% within 18 months.

## Engagement Objective
Design, build, and deliver a unified data platform on Google Cloud (BigQuery, Dataform, Cloud Composer, Fivetran, Looker) over 22 weeks ($250K) covering four analytics domains: marketing, product, customer success, and operations — underpinned by a governed Looker semantic layer.

## Technology Stack
- **Data Warehouse**: BigQuery (GCP projects: core-dynamics-analytics-prod, core-dynamics-analytics-dev)
- **Transformation**: Dataform (three-layer: staging → intermediate → warehouse)
- **Pipelines**: Fivetran (standard connectors) + custom Cloud Functions (ChurnZero, Clearbit)
- **Orchestration**: Cloud Composer 2 (Airflow)
- **BI / Semantic Layer**: Looker (LookML, governed metrics)
- **ML**: BigQuery ML (churn risk logistic regression model)
- **Source Control**: GitHub (Core Dynamics organisation)

## Key Stakeholders
| Role | Name | Workstream |
|------|------|------------|
| CTO / Executive Sponsor | Priya Nair | All |
| Data Engineering Lead (Primary Contact) | Amara Diallo | Foundation |
| VP Marketing | Rachel Summers | Marketing |
| Demand Gen Manager | Owen Brady | Marketing |
| Marketing Ops Manager | Niamh Collins | Marketing |
| VP Product | Claire Ashworth | Product |
| Senior PM (Core Platform) | Leon Yip | Product |
| VP Customer Success | Tara Obinna | Customer |
| CS Ops Manager | Ben Tran | Customer |
| COO | Harriet Drummond | Operations |
| Head of Support Engineering | Carlos Vega | Operations |
| CFO / Finance | Sandra Kowalski | Foundation |

## Rittman Analytics Team
| Role | Name |
|------|------|
| Engagement Lead | Mark Rittman |
| Senior Analytics Engineer | Sophie Tanner |
| Data Engineer | Kofi Asante |
| Looker Developer | Irina Volkov |
| Project Manager | Daniel Osei |

## Data Sources
18 in-scope sources: Salesforce, HubSpot, Google Ads, LinkedIn Ads, Meta Ads, Outreach.io, Clearbit, CoreFM PostgreSQL, Mixpanel, Segment, Intercom, ChurnZero, Zendesk, NetSuite, PagerDuty, GCP Billing Export, Google Cloud Monitoring, BambooHR.

## Key Risks
- R-01: 12% Salesforce-HubSpot contact mismatch rate (marketing attribution coverage gap)
- R-03: ChurnZero only 14 months of history (SoW assumes 24 for BQML)
- R-02: 15% null/incorrect Renewal_Date__c in Salesforce pre-2023
- R-04: ~30% of campaigns have non-standard or missing UTMs
- R-07: CoreFM PostgreSQL network access not yet provisioned
- R-10: PII pseudonymisation requires legal sign-off from Diane Hooper

## Constraints
- **Budget**: $250,000 total
- **Timeline**: 22 weeks (3 phases)
- **PII**: User PII pseudonymised at staging layer (one-way hash on user_id, account_id retained as join key)
- **Looker RLS**: CSMs only see their own accounts (user attribute-based row-level security)
- **Fiscal Year**: Core Dynamics fiscal year starts 1 February

## Out of Scope
- Real-time streaming dashboards (sub-minute latency)
- Self-service ETL tooling or data catalogue
- Predictive modelling beyond churn risk model
- Salesforce/HubSpot/Zendesk configuration changes
- GDPR/CCPA compliance review or legal sign-off
- Mobile or embedded analytics
- Ongoing managed service post-engagement

## Artifacts
- **kickoff_deck**: generated 2026-04-30 — `.wire/kickoff-deck.html`
