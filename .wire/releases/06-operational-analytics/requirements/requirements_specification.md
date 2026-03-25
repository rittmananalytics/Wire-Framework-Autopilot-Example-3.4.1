# Requirements Specification — Operational Analytics
## Release: 06-operational-analytics
## Core Dynamics Data Platform Modernisation

**Client**: Core Dynamics, Inc.
**Prepared by**: Sophie Tanner, Rittman Analytics
**Date**: 2026-03-25
**Version**: 1.0

---

## 1. Executive Summary

Release 06 delivers operational analytics for Core Dynamics' Engineering and Operations teams. It integrates support (Zendesk), infrastructure incident (PagerDuty), cloud infrastructure cost (GCP Billing), and cloud monitoring (GCP Cloud Monitoring) data to produce three Looker dashboards: a support operations view (DO-01), an incident response and reliability view (DO-02), and a per-customer infrastructure cost view (DO-03). This release is a dbt_development type — models and semantic layer are delivered without workshops, mockups, or full enablement sessions.

The primary consumers are the Engineering team (David Park's CTO indirect reports), Support Operations (Tara Obinna's indirect reports via the support manager), and Finance (GCP cost per customer via DO-03). Release 06 is the final delivery release in the engagement.

---

## 2. Business Context

### 2.1 Problem Statement

Engineering teams have no structured view of support ticket trends correlated with engineering incidents. Infrastructure cost is tracked at project level (GCP Billing) but not attributed to individual customer accounts. PagerDuty incident data lives in a silo and is not cross-referenced with customer health or support tickets.

### 2.2 Strategic Goals

1. Enable Engineering to correlate incident frequency with support ticket volumes
2. Attribute GCP infrastructure cost to individual customer accounts for margin analysis
3. Provide Support Operations with ticket trend visibility (volume, CSAT, SLA compliance)
4. Give Finance a per-account infrastructure cost view for pricing and renewal decisions

### 2.3 Success Criteria

- DO-01 support operations view used by Support manager at weekly team standup within 30 days
- DO-03 per-customer cost view enables Finance to identify top 10 most expensive-to-serve accounts
- Incident-to-ticket correlation visible in DO-02 within 1 business day of go-live

---

## 3. Stakeholders

| Name | Role | Involvement |
|------|------|-------------|
| Tara Obinna | VP CS | Support ticket trends; cross-referencing with health |
| David Park | CFO | GCP cost per customer (DO-03) |
| Greg Ellison | Head of BI | Technical owner; Looker access provisioning |
| Engineering lead | CTO's team | PagerDuty incidents, GCP cost (name TBC) |
| Support manager | Tara's team | DO-01 daily user (name TBC) |

---

## 4. Functional Requirements

### FR-001: Support Ticket Operations
**Description**: Trend analysis of Zendesk support tickets by account, priority, CSAT, resolution time, and SLA compliance.
**Acceptance Criteria**:
- Ticket volume by month (trailing 12 months)
- CSAT distribution and average by tier/segment
- P1 resolution time vs SLA target (24 hours)
- Unresolved tickets > 7 days flagged
- `fct_support_tickets` model with grain = ticket, partitioned by created_date

### FR-002: Incident Response Tracking
**Description**: PagerDuty incident log with MTTR, incident frequency, severity distribution, and correlation with support ticket spikes.
**Acceptance Criteria**:
- Incident volume by week (trailing 24 months)
- MTTR (mean time to resolve) by severity
- Correlation view: incidents per week vs support tickets per week
- `fct_incident_response` model with grain = incident

### FR-003: Infrastructure Cost per Customer
**Description**: GCP Billing cost attributed to customer accounts by service (BigQuery, Cloud Composer, GCS, etc.).
**Acceptance Criteria**:
- Monthly cost per customer account (grain = account × service × month)
- Cost trend: trailing 12 months
- Top 10 most expensive accounts by total infrastructure cost
- `fct_infra_cost_by_customer` model
- Attribution method: proportional to account data volume (% of total BigQuery bytes processed)

