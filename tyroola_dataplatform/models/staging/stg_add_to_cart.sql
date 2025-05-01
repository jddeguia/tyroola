{{
  config(
    materialized='table',
    partition_by={'field': 'event_date', 'data_type': 'date'},
    cluster_by=['utm_source']
  )
}}

WITH base AS (
    SELECT *
    FROM {{ ref('base_add_to_cart') }}
)

SELECT * FROM base