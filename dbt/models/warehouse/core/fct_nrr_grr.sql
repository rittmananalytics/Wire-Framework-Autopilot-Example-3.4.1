{{
    config(
        materialized='table',
        tags=['warehouse', 'warehouse_customer']
    )
}}

/*
fct_nrr_grr
-----------
Monthly NRR/GRR per account. Rolls up to company-level in Looker via aggregation.
Full rebuild covers 24 months of history.

NRR = (Beginning ARR + Expansion - Contraction - Churn) / Beginning ARR × 100
GRR = (Beginning ARR - Contraction - Churn) / Beginning ARR × 100

Source: Salesforce opportunity ARR movements classified by type.
Financial metrics — restricted to finance_viewers + leadership in Looker.

Grain: account_pk × month_start
*/

with s_accounts as (
    select * from {{ ref('stg_salesforce__accounts') }}
),

s_opportunities as (
    select * from {{ ref('stg_salesforce__opportunities') }}
),

-- Month spine: 24 months
month_spine as (
    select
        date_trunc(
            date_sub(current_date(), interval n month),
            month
        ) as month_start
    from unnest(generate_array(0, {{ var('nrr_lookback_months', 24) }} - 1)) as n
),

-- Account × month cross join
account_months as (
    select
        a.account_pk,
        a.account_name,
        a.csm_owner,
        a.segment,
        a.region,
        m.month_start
    from s_accounts as a
    cross join month_spine as m
    where a.is_active = true
       or a.churn_date >= m.month_start  -- include churned accounts in their churn month
),

-- ARR movement per account per month from Salesforce opportunities
arr_movements as (
    select
        account_pk,
        date_trunc(close_date, month)                               as movement_month,
        sum(case
            when type = 'New Business' then amount
            else 0
        end)                                                        as new_arr,
        sum(case
            when type = 'Renewal' and amount > 0 then 0           -- renewal without expansion
            when type = 'Upsell' or
                 (type = 'Renewal' and amount > lag_amount)
                 then greatest(0, amount - coalesce(lag_amount, 0))
            else 0
        end)                                                        as expansion_arr,
        sum(case
            when type in ('Downgrade', 'Contraction') then abs(amount)
            else 0
        end)                                                        as contraction_arr,
        sum(case
            when type in ('Churn', 'Non-Renewal') then amount
            when stage_name = 'Closed Lost' and type = 'Renewal' then coalesce(lag_amount, amount)
            else 0
        end)                                                        as churn_arr
    from (
        select
            *,
            lag(amount) over (
                partition by account_pk
                order by close_date
            ) as lag_amount
        from s_opportunities
        where stage_name in ('Closed Won', 'Closed Lost')
    )
    group by 1, 2
),

-- Beginning ARR: ARR at start of each month (from accounts table, approximated)
beginning_arr as (
    select
        am.account_pk,
        am.month_start,
        coalesce(a.arr_usd, 0)                                      as beginning_arr
    from account_months as am
    inner join s_accounts as a
        on am.account_pk = a.account_pk
),

assembled as (
    select
        to_hex(sha256(cast(ba.account_pk as bytes)
            || cast(ba.month_start as string)))                     as nrr_pk,
        ba.account_pk,
        ba.month_start,
        ba.beginning_arr,
        coalesce(mv.expansion_arr, 0)                               as expansion_arr,
        coalesce(mv.contraction_arr, 0)                             as contraction_arr,
        coalesce(mv.churn_arr, 0)                                   as churn_arr,
        ba.beginning_arr
            + coalesce(mv.expansion_arr, 0)
            - coalesce(mv.contraction_arr, 0)
            - coalesce(mv.churn_arr, 0)                             as ending_arr,
        -- NRR: (Beginning + Expansion - Contraction - Churn) / Beginning × 100
        safe_divide(
            ba.beginning_arr
                + coalesce(mv.expansion_arr, 0)
                - coalesce(mv.contraction_arr, 0)
                - coalesce(mv.churn_arr, 0),
            ba.beginning_arr
        ) * 100                                                     as nrr,
        -- GRR: (Beginning - Contraction - Churn) / Beginning × 100
        safe_divide(
            ba.beginning_arr
                - coalesce(mv.contraction_arr, 0)
                - coalesce(mv.churn_arr, 0),
            ba.beginning_arr
        ) * 100                                                     as grr,
        am.csm_owner,
        am.segment,
        am.region
    from beginning_arr as ba
    inner join account_months as am
        on ba.account_pk = am.account_pk
        and ba.month_start = am.month_start
    left join arr_movements as mv
        on ba.account_pk = mv.account_pk
        and ba.month_start = mv.movement_month
),

final as (
    select * from assembled
)

select * from final
