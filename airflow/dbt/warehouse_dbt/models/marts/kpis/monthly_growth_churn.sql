{{ config(materialized='view') }}

with bounds as (
  select
    date_trunc('month', min(sold_at))::date as min_month,
    date_trunc('month', max(sold_at))::date as max_month
  from {{ ref('fct_sales') }}
),

months as (
  select (gs)::date as month
  from bounds b,
       generate_series(b.min_month, b.max_month, interval '1 month') as gs
),

base as (
  select
    date_trunc('month', sold_at)::date as month,
    customer_sk,
    sales_value
  from {{ ref('fct_sales') }}
),

mth as (
  select
    m.month,
    coalesce(sum(b.sales_value), 0)                       as revenue,
    count(distinct b.customer_sk)                         as active_customers
  from months m
  left join base b on b.month = m.month
  group by 1
),

cust_month as (
  select distinct
    date_trunc('month', sold_at)::date as month,
    customer_sk
  from {{ ref('fct_sales') }}
),

retention_anchor_prev as (
  select
    cm_prev.month                                          as prev_month,
    (cm_prev.month + interval '1 month')::date             as month,
    count(distinct cm_prev.customer_sk)                    as active_prev,
    count(distinct cm_next.customer_sk)                    as retained_next
  from cust_month cm_prev
  left join cust_month cm_next
    on cm_next.customer_sk = cm_prev.customer_sk
   and cm_next.month = (cm_prev.month + interval '1 month')::date
  group by 1,2
),

churn as (
  select
    month,
    active_prev,
    (active_prev - retained_next)                                            as churned,
    ((active_prev - retained_next)::numeric / nullif(active_prev, 0))        as churn_rate
  from retention_anchor_prev
),

growth as (
  select
    month,
    revenue,
    active_customers,
    lag(revenue) over (order by month)                                       as revenue_prev,
    ((revenue - lag(revenue) over (order by month))::numeric
      / nullif(lag(revenue) over (order by month), 0))                       as revenue_growth_rate
  from mth
)

select
  g.month,
  g.revenue,
  g.revenue_prev,
  g.revenue_growth_rate,   -- 0.1250 = 12.50%
  g.active_customers,
  c.active_prev,
  c.churned,
  c.churn_rate             -- 0.3200 = 32.00%
from growth g
left join churn c using (month)
order by g.month
