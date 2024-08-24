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

WITH ext_source AS (
  SELECT
    product_code,
    transaction_type,
    price,
    quantity,
    report_date,
    COUNT(*) AS trxn_count
  FROM {{ ref('external_trade_report_buy') }}
  WHERE report_date = {{ exec_date() }}
  GROUP BY
    product_code,
    transaction_type,
    price,
    quantity,
    report_date
),

internal AS (
  SELECT
    product_code,
    transaction_type,
    price,
    quantity,
    report_date,
    COUNT(*) AS trxn_count
  FROM {{ ref('internal_trade_report_buy') }}
  WHERE report_date = {{ exec_date() }}
  GROUP BY
    product_code,
    transaction_type,
    price,
    quantity,
    report_date
)

SELECT
  COALESCE(ext_source.product_code, internal.product_code) AS product_code,
  COALESCE(ext_source.price, internal.price) AS price,
  COALESCE(ext_source.report_date, internal.report_date) AS report_date,
  COALESCE(ext_source.transaction_type, internal.transaction_type) AS transaction_type,
  ext_source.quantity AS external_quantity,
  internal.quantity AS internal_quantity,
  ext_source.trxn_count AS external_trxn_count,
  internal.trxn_count AS internal_trxn_count,
  ext_source.trxn_count - internal.trxn_count AS trxn_count_diff,
  ext_source.trxn_count - internal.trxn_count != 0 AS is_trxn_count_diff
FROM ext_source
FULL OUTER JOIN internal
             ON ext_source.product_code = internal.product_code
            AND ext_source.price = internal.price
            AND ext_source.quantity = internal.quantity
            AND ext_source.report_date = internal.report_date
