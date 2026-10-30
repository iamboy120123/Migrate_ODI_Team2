-- ============================================================
-- D1_diagnose.sql  (rp01_20261029 / SS_ESIM_L2D)  -- Oracle DEV, user DSSDEV
-- SELECT เดียว -> รันด้วย Ctrl+Enter -> export CSV (มี header) ไป input/run_results/rp01_20261029/
-- อ่านอย่างเดียว ไม่แก้ข้อมูล · รัน "ก่อน" S7a_seed_DEV.sql (และรันซ้ำได้หลัง cleanup เพื่อดูว่ากลับสภาพเดิม)
-- คอลัมน์ SEQ / ITEM / VALUE (read_run_results.py จำเป็น diagnose)
-- ITEM ที่มีคำว่า (must be ...) ต้องได้ตามนั้น ไม่งั้นห้าม seed -- ส่งผลให้ agent ดูก่อน
-- ยังไม่ได้ทดสอบกับ DBeaver ของผู้ใช้
-- ============================================================
SELECT 1 AS SEQ, 'NOW (DB SYSDATE)' AS ITEM, TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') AS VALUE FROM DUAL
UNION ALL
SELECT 2, 'SEED_TIME_WINDOW_OK (must be Y: HH24MI >= 0515)',
       CASE WHEN TO_CHAR(SYSDATE, 'HH24MI') >= '0515' THEN 'Y' ELSE 'N' END FROM DUAL
UNION ALL
SELECT 3, 'P1_IF_SEEDED_NOW (SYSDATE-310min)', TO_CHAR(TO_NUMBER(TO_CHAR(SYSDATE - INTERVAL '310' MINUTE, 'YYYYMMDDHH24MI'))) FROM DUAL
UNION ALL
SELECT 4, 'CKPT_MAX = M (COALESCE 0)', TO_CHAR(COALESCE(MAX(checkpoint_partition), 0))
FROM DSSDEV.TB_STAGING_SS_ESIM_CHECKPOINT
UNION ALL
SELECT 5, 'CKPT_MAX_LT_P1 (must be Y)',
       CASE WHEN COALESCE(MAX(checkpoint_partition), 0) < TO_NUMBER(TO_CHAR(SYSDATE - INTERVAL '310' MINUTE, 'YYYYMMDDHH24MI')) THEN 'Y' ELSE 'N' END
FROM DSSDEV.TB_STAGING_SS_ESIM_CHECKPOINT
UNION ALL
SELECT 6, 'CKPT_ROWS_TOTAL', TO_CHAR(COUNT(*)) FROM DSSDEV.TB_STAGING_SS_ESIM_CHECKPOINT
UNION ALL
SELECT 7, 'CKPT_ROWS_PARTITION_DATE_TODAY (070000 deletes these; cleanup cannot restore)', TO_CHAR(COUNT(*))
FROM DSSDEV.TB_STAGING_SS_ESIM_CHECKPOINT
WHERE partition_date = TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDD'))
UNION ALL
SELECT 8, 'CKPT_TEMP_MAX', NVL(TO_CHAR(MAX(checkpoint_partition)), 'NULL') FROM DSSDEV.TB_STAGING_SS_ESIM_CHECKPOINT_TEMP
UNION ALL
SELECT 9, 'CKPT_TEMP_ROWS', TO_CHAR(COUNT(*)) FROM DSSDEV.TB_STAGING_SS_ESIM_CHECKPOINT_TEMP
UNION ALL
SELECT 10, 'STATUS_ROWS (must be 0 or 1)', TO_CHAR(COUNT(*)) FROM DSSDEV.TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS
UNION ALL
SELECT 11, 'STATUS running|success|workflow_process_date',
       NVL(MAX(NVL(running, 'NULL') || '|' || NVL(success, 'NULL') || '|' || NVL(workflow_process_date, 'NULL')), 'NO ROW')
FROM DSSDEV.TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS
UNION ALL
SELECT 12, 'STATUS_GUARD_020000_PASSES (must be Y)',
       CASE WHEN UPPER(COALESCE(MAX(success), 'TRUE')) = 'TRUE' THEN 'Y' ELSE 'N' END
