CREATE OR REPLACE TABLE keepcoding.call_info_by_dni_flag AS
WITH calls AS (
  SELECT DISTINCT CAST(ivr_id AS STRING) AS ivr_id
  FROM keepcoding.ivr_calls
),
dni_ok AS (
  SELECT DISTINCT CAST(ivr_id AS STRING) AS ivr_id
  FROM keepcoding.ivr_steps
  WHERE
    UPPER(REGEXP_REPLACE(CAST(step_name AS STRING), r'\s+', '')) = 'CUSTOMERINFOBYDNI.TX'
    AND UPPER(TRIM(CAST(step_result AS STRING))) = 'OK'
)
SELECT
  calls.ivr_id AS calls_ivr_id,
  CASE WHEN dni_ok.ivr_id IS NOT NULL THEN 1 ELSE 0 END AS info_by_dni_lg
FROM calls
LEFT JOIN dni_ok
  ON dni_ok.ivr_id = calls.ivr_id;
