-- models/marts/kpi/kpi_revenue_by_hq_month.sql
{{ config(materialized='table') }}

with fct as (
  select
    sold_at::date    as date_day,
    headquarters_sk,
    sales_value::numeric(18,2) as sales_value
  from {{ ref('fct_sales') }}
),

dim_hq as (
  select
    headquarters_sk,
    name_headquarters_formated
  from {{ ref('dim_headquarters') }}
),

agg as (
  select
    date_trunc('month', f.date_day)::date as month,
    h.name_headquarters_formated,
    sum(f.sales_value)                        as revenue,
    avg(f.sales_value)::numeric(18,2)         as avg_ticket,      -- ticket médio por matriz
    count(*)                                  as sales_count      -- contagem de vendas
  from fct f
  join dim_hq h using (headquarters_sk)
  group by 1,2
)

select *
from agg
order by month, name_headquarters_formated
