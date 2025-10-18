with sale as (
    select product_sk,sold_at,sales_value
    from {{ref('fct_sales')}}
),
products as (
    select price_product_normlized,product_sk
    from {{ref('dim_products')}}
),
sales_vs_price as (
    select 
    date_trunc('month',s.sold_at)::date as month,
    s.sales_value - p.price_product_normlized as revenue
    from sale s 
    join products p on 
    s.product_sk = p.product_sk
)
select month,sum(revenue) as net_revenue from sales_vs_price
group by month
order by month asc