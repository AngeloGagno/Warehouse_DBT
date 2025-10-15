
with source_sales as (
  select * from {{ ref('stg_sales') }}
),
source_product as (
  select * from {{ ref('stg_products') }}
),
source_headquarters as (
  select * from {{ ref('stg_headquarters') }}
),
product_sales as (
  select
    s.sold_at,
    s.sales_value::numeric(12,2) as sales_value,
    p.name_product,
    p.department_product,
    p.price_product::numeric(12,2) as raw_price_product,
    name_headquarters
  from source_sales s
  join source_product p
    on s.id_product = p.id_product
  join source_headquarters h
    on s.id_headquarters = h.id_headquarters
)
select * from product_sales
