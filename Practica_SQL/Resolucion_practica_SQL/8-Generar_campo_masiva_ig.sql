CREATE OR REPLACE TABLE keepcoding.call_masiva_flag AS
WITH calls AS (
  SELECT CAST(ivr_id AS STRING) AS ivr_id
  FROM keepcoding.ivr_calls
),
masiva_calls AS (
  SELECT DISTINCT CAST(ivr_id AS STRING) AS ivr_id
  FROM keepcoding.ivr_modules
  WHERE UPPER(TRIM(module_name)) = 'AVERIA_MASIVA'  
)
SELECT
  calls.ivr_id AS calls_ivr_id,
  CASE WHEN masiva_calls.ivr_id IS NOT NULL THEN 1 ELSE 0 END AS masiva_lg
FROM calls
LEFT JOIN masiva_calls
  ON masiva_calls.ivr_id = calls.ivr_id;
