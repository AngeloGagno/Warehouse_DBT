with products as (
    select * from {{ref('int_products')}}
)
select 
    product_sk,
    name_product,
    department_product,
    price_product_normlized
    from products
