{{
  config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    partition_by={'field': 'event_date', 'data_type': 'date'},
    cluster_by=['event_name']
  )
}}

{% set reprocess_window_days = 3 %}

WITH base AS (
    SELECT *
    FROM {{ ref('base_funnel_analysis') }}
    {% if is_incremental() %}
    WHERE event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL {{ reprocess_window_days }} DAY)
    {% endif %}
)

{% if is_incremental() %},
existing_records AS (
    SELECT *
    FROM {{ this }}
    WHERE event_date < DATE_SUB(CURRENT_DATE(), INTERVAL {{ reprocess_window_days }} DAY)
)
{% endif %}

SELECT * FROM base

{% if is_incremental() %}
UNION ALL
SELECT * FROM existing_records
{% endif %}
