with sales as (
  select
    product_sk,
    sold_at,
    sales_value
  from {{ ref('fct_sales') }}
),

products as (
  select
    product_sk,
    price_product_normlized as cost_value
  from {{ ref('dim_products') }}
),

joined as (
  select
    s.product_sk,
    date_trunc('month', s.sold_at)::date as month,
    s.sales_value,
    p.cost_value
  from sales s
  join products p using (product_sk)
),

aggregated as (
  select
    product_sk,
    month,
    sum(sales_value)                       as total_revenue,
    sum(cost_value)                        as total_cost,
    sum(sales_value - cost_value)          as gross_profit,
    (sum(sales_value - cost_value)::numeric / nullif(sum(sales_value), 0)) * 100 as margin_pct
  from joined
  group by 1,2
)

select
  d.name_product,
  a.product_sk,
  a.month,
  a.total_revenue,
  a.total_cost,
  a.gross_profit,
  round(a.margin_pct, 2) as margin_pct
from aggregated a
join {{ ref('dim_products') }} d using (product_sk)
order by a.month, d.name_product