FROM DSSDEV.TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS
UNION ALL
SELECT 13, 'LANDING_NONMARKER_ROWS_AFTER_M (must be 0; otherwise real rows get processed too)', TO_CHAR(COUNT(*))
FROM DSSDEV.TB_LANDING_SS_ESIM l
WHERE l.partition_minute > (SELECT COALESCE(MAX(checkpoint_partition), 0) FROM DSSDEV.TB_STAGING_SS_ESIM_CHECKPOINT)
  AND l.partition_minute <= TO_NUMBER(TO_CHAR(SYSDATE + INTERVAL '70' MINUTE, 'YYYYMMDDHH24MI'))
  AND (l.input_source_name IS NULL OR l.input_source_name NOT LIKE '/sa\_test/%' ESCAPE '\')
UNION ALL
SELECT 14, 'LANDING_ROWS_AT_PARTITION_EQ_M (info)', TO_CHAR(COUNT(*))
FROM DSSDEV.TB_LANDING_SS_ESIM l
WHERE l.partition_minute = (SELECT COALESCE(MAX(checkpoint_partition), 0) FROM DSSDEV.TB_STAGING_SS_ESIM_CHECKPOINT)
UNION ALL
SELECT 15, 'LANDING_MARKER_ROWS /sa_test/rp01/ (must be 0 before seed)', TO_CHAR(COUNT(*))
FROM DSSDEV.TB_LANDING_SS_ESIM WHERE input_source_name LIKE '/sa\_test/rp01/%' ESCAPE '\'
UNION ALL
SELECT 16, 'TARGET_MARKER_ROWS valid+temp+reject+raw_temp (must be 0 before seed)', TO_CHAR(
       (SELECT COUNT(*) FROM DSSDEV.TB_TRANSACTION_SS_ESIM_VALID  WHERE cdr_filename LIKE '/sa\_test/rp01/%' ESCAPE '\')
     + (SELECT COUNT(*) FROM DSSDEV.TB_TRANSACTION_SS_ESIM_TEMP   WHERE cdr_filename LIKE '/sa\_test/rp01/%' ESCAPE '\')
     + (SELECT COUNT(*) FROM DSSDEV.TB_TRANSACTION_SS_ESIM_REJECT WHERE cdr_filename LIKE '/sa\_test/rp01/%' ESCAPE '\')
     + (SELECT COUNT(*) FROM DSSDEV.TB_STAGING_SS_ESIM_RAW_TEMP   WHERE cdr_filename LIKE '/sa\_test/rp01/%' ESCAPE '\'))
FROM DUAL
UNION ALL
SELECT 17, 'CHK_DUPLICATE SATRP01% in valid+temp (must be 0)', TO_CHAR(
       (SELECT COUNT(*) FROM DSSDEV.TB_TRANSACTION_SS_ESIM_VALID WHERE chk_duplicate LIKE 'SATRP01%')
     + (SELECT COUNT(*) FROM DSSDEV.TB_TRANSACTION_SS_ESIM_TEMP  WHERE chk_duplicate LIKE 'SATRP01%'))
FROM DUAL
UNION ALL
SELECT 18, 'RAW_TEMP_ROWS_TOTAL (info; 080000 deletes the whole table)', TO_CHAR(COUNT(*)) FROM DSSDEV.TB_STAGING_SS_ESIM_RAW_TEMP
UNION ALL
SELECT 19, 'LANDING sample max partition_date|hour|minute (format check)',
       NVL(TO_CHAR(MAX(partition_date)) || '|' || TO_CHAR(MAX(partition_hour)) || '|' || TO_CHAR(MAX(partition_minute)), 'EMPTY')
FROM DSSDEV.TB_LANDING_SS_ESIM
WHERE input_source_name IS NULL OR input_source_name NOT LIKE '/sa\_test/%' ESCAPE '\'
UNION ALL
SELECT 20, 'CDR_TYPE 1 active in EXT_DSS_TB_MASTER_CDR_TYPE (must be 1)', TO_CHAR(COUNT(*))
FROM DSSDEV.EXT_DSS_TB_MASTER_CDR_TYPE WHERE cdr_type = '1' AND record_status = 'A'
UNION ALL
SELECT 30, 'MAPPING ' || m.b_no || ' / ' || m.invoicing_company_id,
       'rs=' || NVL(m.record_status, 'NULL')
       || ' eff=' || NVL(TO_CHAR(m.effective_date, 'YYYY-MM-DD'), 'NULL')
       || ' exp=' || NVL(TO_CHAR(m.expired_date, 'YYYY-MM-DD'), 'NULL')
       || ' cp=' || NVL(m.content_partner_id, 'NULL')
       || ' svc=' || NVL(TO_CHAR(m.service_id), 'NULL')
       || ' net=' || NVL(m.network_type, 'NULL')
       || ' sb=' || NVL(m.share_basis, 'NULL')
       || ' prt=' || NVL(m.price_rate_type, 'NULL')
FROM DSSDEV.EXT_DSS_VW_SERVICE_MAPPING_BNO_KEY m
WHERE m.b_no IN ('ECP_ESIM_SalesT', 'ECP_ESIM_Step', 'ECP_ESIM_Sales_Gable')
UNION ALL
SELECT 31, 'MAP_OK ECP_ESIM_SalesT/AWN active 2026-01-01 with 5 cols NOT NULL (must be 1)', TO_CHAR(COUNT(*))
FROM DSSDEV.EXT_DSS_VW_SERVICE_MAPPING_BNO_KEY m
WHERE m.record_status = 'A' AND m.b_no = 'ECP_ESIM_SalesT' AND m.invoicing_company_id = 'AWN'
  AND TRUNC(m.effective_date) <= DATE '2026-01-01'
  AND (m.expired_date IS NULL OR TRUNC(m.expired_date) >= DATE '2026-01-01')
  AND m.content_partner_id IS NOT NULL AND m.service_id IS NOT NULL AND m.network_type IS NOT NULL
  AND m.share_basis IS NOT NULL
UNION ALL
SELECT 32, 'MAP ECP_ESIM_SalesT/AWN active 2024-01-01 (must be 0)', TO_CHAR(COUNT(*))
FROM DSSDEV.EXT_DSS_VW_SERVICE_MAPPING_BNO_KEY m
WHERE m.record_status = 'A' AND m.b_no = 'ECP_ESIM_SalesT' AND m.invoicing_company_id = 'AWN'
  AND TRUNC(m.effective_date) <= DATE '2024-01-01'
  AND (m.expired_date IS NULL OR TRUNC(m.expired_date) >= DATE '2024-01-01')
UNION ALL
SELECT 33, 'MAP ECP_ESIM_Sales_Gable/AWN active 2026-01-01 (must be 0)', TO_CHAR(COUNT(*))
FROM DSSDEV.EXT_DSS_VW_SERVICE_MAPPING_BNO_KEY m
WHERE m.record_status = 'A' AND m.b_no = 'ECP_ESIM_Sales_Gable' AND m.invoicing_company_id = 'AWN'
  AND TRUNC(m.effective_date) <= DATE '2026-01-01'
  AND (m.expired_date IS NULL OR TRUNC(m.expired_date) >= DATE '2026-01-01')
UNION ALL
SELECT 34, 'MAP rows for Step/3BB-owner/odd b_no (must be 0)', TO_CHAR(COUNT(*))
FROM DSSDEV.EXT_DSS_VW_SERVICE_MAPPING_BNO_KEY m
WHERE m.record_status = 'A'
  AND (m.b_no IN ('ECP_ESIM_Step', ' _ESIM_SalesT', 'ecp_ESIM_SalesT', '_ESIM_SalesT', 'ECP_ESIM_')
       OR (m.b_no = 'ECP_ESIM_SalesT' AND m.invoicing_company_id = '3BB'))
ORDER BY 1, 2
