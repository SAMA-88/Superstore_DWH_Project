{{
    config(
        materialized='table'
    )
}}

SELECT
    o.row_id,
    o.order_id,
    o.order_date,
    o.ship_date,
    o.ship_mode,
    o.customer_id,
    o.country,
    o.city,
    o.state,
    o.postal_code,
    o.region,
    o.product_id,
    o.category,
    o.sub_category,
    o.product_name,
    p.sales,
    p.quantity,
    p.discount,
    p.profit
FROM {{ ref('stg_orders') }} o
LEFT JOIN {{ ref('stg_payments') }} p 
    ON o.row_id = p.row_id