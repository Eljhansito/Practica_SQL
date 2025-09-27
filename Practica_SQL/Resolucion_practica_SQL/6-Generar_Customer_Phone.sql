CREATE OR REPLACE TABLE keepcoding.call_customer_phone AS
WITH phone_candidates AS (
  SELECT
    CAST(steps.ivr_id AS STRING) AS ivr_id,
    REGEXP_REPLACE(TRIM(CAST(steps.customer_phone AS STRING)), r'\s+', '') AS phone_clean, 
    CAST(steps.module_sequece AS INT64) AS module_sequece,   
    CAST(steps.step_sequence  AS INT64) AS step_sequence
  FROM keepcoding.ivr_steps AS steps
  WHERE steps.customer_phone IS NOT NULL
    AND TRIM(CAST(steps.customer_phone AS STRING)) <> ''
),
ranked_phones AS (
  SELECT
    ivr_id, 
    phone_clean AS customer_phone,
    ROW_NUMBER() OVER (
      PARTITION BY ivr_id
      ORDER BY module_sequece ASC, step_sequence ASC  
    ) AS row_num
  FROM phone_candidates
)
SELECT
  CAST(calls.ivr_id AS STRING) AS calls_ivr_id,
  ranked_phones.customer_phone AS customer_phone
FROM keepcoding.ivr_calls AS calls
LEFT JOIN ranked_phones
  ON ranked_phones.ivr_id = CAST(calls.ivr_id AS STRING)
 AND ranked_phones.row_num = 1;