### FR-004: Support Capacity Planning
**Description**: Trend of tickets per CSM to support capacity planning decisions.
**Acceptance Criteria**:
- Tickets per CSM per month (trailing 12 months)
- Open ticket backlog per CSM
- `fct_support_capacity` model with grain = csm × month

---

## 5. Non-Functional Requirements

- **Performance**: DO-01, DO-02, DO-03 load within 5 seconds
- **Freshness**: Support tickets daily; PagerDuty incidents daily; GCP Billing monthly (billing export delay)
- **Security**: GCP cost per customer restricted to `finance_viewers` and `leadership` in Looker
- **Data availability**: PagerDuty and GCP Billing Fivetran connectors set up by Greg Ellison before deployment

---

## 6. Data Requirements

| Source | Type | Owner | Volume | Refresh |
|--------|------|-------|--------|---------|
| Zendesk | Support | Support manager | ~5K tickets/yr | Daily (already in Release 02) |
| PagerDuty | Incidents | Engineering lead | ~500 incidents/yr | Daily (new Fivetran connector) |
| GCP Billing export | Cloud cost | Greg Ellison | Monthly billing export | Monthly |
| GCP Cloud Monitoring | Infrastructure | Greg Ellison | Metrics daily | Daily |
| stg_zendesk__* | Release 02 outputs | Data team | Staging | Daily |
| stg_salesforce__accounts | Release 02 outputs | Data team | 312 accounts | 6-hourly |

---

## 7. Technical Requirements

- **Platform**: BigQuery, dbt Core, Looker
- **New BigQuery dataset**: `mart_operations`
- **New Fivetran connectors** (Greg Ellison to provision): PagerDuty, GCP Billing export
- **dbt models location**: `dbt/models/warehouse/core/`
- **Looker model**: New `operations.model.lkml`; explores: `support_ops`, `incident_response`, `infra_cost`

---

## 8. Deliverables

| Deliverable | Artifact | Acceptance Criteria |
|-------------|---------|---------------------|
| Support ticket model | dbt: `fct_support_tickets` | Ticket grain, CSAT, resolution time, SLA flag |
| Incident response model | dbt: `fct_incident_response` | Incident grain, MTTR, severity, correlation join |
| Infrastructure cost model | dbt: `fct_infra_cost_by_customer` | Account × service × month; proportional attribution |
| Support capacity model | dbt: `fct_support_capacity` | CSM × month; ticket volume + backlog |
| DO-01 Support Operations | Looker dashboard | Weekly standup ready |
| DO-02 Incident Response | Looker dashboard | Incident × ticket correlation view |
| DO-03 Infrastructure Cost | Looker dashboard | Per-customer cost; finance-restricted ARR fields |
| Architecture documentation | Enablement | Architecture guide + operations runbook |

---

## 9. Timeline

| Milestone | Target |
|-----------|--------|
| Data model approved | Sprint 11 |
| dbt models built + tested | Sprint 11 |
| Dashboards built | Sprint 12 |
| Deployment | Sprint 12 |

---

## 10. Assumptions and Dependencies

- Zendesk staging models already deployed (Release 02)
- PagerDuty Fivetran connector provisioned by Greg Ellison before Sprint 11
- GCP Billing export to BigQuery configured by Greg Ellison
- CSM owner field in stg_zendesk__tickets populated (via account_pk join)
- GCP cost attribution: proportional to BigQuery bytes processed per account (approximation — exact attribution requires custom billing labels)

---

## 11. Scope Management

### In Scope
- Support ticket operations dbt models and DO-01 dashboard
- Incident response dbt models and DO-02 dashboard
- Infrastructure cost per customer dbt models and DO-03 dashboard
- Architecture documentation

### Out of Scope
- BambooHR employee analytics (data source not yet connected)
- Real-time support ticket streaming (batch daily)
- Automated PagerDuty incident creation from data alerts
- Engineering team training session (self-service; quick reference card only)
- Billing label automation (cost attribution is proportional approximation)
