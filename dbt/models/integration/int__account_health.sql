{{
    config(
        materialized='view',
        tags=['integration', 'intermediate_customer']
    )
}}

/*
int__account_health
--------------------
Assembles 5 health signal components per account per day:
  1. Product engagement (from Release 04 dim_account_product_score)
  2. Support health (Zendesk CSAT, resolution time, ticket volume)
  3. Financial health (ARR trend, renewal proximity)
  4. Relationship health (QBR recency, exec sponsor, open escalations)
  5. NPS (most recent survey response within 180 days)

Each signal is normalised to 0.0–1.0 before weight application.
The ChurnZero score is included as a supplementary signal reference only.

Grain: account_pk × score_date (one row per account per calendar day)
*/

with s_accounts as (
    select * from {{ ref('stg_salesforce__accounts') }}
),

s_product_scores as (
    select * from {{ source('mart_product', 'dim_account_product_score') }}
),

s_zendesk_tickets as (
    select * from {{ ref('stg_zendesk__tickets') }}
),

s_nps_surveys as (
    select * from {{ ref('stg_intercom__nps_surveys') }}
),

s_churnzero as (
    select * from {{ ref('stg_churnzero__account_health') }}
),

s_salesforce_opps as (
    select * from {{ ref('stg_salesforce__opportunities') }}
    where type = 'Renewal'
),

-- Spine: one row per account per day (last 90 days for int layer)
date_spine as (
    select
        date_add(date_sub(current_date(), interval 89 day), interval n day) as score_date
    from unnest(generate_array(0, 89)) as n
),

account_date_spine as (
    select
        a.account_pk,
        d.score_date
    from s_accounts as a
    cross join date_spine as d
),

-- Signal 1: Product engagement — use monthly score, forward-filled daily
product_signal as (
    select
        account_pk,
        score_month,
        product_engagement_score
    from s_product_scores
),

-- Signal 2: Support health — trailing 30-day rolling window per day
support_signal as (
    select
        account_pk,
        cast(ticket_created_date as date) as ticket_date,
        avg(csat_score)                                             as avg_csat,
        avg(resolution_hours)                                       as avg_resolution_hrs,
        count(distinct ticket_pk)                                   as ticket_count_30d
    from s_zendesk_tickets
    group by 1, 2
),

-- Signal 3: NPS — most recent survey within 180 days
nps_signal as (
    select
        account_pk,
        survey_date,
        nps_score,
        row_number() over (
            partition by account_pk
            order by survey_date desc
        ) as rn
    from s_nps_surveys
    where survey_date >= date_sub(current_date(), interval 180 day)
),

latest_nps as (
    select
        account_pk,
        survey_date,
        nps_score
    from nps_signal
    where rn = 1
),

-- Signal 4: Renewal proximity — days to next renewal
renewal_signal as (
    select
        account_pk,
        min(close_date) as next_renewal_date,
        date_diff(min(close_date), current_date(), day) as days_to_renewal
    from s_salesforce_opps
    where close_date >= current_date()
    group by 1
),

-- Signal 5: Relationship — QBR completion date from Salesforce (custom field)
relationship_signal as (
    select
        a.account_pk,
        a.last_qbr_date,
        a.exec_sponsor_identified  as has_exec_sponsor,
        date_diff(current_date(), a.last_qbr_date, day) as days_since_qbr
    from s_accounts as a
),

-- ChurnZero supplementary signal
churnzero_signal as (
    select
        account_pk,
        health_date,
        churn_score as churnzero_churn_score
    from s_churnzero
),

-- Assemble all signals
assembled as (
    select
        ads.account_pk,
        ads.score_date,

        -- Product signal (most recent monthly score ≤ score_date)
        (
            select ps.product_engagement_score
            from product_signal as ps
            where ps.account_pk = ads.account_pk
              and ps.score_month <= date_trunc(ads.score_date, month)
            order by ps.score_month desc
            limit 1
        )                                                            as product_signal_raw,

        -- Support signal — trailing 30-day averages
        (
            select avg(ss.avg_csat)
            from support_signal as ss
            where ss.account_pk = ads.account_pk
              and ss.ticket_date between date_sub(ads.score_date, interval 30 day)
                                    and ads.score_date
        )                                                            as support_csat_avg,

        (
            select avg(ss.avg_resolution_hrs)
            from support_signal as ss
            where ss.account_pk = ads.account_pk
              and ss.ticket_date between date_sub(ads.score_date, interval 30 day)
                                    and ads.score_date
        )                                                            as support_resolution_hrs_avg,

        (
            select sum(ss.ticket_count_30d)
            from support_signal as ss
            where ss.account_pk = ads.account_pk
              and ss.ticket_date between date_sub(ads.score_date, interval 30 day)
                                    and ads.score_date
        )                                                            as support_ticket_count,

        -- Financial signal
        a.arr_usd                                                    as financial_arr_usd,
        rs.days_to_renewal                                           as financial_renewal_days,

        -- Relationship signal
        rel.days_since_qbr                                           as relationship_qbr_days_since,
        rel.has_exec_sponsor                                         as relationship_exec_sponsor,

        -- NPS signal
        nps.nps_score                                                as nps_score_latest,
        date_diff(ads.score_date, nps.survey_date, day)              as nps_days_since,

        -- ChurnZero supplementary
        (
            select cz.churnzero_churn_score
            from churnzero_signal as cz
            where cz.account_pk = ads.account_pk
              and cz.health_date <= ads.score_date
            order by cz.health_date desc
            limit 1
        )                                                            as churnzero_churn_score

    from account_date_spine as ads
    inner join s_accounts as a
        on ads.account_pk = a.account_pk
    left join renewal_signal as rs
        on ads.account_pk = rs.account_pk
    left join relationship_signal as rel
        on ads.account_pk = rel.account_pk
    left join latest_nps as nps
        on ads.account_pk = nps.account_pk
),

final as (
    select * from assembled
)

select * from final
