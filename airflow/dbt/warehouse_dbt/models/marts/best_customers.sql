with source_customers as (
    select * from {{ref('int_dim_customers')}}
),
source_sales as (
    select * from {{ref('stg_sales')}}
),
group_customers as (
    select sum(sales_value) as amount_spent,
    count(*) as sales_count,
    name_customer from 
    source_sales ss join source_customers sc on ss.id_customer = sc.id_customer
    group by name_customer
),
rank_customers as (
    select row_number() over (order by amount_spent desc , name_customer desc) as ranked_customers,
    name_customer,
    amount_spent, 
    sales_count
    from group_customers

),
top_10_customers as (
    select * from rank_customers where ranked_customers <= 10
)
select * from top_10_customers
