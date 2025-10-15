with customer_sales as (
    select * from {{ ref('int_customers_sales') }}
),
agg as (
    select
        name_customer,
        sum(sales_value) as amount_spent,
        count(*)         as sales_count
    from customer_sales
    group by name_customer
),
ranked as (
    select
        a.*,
        row_number() over (order by amount_spent desc) as rnk
    from agg a
)
select *
from ranked
where rnk <= 10
