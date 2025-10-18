-- models/marts/dim/dim_customer.sql
with base as (
  select
    id_customer,
    regexp_replace(name_customer, '^(?:Sr\.|Srta\.|Dr\.|Dra\.)\s*', '', 'i') as name_customer_clean,
    split_part(email_customer, '@', 1)||'@***' as email_masked,
    regexp_replace(phonenum_customer, '\d(?=\d{4})', '*', 'g') as phone_masked
  from {{ ref('stg_customers') }}
)
select
  {{ dbt_utils.generate_surrogate_key(['id_customer']) }} as customer_sk,
  id_customer as customer_nk,
  name_customer_clean,
  email_masked,
  phone_masked
from base