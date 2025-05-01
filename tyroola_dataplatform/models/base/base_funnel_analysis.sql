{{ config (materialized='view') }}

WITH base AS (
    SELECT
        DATE(FORMAT_TIMESTAMP('%Y-%m-%d %H:%M:%S', TIMESTAMP_MICROS(event_timestamp))) AS event_date,
        FORMAT_TIMESTAMP('%Y-%m-%d %H:%M:%S', TIMESTAMP_MICROS(event_timestamp)) AS event_timestamp,
        user_pseudo_id,
        (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS ga_session_id,
        event_name,  
        device.category AS device_category,
        items.item_name AS product_name,
        items.item_brand AS brand,
        items.item_category AS item_category,
        ecommerce.total_item_quantity,
        ecommerce.purchase_revenue_in_usd,
        ecommerce.shipping_value_in_usd,
        ecommerce.refund_value_in_usd,
        (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'payment_type') AS payment_type,
        (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'source') AS utm_source,
        (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'medium') AS utm_medium,
        (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'campaign') AS utm_campaign,
    FROM {{ source('public_dataset', 'events_*') }},
    UNNEST(items) AS items
    WHERE event_name IN ('view_item', 'add_to_cart', 'begin_checkout', 'purchase')
),

session_id AS (
    SELECT *,
        CONCAT(user_pseudo_id, CAST(ga_session_id AS STRING)) AS session_id
    FROM base
)

SELECT * FROM session_id

