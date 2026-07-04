# Project Kickoff Call Transcript

**Meeting:** Core Dynamics × Rittman Analytics — Project Kickoff
**Date:** Monday, 2 February 2026
**Time:** 14:00–15:30 UTC
**Platform:** Google Meet
**Recorded by:** Daniel Osei (Rittman Analytics PM)

**Attendees:**
- Mark Rittman (RA — Engagement Lead)
- Daniel Osei (RA — Project Manager)
- Sophie Tanner (RA — Senior Analytics Engineer)
- Kofi Asante (RA — Data Engineer)
- Priya Nair (Core Dynamics — CTO, Executive Sponsor)
- Amara Diallo (Core Dynamics — Data Engineering Lead)
- Rachel Summers (Core Dynamics — VP Marketing)
- Tara Obinna (Core Dynamics — VP Customer Success)
- Harriet Drummond (Core Dynamics — COO)

**Absent / Apologies:**
- Claire Ashworth (Core Dynamics — VP Product) — sent apologies, to be rescheduled separately
- Carlos Vega (Core Dynamics — Head of Support Engineering)

---

## [00:00–00:08] Introductions and agenda review

**Mark Rittman:** Good afternoon everyone, and welcome to the kickoff call for what I think is genuinely one of the more exciting engagements we've taken on this year. The scope here covers the full breadth of Core Dynamics' analytics needs — marketing, product, customer success, and operations — and we're building on a platform that I think will serve you for several years. Let me just run through what we're hoping to cover today.

First, brief introductions from our side for anyone who hasn't met the full Rittman Analytics team yet. Then I'd like to hand over to Priya for a brief framing of what success looks like from the executive perspective. After that we'll do a quick walkthrough of the phased plan, confirm our key contacts for each workstream, and then spend the last half-hour on immediate next steps — access provisioning, the data source audit, and scheduling the workstream-specific discovery sessions this week.

**Priya Nair:** Thanks Mark. Really glad we're underway. I'll keep my framing brief. The board has set us a clear target: NRR from 104% to 115% within 18 months. That's not going to happen through better gut-feel — we need to know which customers are at risk before they tell us, and we need to know what's working in marketing and product to double down on it. That's what this platform needs to deliver. I'm going to stay close to this one personally, which is unusual for me with a vendor engagement, but I think it signals how seriously we're taking it internally.

**Mark Rittman:** That's really helpful context, Priya, and honestly that's the kind of executive framing that makes these projects succeed. One thing I want to call out early — the metric consistency problem we identified in discovery. The 8% discrepancy in MRR reporting between Sales, Finance, and CS is actually quite common in companies at your growth stage, but it can undermine confidence in every dashboard we build if we don't address it head-on. Sophie, do you want to say a word on how we're approaching that?

**Sophie Tanner:** Sure. So the approach in the SoW is that we define every governed metric — MRR, NRR, CAC, churn rate — once in the Looker semantic layer, and every report references that definition. We don't allow analysts to write their own MRR calculation in a dashboard. It sounds simple but it requires a sign-off process: we'll produce a Metric Definitions document in Phase 2, we'll get each workstream sponsor to sign off on the definitions that affect them, and then those definitions are locked. The first time someone says "that number doesn't match my spreadsheet," we can point to the agreed definition and work out why the spreadsheet was different — rather than going around in circles.

**Rachel Summers:** That's exactly what we need. I had a situation last quarter where I presented CAC to the board and got challenged by Sandra's team because their number was different. It turned out they were including implementation services cost in customer acquisition cost and we weren't. Neither of us was wrong per se, but it was embarrassing. Getting that agreed upfront is critical.

---

## [00:08–00:22] Phase 1 plan walkthrough

**Daniel Osei:** I'll take us through the Phase 1 plan. Weeks one through four are about getting the foundations right — infrastructure, pipelines, and data quality — before we touch any analytics. This week the priorities are: access provisioning for the GCP projects, scheduling the four workstream discovery sessions, and the data source audit. Amara, I've shared a data source audit template in the shared Drive folder — if you can get that to the relevant system owners this week that would be fantastic.

