-- IVR SUMMARY (1 fila por llamada)
-- Reúne: datos base de la llamada + todos los indicadores calculados

CREATE OR REPLACE TABLE keepcoding.ivr_summary AS
WITH base_detail AS (
  -- ivr_detail tiene varias filas por llamada (por step). Resumimos a 1 usando ANY_VALUE().
  SELECT
    CAST(calls_ivr_id AS STRING)                            AS ivr_id,
    ANY_VALUE(calls_phone_number)                           AS phone_number,
    ANY_VALUE(calls_ivr_result)                             AS ivr_result,
    ANY_VALUE(calls_start_date)                             AS start_date,
    ANY_VALUE(calls_end_date)                               AS end_date,
    ANY_VALUE(calls_total_duration)                         AS total_duration,
    ANY_VALUE(calls_customer_segment)                       AS customer_segment,
    ANY_VALUE(calls_ivr_language)                           AS ivr_language,
    ANY_VALUE(calls_steps_module)                           AS steps_module,
    ANY_VALUE(calls_module_aggregation)                     AS module_aggregation
  FROM keepcoding.ivr_detail
  GROUP BY calls_ivr_id
)

SELECT
  base_detail.ivr_id,
  base_detail.phone_number,
  base_detail.ivr_result,
  vdn_agg.vdn_aggregation,                          -- (punto 4)

  base_detail.start_date,
  base_detail.end_date,
  base_detail.total_duration,
  base_detail.customer_segment,
  base_detail.ivr_language,
  base_detail.steps_module,
  base_detail.module_aggregation,

  ident.document_type,                              -- (punto 5)
  ident.document_identification,                    -- (punto 5)
  cust_phone.customer_phone,                        -- (punto 6)
  bill.billing_account_id,                          -- (punto 7)

  masiva.masiva_lg,                                 -- (punto 8)
  info_phone.info_by_phone_lg,                      -- (punto 9)
  info_dni.info_by_dni_lg,                          -- (punto 10)
  repeats.repeated_phone_24H,                       -- (punto 11)
  repeats.cause_recall_phone_24H                    -- (punto 11)

FROM base_detail
LEFT JOIN keepcoding.vdn_aggregation              AS vdn_agg
  ON vdn_agg.calls_ivr_id = base_detail.ivr_id

LEFT JOIN keepcoding.call_identification          AS ident
  ON ident.calls_ivr_id = base_detail.ivr_id

LEFT JOIN keepcoding.call_customer_phone          AS cust_phone
  ON cust_phone.calls_ivr_id = base_detail.ivr_id

LEFT JOIN keepcoding.call_billing_account         AS bill
  ON bill.calls_ivr_id = base_detail.ivr_id

LEFT JOIN keepcoding.call_masiva_flag             AS masiva
  ON masiva.calls_ivr_id = base_detail.ivr_id

LEFT JOIN keepcoding.call_info_by_phone_flag      AS info_phone
  ON info_phone.calls_ivr_id = base_detail.ivr_id

LEFT JOIN keepcoding.call_info_by_dni_flag        AS info_dni
  ON info_dni.calls_ivr_id = base_detail.ivr_id

LEFT JOIN keepcoding.call_phone_repeats_24h       AS repeats
  ON repeats.calls_ivr_id = base_detail.ivr_id;
