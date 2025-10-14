with source as (
    select * from {{source('postgres_warehouse_dbt','produtos')}}
),
rename_columns as (
    select 
    id_produto as id_product,
    nome as name_product,
    setor as department_product,
    preco_compra as price_product,
    current_timestamp as etl_inserted_at
    from source
)
select * from rename_columns