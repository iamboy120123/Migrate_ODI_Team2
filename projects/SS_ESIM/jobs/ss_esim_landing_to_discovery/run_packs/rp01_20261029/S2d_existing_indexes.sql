-- S2d index ที่มีอยู่จริงของ target — รันเป็น DSSDEV บน Oracle Dev
-- รันได้ทุก client (DBeaver / SQL Developer / sqlplus) — เป็น SELECT เดียว
-- export ผลเป็น CSV (มี header) แล้ววางใน input/run_results/<ชื่อ pack นี้>/ ชื่อไฟล์อะไรก็ได้ (แนะนำ: indexes.csv)
SELECT i.table_name, i.index_name, i.uniqueness, c.column_position, c.column_name
FROM all_indexes i JOIN all_ind_columns c ON c.index_owner = i.owner AND c.index_name = i.index_name
WHERE i.table_owner = 'DSSDEV' AND i.table_name IN ('TB_STAGING_SS_ESIM_CHECKPOINT', 'TB_STAGING_SS_ESIM_CHECKPOINT_TEMP', 'TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS', 'TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS_TEMP', 'TB_STAGING_SS_ESIM_RAW_TEMP', 'TB_TRANSACTION_SS_ESIM_REJECT', 'TB_TRANSACTION_SS_ESIM_TEMP', 'TB_TRANSACTION_SS_ESIM_VALID')
ORDER BY i.table_name, i.index_name, c.column_position
