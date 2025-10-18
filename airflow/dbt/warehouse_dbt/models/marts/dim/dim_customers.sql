with customers as (
  select * from {{ref('int_customers')}}
)
select customer_sk,   
  name_customer_clean,
  email_masked,
  phone_masked
  from customers