**Amara Diallo:** Yes, I've already sent it to Greg's team for Salesforce, Niamh for HubSpot, and Leon for Mixpanel and Segment. The trickier one is the CoreFM PostgreSQL access. We have a read-only replica we use for reporting, but we've never exposed it outside the VPC before. I need to talk to Sean Murphy about the best approach — probably Cloud SQL Auth Proxy.

**Kofi Asante:** That works well for us. We've used Cloud SQL Auth Proxy for a couple of similar setups and it's clean from a security perspective. If it would help, I can get on a call with Sean directly this week to walk through the technical requirements on our side.

**Amara Diallo:** That would be great, yes. I'll introduce you over email today.

**Mark Rittman:** Good. One thing to flag on the CoreFM database — we flagged this in the SoW but I want to make it explicit here — the pseudonymisation of PII in the staging layer needs Priya's sign-off before we implement it. We'll document the approach in a short technical note and circulate it in week two. It's not complex but it's important that it's a deliberate, documented decision rather than something we just do quietly.

**Priya Nair:** Agreed. Loop in our legal counsel on that one — I'll introduce you to Diane Hooper, she handles data privacy for us.

---

## [00:22–00:45] Workstream discovery scheduling

**Daniel Osei:** For the four workstream discovery sessions, we'd like to get them done in the first two weeks. We've done a lot of the upfront discovery in the SoW process but there will be things we've missed, and we want to validate the data model designs with the people who actually use the data before we build anything. I'm thinking 90 minutes per session. Is it better to do these as separate sessions with each workstream lead, or would you prefer a combined session?

**Tara Obinna:** Separate, please. The CS session alone could fill 90 minutes easily. The churn model discussion in particular — I want to make sure we're using the right features and that the model output actually maps to how my team makes decisions. We've had vendors build "churn prediction" for us before and the outputs were technically impressive but operationally useless.

**Mark Rittman:** That's a really important point and I'm glad you've raised it now rather than in week fourteen. Can you say more about what "operationally useless" looked like in that previous experience?

**Tara Obinna:** The model would spit out a score from zero to one and say an account was "high risk." But it gave no explanation. My CSMs couldn't act on it because they didn't know what was driving the score. Was it low product usage? A recent support escalation? A contact leaving the company? Each of those requires a completely different action. So the score just sat there and no-one trusted it.

**Mark Rittman:** Right. So what we need to build is not just the score but the contributing signals, visible at the account level. That's actually in the SoW — the `dim_account_health` table surfaces the individual signals — but I want to make sure we design the dashboard around that explainability rather than leading with a single number.

**Sophie Tanner:** We can take a "reasons" approach in the Looker dashboard — so for any at-risk account, there's a panel that shows the top three signals driving the score. "Product engagement score dropped 18 points in 30 days. Last login was 21 days ago. One open P2 support ticket unresolved for 8 days." That's actionable.

**Tara Obinna:** Yes. That's what I want. If your team can deliver that, I'll be a very happy stakeholder.

**Rachel Summers:** Can I ask a question on the marketing side? The multi-touch attribution model — I want to understand how the different attribution models will actually work in practice. In the SoW you mention first-touch, last-touch, linear, time-decay, and U-shaped. Are those all going to be live simultaneously in the dashboard, or do we pick one?

**Sophie Tanner:** The MA-02 dashboard has an attribution model selector — so all five models are calculated in the warehouse and you can switch between them in the dashboard. The idea is that you don't have to commit to one model. You can use linear as your default operating view, but when you're debating with Greg whether SDR outreach is getting enough credit, you can switch to a first-touch view and see the argument from that perspective. It changes the conversation from "which model is right" to "here's what the data looks like under different assumptions."

**Rachel Summers:** I love that. Can we add U-shaped as the default? That's generally the most defensible for B2B — it gives weight to first touch and lead conversion, which are the two moments that matter most for our pipeline arguments with Sales.

**Sophie Tanner:** Absolutely, we can make that the default with the selector available to override.

---

## [00:45–01:10] Access provisioning and immediate actions

**Daniel Osei:** Let me capture the immediate actions before we wrap up. Amara — GCP `Owner` on the dev project and `Editor` on prod for the Rittman Analytics service account. Target by end of this week?

