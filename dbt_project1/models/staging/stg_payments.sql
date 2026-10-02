{{ config(materialized='view') }}

with source as (

    select *
    from {{ source('ods', 'raw_payments') }}

)

select
    id as payment_id,
    order_id,
    payment_method,
    cast(amount as decimal(10, 2)) / 100.0 as amount_usd
from source