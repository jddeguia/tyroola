{{ config (materialized='view') }}

WITH base AS (
    SELECT
        DATE(FORMAT_TIMESTAMP('%Y-%m-%d %H:%M:%S', TIMESTAMP_MICROS(event_timestamp))) AS event_date,
        items.item_name AS product_name,
        items.item_brand AS brand,
        traffic_source.source AS utm_source,
        COUNT(DISTINCT user_pseudo_id) AS users_started_checkout
    FROM {{ source('public_dataset', 'events_*') }},
    UNNEST(items) AS items
    WHERE event_name = 'begin_checkout'
    GROUP BY ALL
)

SELECT * 
FROM base
