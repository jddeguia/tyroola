{{ config (materialized='view') }}

WITH base AS (
    SELECT
        DATE(FORMAT_TIMESTAMP('%Y-%m-%d %H:%M:%S', TIMESTAMP_MICROS(event_timestamp))) AS event_date,
        event_name,
        items.item_name AS product_name,
        items.item_brand AS brand,
        (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'source') AS utm_source,
        (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'medium') AS utm_medium,
        (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'campaign') AS utm_campaign
    FROM {{ source('public_dataset', 'events_*') }},
    UNNEST(items) AS items
    WHERE event_name IN ('view_item', 'add_to_cart', 'begin_checkout', 'purchase')
)

SELECT * FROM base

