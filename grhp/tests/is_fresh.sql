{% test is_fresh(model, date_column, interval_in_days, partition_column) %}
-- this checks if the max date column is T-1
-- test succeeds if 0 rows are returned from the query

SELECT
  MAX(SAFE_CAST({{ date_column }}) AS DATE) AS max_date
FROM {{ model }}

{% if partition_column %}
-- for tables that require partition filters
WHERE {{ partition_column }} >= DATE_SUB(CURRENT_DATE, INTERVAL 2 DAY)
{% endif %}

HAVING max_date < DATE_SUB(CURRENT_DATE, INTERVAL {{ interval_in_days }} DAY)
{% endtest %}
