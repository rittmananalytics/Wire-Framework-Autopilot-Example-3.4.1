# Stakeholder Interview Notes — Tara Obinna, VP Customer Success

**Interview Type:** Workstream Discovery — Customer Analytics
**Date:** Thursday, 5 February 2026
**Duration:** 95 minutes
**Interviewer:** Mark Rittman, Sophie Tanner
**Note-taker:** Daniel Osei
**Interviewee:** Tara Obinna, VP Customer Success
**Also present:** Ben Tran, CS Ops Manager

---

## Context & Background

Tara joined Core Dynamics 18 months ago from a VP CS role at a Series B infrastructure SaaS company. She inherited a CS team that was predominantly reactive — focused on QBR delivery and renewal calls rather than proactive health management. She has 14 CSMs, split across three geographic pods (Americas, EMEA, APAC). Ben Tran joined as CS Ops Manager eight months ago and has been the main person trying to build data-driven rigour into CS processes.

---

## Current State of Data & Tooling

**Q: Walk us through how you currently track customer health today.**

**Tara:** ChurnZero is our platform of record for health scoring. But honestly, I have low confidence in the scores it generates. ChurnZero's health score is based primarily on login events — a customer logs in regularly, they get a green score. A customer who hasn't logged in for three weeks goes amber. That's it, basically. It doesn't know whether they're actually using the product or just logging in to look at a dashboard. It doesn't factor in whether they've raised five P1 tickets in the last month. And it definitely doesn't know how their contract is performing relative to their original business case.

**Ben Tran:** The other problem is there's no connection between ChurnZero and Salesforce's renewal data. Tara and I have to manually reconcile the renewal pipeline every Monday morning by pulling a report from each system and doing a VLOOKUP. It takes about two hours every single week.

**Q: What signals do you currently use to identify at-risk accounts?**

**Tara:** Honestly? Gut feel and quarterly touchpoints. If a CSM has a bad call with an account, they'll flag it. If a renewal comes up and the account hasn't responded to outreach, we treat it as at-risk. But we almost never identify risk proactively — we tend to find out when the account either raises a formal concern or when they decline the renewal call. By then it's usually too late.

**Ben:** We also use NPS as a lagging signal. We send NPS surveys through Intercom every six months. But six months is a long time — an account can go from a nine to a detractor in two months and we won't know until the next survey cycle.

**Q: Can you give me an example of a churn you wished you'd caught earlier?**

**Tara:** Last quarter we lost one of our top-twenty accounts — Meridian Healthcare, about $340K ARR. They churned completely. In hindsight, the signals were all there for four months: their feature usage had dropped significantly, they'd had three support escalations, and one of their internal champions had left the company. But we didn't join those dots until the executive there told us they were evaluating alternatives. That was a $340K miss that I'm confident we could have at least contested if we'd had an early warning system.

---

## Requirements Deep Dive

**Q: If you could build the ideal CS dashboard from scratch, what would you put on it?**

**Tara:** First thing every morning, I want to see: what changed overnight. Which accounts got worse? Which ones improved? I don't want to look at everything every day — I want the system to tell me what I need to pay attention to. So the default view should be "alerts and changes since yesterday," not a static list of all 312 accounts sorted alphabetically.

**Ben:** For the individual CSM view, the most important thing is prioritisation. A CSM managing forty accounts needs to know: which three accounts do I need to call today? Right now they have to figure that out themselves, which means they call the accounts they like talking to rather than the accounts that need attention.

**Q: Tell me more about the "reasons" requirement you mentioned in the kickoff call.**

**Tara:** Yes. The score alone is useless. If I see an account is "High Risk," I need to know why. And I need the why to be specific enough that a CSM can take action. "Product engagement dropped" is too vague. "Asset management module usage dropped 60% last month compared to their previous three-month average" is actionable — a CSM can email the key users and ask what's changed.

**Sophie Tanner:** So you'd want the contributing signals ranked by impact? Like, "the top three reasons this account is at risk are..."?

**Tara:** Exactly. And ideally the system would suggest a recommended action alongside each reason. "Usage drop in a core module — recommended action: schedule a feature health check call with the admin user." We use a playbook system in ChurnZero for this but it's very manual and nobody maintains it. If the system could surface the right play automatically based on the signals, that would be transformative.

> **Note for Sophie:** Consider whether Looker Actions can trigger a Salesforce task with a predefined task template based on the leading risk signal. Worth scoping as a potential Phase 3 enhancement.

**Q: On the expansion signals — what does a good expansion opportunity look like for you?**

