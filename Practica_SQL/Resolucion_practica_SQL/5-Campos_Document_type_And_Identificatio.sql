CREATE OR REPLACE TABLE keepcoding.call_identification AS
WITH candidates AS (
  SELECT
    CAST(ivr_id AS STRING) AS ivr_id,                                
    UPPER(TRIM(CAST(document_type AS STRING))) AS document_type,
    REGEXP_REPLACE(TRIM(CAST(document_identification AS STRING)), r'\s+', '') AS document_identification,
    CAST(module_sequece AS INT64) AS module_sequece,                 
    CAST(step_sequence  AS INT64) AS step_sequence
  FROM keepcoding.ivr_steps
  WHERE document_identification IS NOT NULL
    AND TRIM(CAST(document_identification AS STRING)) <> ''
),
ranked AS (
  SELECT
    ivr_id,
    document_type,
    document_identification,
    ROW_NUMBER() OVER (
      PARTITION BY ivr_id
      ORDER BY module_sequece, step_sequence
    ) AS rn
  FROM candidates
)
SELECT
  ivr_id AS calls_ivr_id,
  document_type,
  document_identification
FROM ranked
WHERE rn = 1;