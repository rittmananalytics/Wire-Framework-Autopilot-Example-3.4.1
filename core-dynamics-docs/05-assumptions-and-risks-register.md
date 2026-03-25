# Engagement Assumptions & Risks Register

**Document:** Engagement Assumptions & Risks Register
**Engagement:** Core Dynamics Data Platform (RA-2026-0041)
**Owner:** Daniel Osei (Project Manager)
**Last Updated:** 7 February 2026
**Version:** 1.1

---

| ID | Category | Assumption / Risk | Likelihood | Impact | Owner | Mitigation | Status |
|---|---|---|---|---|---|---|---|
| R-01 | Data Quality | Salesforce-HubSpot contact deduplication has 12% mismatch rate — marketing attribution coverage will be incomplete | Confirmed | High | Kofi Asante | Assess dedup logic in Phase 1; implement fuzzy matching at staging layer if required; document coverage gap | Open |
| R-02 | Data Quality | `Renewal_Date__c` null/incorrect for ~15% of Salesforce accounts pre-2023 | Confirmed | Medium | Ben Tran (client) | Ben to pursue Salesforce data clean-up sprint; document impact on BQML training data | Open |
| R-03 | Data Quality | ChurnZero historical data only available for 14 months (SoW assumes 24 months for BQML) | Confirmed | High | Sophie Tanner | Investigate Salesforce opportunity data as proxy for pre-ChurnZero period; adjust model card to document reduced training window | Open |
| R-04 | Data Quality | UTM parameter hygiene inconsistent — ~30% of campaigns untagged or non-standard | Confirmed | Medium | Niamh Collins (client) | Niamh running UTM audit; historic data gap accepted and documented; forward-looking enforcement to improve coverage | Open — client action |
| R-05 | Data Quality | GCP Billing label coverage for customer attribution unknown | Identified | High | Kofi Asante / Sean Murphy | Sean to prepare label coverage audit before operations discovery session; scope DO-02 appropriately | Open |
| R-06 | Data Quality | Segment and Mixpanel event overlap creates double-counting risk | Confirmed | Medium | Kofi Asante | Leon to provide event-to-source mapping; deduplication rules built into staging models | Open — awaiting client input |
| R-07 | Access / Dependency | CoreFM PostgreSQL network access not yet provisioned | In progress | High | Amara Diallo | Kofi and Sean to agree on Cloud SQL Auth Proxy configuration this week | In progress |
| R-08 | Access / Dependency | NetSuite integration role creation can take 2–3 weeks | Flagged | Medium | Sandra Kowalski (client) | Priya Nair to flag to Sandra; start process immediately even though Phase 2 dependency | In progress — Priya actioned |
| R-09 | Access / Dependency | ChurnZero has no native Fivetran connector — custom Cloud Function required | Known | Medium | Kofi Asante | Custom connector build scoped and included in SoW; allocated extra buffer in Phase 1 for debugging | In scope |
| R-10 | Scope | PII pseudonymisation approach requires legal sign-off (Diane Hooper) before implementation | New | Medium | Mark Rittman | Legal introduction actioned by Priya; target sign-off by end of Week 2 | Open |
| R-11 | Scope | Revised product engagement score weighting (post-discovery) requires sign-off from both Product and CS leads before build | New | Low | Sophie Tanner | Circulate revised weighting document to Claire Ashworth and Tara Obinna by EOD 9 Feb | Open |
| R-12 | Timeline | Stakeholder UAT availability in Phase 3 — four separate UAT windows in weeks 15–20 | Anticipated | Medium | Daniel Osei | Block UAT windows in stakeholder calendars during Week 2 to secure availability | Open |
| R-13 | Timeline | Claire Ashworth missed kickoff call — Product workstream discovery may be delayed | Mitigated | Low | Daniel Osei | Discovery session rescheduled and completed 5 Feb; no timeline impact | Closed |
| R-14 | Commercial | Out-of-scope remediation work (e.g., Salesforce data clean-up, UTM enforcement) may generate change requests | Anticipated | Medium | Mark Rittman | Maintain clear SoW boundary; raise change requests promptly with written approval before proceeding | Ongoing |

---

## Risk Summary

| Status | Count |
|---|---|
| Open | 9 |
| In Progress | 2 |
| Ongoing | 1 |
| Closed | 1 |
| **Total** | **13** |

| Impact Level | Count |
|---|---|
| High | 4 |
| Medium | 7 |
| Low | 2 |

---

*Document maintained in Google Drive: `/Core Dynamics — RA-2026-0041 / Project Management / Risks & Assumptions Register`*

*Next review: End of Phase 1 (End of Week 4)*
