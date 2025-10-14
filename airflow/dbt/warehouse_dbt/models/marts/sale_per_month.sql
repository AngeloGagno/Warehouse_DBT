with source_sales as (
    select * from {{ ref('stg_sales') }}
),
source_product as (
    select * from {{ ref('stg_products') }}
),
sales_ordered_month as (
    select
        date_trunc('month', ss.sold_at) as month,
        count(*)                        as sales_count,
        sum(ss.sales_value)             as sales_amount
    from source_sales ss
    join source_product sp on sp.id_product = ss.id_product
    group by 1
),
product_month as (
    select
        date_trunc('month', ss.sold_at) as month,
        sp.name_product,
        count(*) as product_count
    from source_sales ss
    join source_product sp on sp.id_product = ss.id_product
    group by 1, 2
),
top_product as (
    select month, name_product as top_product, product_count as top_product_qty
    from (
        select
            month,
            name_product,
            product_count,
            row_number() over (partition by month order by product_count desc) as rn
        from product_month
    ) t
    where rn = 1
),
get_sales_last_month as (
    select 
        som.month,
        tp.top_product,
        tp.top_product_qty,
        lag(som.sales_amount) over (order by som.month) as prev_month_sales,
        lag(som.sales_count)  over (order by som.month) as prev_month_count,
        som.sales_amount,
        som.sales_count
    from sales_ordered_month som
    left join top_product tp on tp.month = som.month
),
get_percent_grow_decrease as (
    select 
        month, 
        sales_amount, 
        case 
            when prev_month_sales is null or prev_month_sales = 0 then null
            else round((sales_amount::numeric / prev_month_sales::numeric), 2)
        end as revenue_vs_LM,
        sales_count,
        case 
            when prev_month_count is null or prev_month_count = 0 then null
            else round((sales_count::numeric / prev_month_count::numeric), 2)
        end as sales_vs_LM,
        top_product,
        top_product_qty
    from get_sales_last_month
)
select *
from get_percent_grow_decrease
order by month
