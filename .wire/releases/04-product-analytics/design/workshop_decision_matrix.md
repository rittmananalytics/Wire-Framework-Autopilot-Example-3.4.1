# Workshop Decision Matrix — Product Analytics
## Release: 04-product-analytics

| ID | Topic | Options | Decision | Rationale | Owner |
|----|-------|---------|---------|-----------|-------|
| A1 | Unmapped Mixpanel events | (a) Drop unmapped, (b) Group as 'Other' | ✓ Group as `module='Other', feature_group='Unmapped'` | Preserves volume; surfaced in DQ monitoring | Leon Yip |
| A2 | PB-01 heatmap default level | (a) Fixed Feature Group, (b) User-selectable | ✓ Default Feature Group; user can drill to Feature | Consistent with requirements; Feature level too granular as default | Claire Ashworth |
| B1 | Authoritative source for transactional events | (a) Segment, (b) Mixpanel, (c) Coalesce | ✓ Segment for work_order, asset, report events | Server-side more reliable; confirmed in supplementary requirements | Leon Yip |
| B2 | Mixpanel-only events | (a) Include all, (b) Include only mapped events | ✓ Include all Mixpanel events not covered by Segment | Discovery events have no Segment equivalent | Leon Yip |
| C1 | Score weights | Per supplementary requirements 20/20/20/10/5/15/10 | ✓ Confirmed | Agreed by Claire Ashworth in discovery session | Claire Ashworth |
| C2 | Tara Obinna sign-off on weights | Required before build | ⚠ Pending — default to supplementary requirements weights | Block `dim_account_product_score` build until confirmed | Tara Obinna |
| C3 | At-risk score threshold | (a) <40, (b) <50, (c) Configurable via seed | ✓ Default <40; configurable via `product_health_thresholds` seed | Allows CS team to adjust without developer intervention | Claire Ashworth |
| D1 | IoT step (Step 6) scope | (a) In scope, (b) Optional, (c) Out of scope | ✓ Included as optional; not counted in "core onboarding complete" | Core onboarding = Steps 1–5; Steps 6–7 extended | Leon Yip |
| D2 | Stalled definition | (a) >7 days, (b) >14 days, (c) Configurable | ✓ >14 days; configurable via seed table | 14 days balances urgency vs. noise | Claire Ashworth |
| D3 | CSM field in Salesforce | (a) Owner.Name, (b) CSM__c custom field | ✓ Use `Account.CSM__c` custom lookup field | Tara Obinna confirmed this is the correct field | Tara Obinna |
| E1 | User_Seats__c null handling | (a) Show NULL, (b) Default to 0, (c) Hide tile | ✓ Show NULL with tooltip: "Contracted seats not on file" | Hiding data risks misleading; NULL is honest | Amara Diallo |
| E2 | Feature taxonomy seed update cadence | (a) Manual, (b) Quarterly, (c) CI hook | ✓ Manual with documented process in operations guide | Low frequency expected; manual process acceptable | Leon Yip |
