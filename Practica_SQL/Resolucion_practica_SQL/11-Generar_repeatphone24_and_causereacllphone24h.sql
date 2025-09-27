CREATE OR REPLACE TABLE keepcoding.call_phone_repeats_24h AS
WITH base_calls AS (
  SELECT
    CAST(ivr_id AS STRING)        AS ivr_id,
    CAST(phone_number AS STRING)  AS phone_number,
    TIMESTAMP(start_date)         AS start_ts
  FROM keepcoding.ivr_calls
),

-- ¿Tiene otra llamada del mismo teléfono en las 24h anteriores?
calls_with_prev_24h AS (
  SELECT DISTINCT current_call.ivr_id
  FROM base_calls AS current_call
  INNER JOIN base_calls AS other_call
    ON current_call.phone_number = other_call.phone_number
   AND other_call.start_ts <  current_call.start_ts
   AND other_call.start_ts >= current_call.start_ts - INTERVAL 24 HOUR
),

-- ¿Tiene otra llamada del mismo teléfono en las 24h posteriores?
calls_with_next_24h AS (
  SELECT DISTINCT current_call.ivr_id
  FROM base_calls AS current_call
  INNER JOIN base_calls AS other_call
    ON current_call.phone_number = other_call.phone_number
   AND other_call.start_ts >  current_call.start_ts
   AND other_call.start_ts <= current_call.start_ts + INTERVAL 24 HOUR
)

SELECT
  base_calls.ivr_id                                                   AS calls_ivr_id,
  CASE WHEN calls_with_prev_24h.ivr_id IS NOT NULL THEN 1 ELSE 0 END  AS repeated_phone_24H,
  CASE WHEN calls_with_next_24h.ivr_id IS NOT NULL THEN 1 ELSE 0 END  AS cause_recall_phone_24H
FROM base_calls
LEFT JOIN calls_with_prev_24h
  ON calls_with_prev_24h.ivr_id = base_calls.ivr_id
LEFT JOIN calls_with_next_24h
  ON calls_with_next_24h.ivr_id = base_calls.ivr_id;