**Amara Diallo:** Should be fine. I'll need to raise it with Priya and our IT security team but it's expected so no surprises.

**Priya Nair:** Approved from my side. Amara, treat that as pre-approved, just follow the standard provisioning process.

**Daniel Osei:** Fivetran — Amara, are you the right person to provision the connector credentials, or do we need to go to individual system owners?

**Amara Diallo:** Mix of both. Salesforce — Greg's team will need to create a dedicated API user, I'll chase that. HubSpot — Niamh has already said she can do that this week. Google Ads, LinkedIn, Meta — Owen Brady controls those. I'll send him the Fivetran documentation today.

**Kofi Asante:** For Zendesk and PagerDuty, it would be worth checking whether they have API token generation restricted to admin users — some enterprise configurations require a security team approval.

**Amara Diallo:** I'll check. Carlos owns Zendesk and Sean owns PagerDuty. I'll copy them on the access request email.

**Mark Rittman:** One thing I want to flag — and this is based on hard experience — the NetSuite connector sometimes takes two to three weeks to get properly credentialled because it requires a dedicated integration role to be set up by the NetSuite admin. I'd start that process today, Sandra, even though we don't need it until Phase 2.

**Priya Nair:** Sandra isn't on this call but I'll flag it to her directly. Good point.

---

## [01:10–01:28] Risks and questions

**Harriet Drummond:** I've been fairly quiet but I want to raise something on the operations workstream. The GCP Billing export — Sean has this partially configured, as you noted in the SoW. But I want to understand what "partially configured" means. We've had situations where the billing export was running but wasn't capturing all the right labels for customer attribution. Is that going to be a problem?

**Kofi Asante:** It can be. The customer cost attribution model in the SoW depends on GCP resource labels being consistently applied — specifically a `customer_id` label on the projects and resources associated with each customer's CoreFM environment. If the labelling is inconsistent, we'll be able to show total GCP costs but not per-customer allocation. Sean and I should audit the current label coverage before we commit to the dashboard spec for DO-02.

**Harriet Drummond:** I'll ask Sean to prepare a summary of the current billing export configuration and label coverage before the operations discovery session. If there are gaps, I want to know now rather than in week fifteen.

**Mark Rittman:** That's exactly the right instinct, Harriet. We'll put a dependency flag on that in the project plan.

**Tara Obinna:** One more question. The CSM Book of Business dashboard — it has row-level security so each CSM only sees their own accounts. How does that work in practice when a CSM leaves and their accounts are reassigned? Is it manual?

**Sophie Tanner:** It's driven by a Looker user attribute that maps to the CSM assignment in Salesforce. So as long as the Salesforce CSM assignment field is updated when accounts are reassigned, the dashboard updates automatically on the next Fivetran sync. The key dependency is keeping Salesforce CSM assignments current — which I suspect you'd want to do for other reasons anyway.

**Tara Obinna:** Yes, we're generally good at that. Good to know it's not a manual Looker admin process every time.

---

## [01:28–01:30] Close and next steps

**Daniel Osei:** To summarise actions before we close:

| Owner | Action | Due |
|---|---|---|
| Amara Diallo | GCP access provisioning for RA service account | Fri 6 Feb |
| Amara Diallo | Introduce Kofi Asante to Sean Murphy re: Cloud SQL Auth Proxy | Wed 4 Feb |
| Amara Diallo | Chase Salesforce API user creation with Greg Fontaine's team | Wed 4 Feb |
| Priya Nair | Introduce Mark Rittman to Diane Hooper (legal, PII pseudonymisation) | Fri 6 Feb |
| Amara Diallo | Send Fivetran credential requests to Owen Brady, Carlos Vega, Sean Murphy | Wed 4 Feb |
| Sandra Kowalski (via Priya) | Begin NetSuite integration role setup | This week |
| Sean Murphy | Prepare GCP billing label coverage summary for operations discovery session | Before ops discovery session |
| Daniel Osei | Share workstream discovery session invites | Today |
| Mark Rittman | Circulate Claire Ashworth rescheduled discovery session proposal | Today |

**Mark Rittman:** Great. Thanks everyone — really energising start. Looking forward to the discovery sessions this week and next. Amara, speak soon.
