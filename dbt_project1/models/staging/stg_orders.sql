{{ config(materialized='view') }}

with source as (

    select *
    from {{ source('ods', 'raw_orders') }}

)

select
    id as order_id,
    user_id as customer_id,
    cast(order_date as date) as order_date,
    status as order_status
from source