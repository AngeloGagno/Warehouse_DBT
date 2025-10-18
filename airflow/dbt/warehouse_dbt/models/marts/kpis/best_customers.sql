with f as (
  select customer_sk, sales_value
  from {{ ref('fct_sales') }}
),
dim as (
  select customer_sk, name_customer_clean
  from {{ ref('dim_customers') }}
),
agg as (
  select
    d.name_customer_clean as name_customer,
    sum(f.sales_value) as amount_spent,
    count(*) as sales_count
  from f
  join dim d using (customer_sk)
  group by 1
),
ranked as (
  select *,
         row_number() over (order by amount_spent desc) as rnk
  from agg
)
select *
from ranked
where rnk <= 10
