{{ config (materialized='view') }}

WITH base AS (
    SELECT
        DATE(FORMAT_TIMESTAMP('%Y-%m-%d %H:%M:%S', TIMESTAMP_MICROS(event_timestamp))) AS event_date,
        items.item_name AS product_name,
        items.item_brand AS brand,
        traffic_source.source AS utm_source,
        SUM(ecommerce.purchase_revenue_in_usd) AS total_revenue,
        AVG(ecommerce.purchase_revenue_in_usd) AS avg_order_value
    FROM {{ source('public_dataset', 'events_*') }},
    UNNEST(items) AS items
    WHERE event_name = 'purchase'
    GROUP BY ALL
)

SELECT * 
FROM base
