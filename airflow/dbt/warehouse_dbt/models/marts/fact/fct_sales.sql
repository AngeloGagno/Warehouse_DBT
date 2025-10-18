-- models/marts/fct/fct_sales.sql
with sales as (
  select
    id_sale,
    id_customer,
    id_headquarters,
    id_product,
    sold_at::timestamp as sold_at,
    sales_value::numeric as sales_value
  from {{ ref('stg_sales') }}
),
dim_customer as (
  select customer_sk, customer_nk
  from {{ ref('int_customers') }}
),
dim_headquarters as (
  select headquarters_sk,headquarters_nk 
  from {{ref('int_headquarters')}}
),
dim_product as (
  select product_sk,product_nk
  from {{ref('int_products')}}
)
select
  s.id_sale,
  d.customer_sk, -- Surrogate Key para evitar a chave de negocio
  headquarters_sk, -- Surrogate Key
  product_sk, -- Surrogate Key
  s.sold_at,
  s.sales_value
from sales s
join dim_customer d
  on d.customer_nk = s.id_customer
join dim_headquarters h
  on h.headquarters_nk = s.id_headquarters
join dim_product p
  on p.product_nk = s.id_product

