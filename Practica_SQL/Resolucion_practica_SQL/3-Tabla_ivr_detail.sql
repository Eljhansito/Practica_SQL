
CREATE OR REPLACE TABLE keepcoding.ivr_detail AS
WITH mod_agg AS (
  SELECT
    ivr_id,
    COUNT(DISTINCT module_sequece) AS calls_steps_module,
    STRING_AGG(module_name, ' > ' ORDER BY module_sequece) AS calls_module_aggregation
  FROM (
    SELECT DISTINCT 
        ivr_id, 
        module_sequece, 
        module_name
    FROM keepcoding.ivr_modules
  )
  GROUP BY ivr_id
)

SELECT
-- Campos de CALL 

  calls.ivr_id                                            AS calls_ivr_id,
  calls.phone_number                                      AS calls_phone_number,
  calls.ivr_result                                        AS calls_ivr_result,
  calls.vdn_label                                         AS calls_vdn_label,
  calls.start_date                                        AS calls_start_date,
  CAST(FORMAT_DATE('%Y%m%d', DATE(calls.start_date)) AS INT64) AS calls_start_date_id,  
  calls.end_date                                          AS calls_end_date,
  CAST(FORMAT_DATE('%Y%m%d', DATE(calls.end_date))   AS INT64) AS calls_end_date_id,    
  calls.total_duration                                    AS calls_total_duration,
  calls.customer_segment                                  AS calls_customer_segment,
  calls.ivr_language                                      AS calls_ivr_language,

  -- agregados de módulos por llamada

  module_aggregated.calls_steps_module                                 AS calls_steps_module,
  module_aggregated.calls_module_aggregation                           AS calls_module_aggregation,

  -- Campos de MODULE 

  modules.module_sequece                                    AS module_sequece,   
  modules.module_name                                        AS module_name,
  modules.module_duration                                    AS module_duration,
  modules.module_result                                      AS module_result,

  -- Campos de STEP
  steps.step_sequence                                      AS step_sequence,
  steps.step_name                                          AS step_name,
  steps.step_result                                        AS step_result,
  steps.step_description_error                             AS step_description_error,


  -- Datos capturados en pasos (identificación / contacto / billing)

  steps.document_type                                      AS document_type,
  steps.document_identification                            AS document_identification,
  steps.customer_phone                                     AS customer_phone,
  steps.billing_account_id                                 AS billing_account_id

FROM keepcoding.ivr_calls   AS calls
LEFT JOIN keepcoding.ivr_modules AS modules
  ON modules.ivr_id = calls.ivr_id
LEFT JOIN keepcoding.ivr_steps   AS steps
  ON steps.ivr_id = calls.ivr_id
 AND steps.module_sequece = modules.module_sequece 
LEFT JOIN mod_agg AS module_aggregated
  ON module_aggregated.ivr_id = calls.ivr_id
;
