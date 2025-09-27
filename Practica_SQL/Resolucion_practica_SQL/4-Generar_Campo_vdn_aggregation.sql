CREATE OR REPLACE TABLE keepcoding.vdn_aggregation AS
WITH calls AS (
  SELECT
    ivr_id,
    UPPER(TRIM(CAST(vdn_label AS STRING))) AS vdn_label_norm
  FROM keepcoding.ivr_calls
)
SELECT
  ivr_id AS calls_ivr_id,
  CASE
    WHEN vdn_label_norm LIKE 'ATC%'           THEN 'FRONT'
    WHEN vdn_label_norm LIKE 'TECH%'          THEN 'TECH'
    WHEN vdn_label_norm LIKE 'ABSORPTION%'    THEN 'ABSORPTION'
    ELSE 'RESTO'
  END AS vdn_aggregation
FROM calls;