**Ben:** Three main categories. First, unused licences — a customer bought 200 seats and only 120 are active users. That's a conversation about either reducing their contract (which we want to avoid) or activating the dormant users. Second, module gaps — they're on the base CoreFM package and not using the Maintenance Management or Energy Management modules at all, even though they're applicable to their business. Third, multi-site potential — we know they have other facilities or business units that aren't yet on CoreFM.

**Tara:** The multi-site one is the biggest revenue opportunity but it's the hardest to track because it requires knowing something about the customer's corporate structure that isn't in our system. We'd need to pull that from Salesforce account hierarchy data, which is inconsistently maintained.

> **Note for Kofi:** Flag Salesforce account hierarchy data quality as a potential gap. May require data enrichment (Clearbit) or manual cleanup campaign before expansion signals are reliable.

**Q: How do you want to handle the QBR preparation use case?**

**Tara:** Right now a CSM spends three to five hours preparing a QBR deck. They're pulling ARR from Salesforce, product usage from wherever they can get it, support ticket summary from Zendesk, NPS from Intercom. It's a nightmare. The SoW mentions a "one-click QBR data pull" — I want to understand what that actually means in practice.

**Sophie Tanner:** The idea is a Looker Action on the CSM Book of Business dashboard — you click a button next to an account, and it generates a pre-populated Google Slides deck with the account's metrics already filled in. ARR, health score trend, product engagement, support summary, renewal date. The CSM then just adds the narrative and their notes. It won't eliminate QBR prep time entirely but it should take it from five hours to one hour.

**Tara:** That alone would be a massive win. My CSMs will love you if you deliver that.

**Q: On the churn risk model — what's your risk appetite for false positives versus false negatives?**

**Ben:** What do you mean by that exactly?

**Sophie Tanner:** A false positive is an account the model flags as high-risk that's actually fine. A false negative is an account that churns that the model didn't flag. There's usually a trade-off — if you make the model more sensitive, you catch more real churn risk, but you also generate more false alarms and CSMs start ignoring the alerts because they're not reliable.

**Tara:** I'd rather have more false positives than false negatives. If the model tells a CSM to reach out to an account that turns out to be fine, the worst that happens is the CSM has a good proactive call. If the model misses a real churn risk, we lose ARR. So I'd err toward sensitivity.

> **Note for Sophie:** Calibrate the BQML model threshold toward higher recall, lower precision. Discuss with Tara during model evaluation review whether a 0.4 probability threshold (rather than 0.5) is appropriate given this preference.

---

## Data Quality & Access Notes

- **ChurnZero:** Ben Tran has admin access and can generate API tokens. Historical health score data goes back approximately 14 months — *this is below the 24-month requirement in the SoW for BQML training data. Needs flagging.* Ben believes the 24-month gap can be partially addressed using historical Salesforce opportunity data as a proxy.
- **Salesforce renewal data:** Ben acknowledges that Salesforce `Renewal_Date__c` field has approximately 15% null or incorrect values for accounts predating the Salesforce implementation in 2023. This will need a data quality remediation sprint or a documented exception in the model.
- **Zendesk:** Carlos Vega's team has restricted the CSAT export. Ben will speak to Carlos to ensure the Fivetran connector has access to CSAT scores.
- **CSM assignment in Salesforce:** Currently tracked in a custom field `CSM_Owner__c`. Ben confirms it is kept up to date when accounts are reassigned, but noted there were about three months in 2024 when it was not consistently maintained. This will create a gap in historical CSM attribution.

---

## Agreed Priorities (ranked by Tara)

1. Early warning system — accounts entering At Risk band with explainable signals *(Critical)*
2. CSM Book of Business with daily prioritised action list *(Critical)*
3. NRR / GRR tracking with segment and CSM-level cuts *(High)*
4. Expansion signals dashboard *(High)*
5. QBR one-click data pull *(Medium — high CSM satisfaction impact)*
6. Churn risk model with probability scores *(Medium — dependent on data quality resolution)*

---

## Open Questions / Follow-ups

| Question | Owner | Due |
|---|---|---|
| Can ChurnZero historical data prior to 14 months be approximated using Salesforce opportunity data? | Ben Tran + Sophie Tanner | Before Phase 2 start |
| What is the actual coverage of `Renewal_Date__c` null values in Salesforce — can it be fixed before Phase 2? | Ben Tran | Before Phase 2 start |
| Confirm Zendesk CSAT export access with Carlos Vega | Ben Tran | By end of Week 2 |
| Scope feasibility of playbook recommendation logic in Looker Actions | Sophie Tanner | Phase 3 scoping review |
| Confirm Salesforce account hierarchy data quality for multi-site expansion signals | Kofi Asante | Phase 2 data audit |
