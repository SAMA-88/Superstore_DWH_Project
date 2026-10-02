{{ config(materialized='table') }}

with orders as (

    select *
    from {{ ref('stg_orders') }}

),

payments as (

    select *
    from {{ ref('dim_payments') }}

),

order_payments as (

    select
        order_id,
        sum(amount_usd) as total_amount_usd
    from payments
    group by order_id

)

select
    o.order_id,
    o.customer_id,
    o.order_date,
    o.order_status,
    coalesce(op.total_amount_usd, 0) as total_amount_usd
from orders o
left join order_payments op
    using (order_id)