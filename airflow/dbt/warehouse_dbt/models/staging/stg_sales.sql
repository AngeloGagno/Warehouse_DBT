with source as (
    select * from {{source('postgres_warehouse_dbt','vendas')}}
),
rename_columns as (
    select
    id_venda as id_sale,
    id_produto as id_product,
    valor_vendido as sales_value,
    id_matriz as id_headquarters,
    id_cliente as id_customer,
    vendido_em as sold_at,
    current_timestamp as etl_inserted_at
    from source
)
select * from rename_columns