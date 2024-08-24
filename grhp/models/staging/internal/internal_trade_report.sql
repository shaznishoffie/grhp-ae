{{
  config(
    materialized = "incremental",
    incremental_strategy = "insert_overwrite",
    partitions = [exec_date()],
    require_partition_filter = true,
    partition_by = {
      "field": "report_date",
      "data_type": "date",
      "granularity": "day"
    },
    pre_hook = "alter table if exists {{ this }} set options (require_partition_filter = false)",
    post_hook = "alter table if exists {{ this }} set options (require_partition_filter = true)"
  )
}}

SELECT
  product_code,
  IF(quantity > 0, quantity, NULL) AS buy_quantity,
  IF(quantity < 0, ABS(quantity), NULL) AS sell_quantity,
  price,
  report_date
FROM {{ source('grhp_raw', 'ghp_ae_test_internal_trade_report') }}
WHERE report_date = {{ exec_date() }}
