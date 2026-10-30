-- S2b preflight (2026-10-29T21:09:41) — รันเป็น DSSDEV บน Oracle Dev
-- รันได้ทุก client (DBeaver / SQL Developer / sqlplus) — เป็น SELECT เดียว
-- export ผลเป็น CSV (มี header) แล้ววางใน input/run_results/<ชื่อ pack นี้>/ ชื่อไฟล์อะไรก็ได้ (แนะนำ: preflight.csv)
-- ผลต้องได้หลายแถว: check 0,2,5,6,7 (+2b ถ้ามีตารางขาด)
SELECT '0' AS check_id, 'DB_VERSION' AS check_name, product AS item, version AS result, '19.x' AS expected FROM product_component_version WHERE UPPER(product) LIKE '%DATABASE%'
UNION ALL
SELECT '2', 'TARGET_TABLES', 'found', TO_CHAR(COUNT(*)), '8' FROM all_tables WHERE owner = 'DSSDEV' AND table_name IN ('TB_STAGING_SS_ESIM_CHECKPOINT', 'TB_STAGING_SS_ESIM_CHECKPOINT_TEMP', 'TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS', 'TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS_TEMP', 'TB_STAGING_SS_ESIM_RAW_TEMP', 'TB_TRANSACTION_SS_ESIM_REJECT', 'TB_TRANSACTION_SS_ESIM_TEMP', 'TB_TRANSACTION_SS_ESIM_VALID')
UNION ALL
SELECT '2b', 'MISSING_TABLE', t.column_value, 'MISSING', 'none' FROM TABLE(sys.odcivarchar2list('TB_STAGING_SS_ESIM_CHECKPOINT', 'TB_STAGING_SS_ESIM_CHECKPOINT_TEMP', 'TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS', 'TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS_TEMP', 'TB_STAGING_SS_ESIM_RAW_TEMP', 'TB_TRANSACTION_SS_ESIM_REJECT', 'TB_TRANSACTION_SS_ESIM_TEMP', 'TB_TRANSACTION_SS_ESIM_VALID')) t WHERE NOT EXISTS (SELECT 1 FROM all_tables a WHERE a.owner = 'DSSDEV' AND a.table_name = t.column_value)
UNION ALL
SELECT '5', 'EXTERNAL_OBJECT', e.column_value, NVL((SELECT MIN(o.owner || '.' || o.object_type) FROM all_objects o WHERE o.object_name = e.column_value), 'NOT FOUND'), 'found' FROM TABLE(sys.odcivarchar2list('EXT_DSS_CHECKPOINT_TB_TRANSACTION_SS_ESIM_VALID', 'EXT_DSS_TB_MASTER_CDR_TYPE', 'EXT_DSS_VW_SERVICE_MAPPING_BNO_KEY', 'TB_LANDING_SS_ESIM')) e
UNION ALL
SELECT '6', 'IS_OWNER', 'DSSDEV', CASE WHEN 'DSSDEV' = 'DSSDEV' THEN 'YES' ELSE 'NO' END, 'YES' FROM dual
UNION ALL
SELECT '7', 'NAME_RESOLUTION', n.column_value, CASE WHEN EXISTS (SELECT 1 FROM all_objects o WHERE o.owner = 'DSSDEV' AND o.object_name = n.column_value AND o.object_type IN ('TABLE','VIEW','MATERIALIZED VIEW')) THEN 'OWN OBJECT' WHEN EXISTS (SELECT 1 FROM all_synonyms s WHERE s.owner IN ('DSSDEV', 'PUBLIC') AND s.synonym_name = n.column_value) THEN 'SYNONYM' ELSE 'NOT RESOLVABLE' END, 'OWN OBJECT|SYNONYM' FROM TABLE(sys.odcivarchar2list()) n
ORDER BY 1, 3
