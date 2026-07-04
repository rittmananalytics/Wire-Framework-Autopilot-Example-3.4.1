# Workshop Decision Matrix — Customer Analytics
## Release: 05-customer-analytics

**Note**: Workshop materials generated as reference — no workshop conducted in Autopilot mode. Decisions below reflect the authoritative choices made during requirements and design phases.

---

## Decisions Made

| Decision | Choice | Rationale | Owner |
|----------|--------|-----------|-------|
| NRR expansion classification | Seat upgrades = expansion ARR; cross-sells = new ARR (separate opportunity) | Consistent with SaaS benchmarking industry standard | David Park |
| Churn recognition date | Contract end date | Simpler, auditable, matches Finance period-end close | David Park + Amara Diallo |
| Multi-year contract ARR | Annualise total contract value / contract length in months × 12 | Standard practice; already in Salesforce ACV field | Amara Diallo |
| Health score weights | Product 30%, Support 20%, Financial 25%, Relationship 15%, NPS 10% | Product engagement most predictive; financial health important given 8% discrepancy | Tara Obinna + Claire Ashworth |
| Support health metric | Composite: CSAT (50%) + avg_resolution_hours normalised (30%) + ticket_volume normalised (20%) | CSAT alone misses response time; volume important for enterprise accounts | Tara Obinna |
| ChurnZero relationship | Supplement — ChurnZero signals feed in as one input; BigQuery becomes system of record | Avoid disrupting CS team workflow; ChurnZero UI stays; BigQuery adds historical depth | Tara Obinna |
| BQML churn definition | Full churn only (not contraction) | Cleaner binary label; contraction is a separate use case | Tara Obinna |
| Financial metric access | finance_viewers + leadership Looker groups only | ARR/NRR sensitive; restricted by David Park | David Park |
| CSM owner field | Salesforce `Owner.Name` mapped via `stg_salesforce__accounts.csm_owner` | Standard field; already staged in Release 02 | Amara Diallo |
| Risk band thresholds | Low <0.20, Medium 0.20–0.40, High 0.40–0.65, Critical ≥0.65 | Calibrated to ~10% critical, 20% high in expected distribution | Tara Obinna + Marcus Webb |
