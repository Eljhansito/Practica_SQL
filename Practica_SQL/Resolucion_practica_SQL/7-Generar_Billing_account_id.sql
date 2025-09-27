CREATE OR REPLACE TABLE keepcoding.call_billing_account AS
WITH billing_candidates AS (
  SELECT
    CAST(steps.ivr_id AS STRING) AS ivr_id,
    REGEXP_REPLACE(TRIM(CAST(steps.billing_account_id AS STRING)), r'\s+', '') AS billing_account_id_clean,
    CAST(steps.module_sequece AS INT64) AS module_sequece,   
    CAST(steps.step_sequence  AS INT64) AS step_sequence
  FROM keepcoding.ivr_steps AS steps
  WHERE steps.billing_account_id IS NOT NULL
    AND TRIM(CAST(steps.billing_account_id AS STRING)) <> ''
),
ranked_billing AS (
  SELECT
    billing_candidates.ivr_id,
    billing_candidates.billing_account_id_clean AS billing_account_id,
    ROW_NUMBER() OVER (
      PARTITION BY billing_candidates.ivr_id
      ORDER BY billing_candidates.module_sequece, billing_candidates.step_sequence
    ) AS row_num
  FROM billing_candidates
)
SELECT
  CAST(calls.ivr_id AS STRING) AS calls_ivr_id,
  ranked_billing.billing_account_id AS billing_account_id
FROM keepcoding.ivr_calls AS calls
LEFT JOIN ranked_billing
  ON ranked_billing.ivr_id = CAST(calls.ivr_id AS STRING)
 AND ranked_billing.row_num = 1;
