-- คอมไพล์ task_6660be16ef9e43bfbcc8974256bb27f6_090000_success_ss_esim_landing_to_discovery_workflow_status.sql กับฐานจริงแบบไม่ดึงข้อมูล (WHERE 1=0) · SELECT อย่างเดียว
SELECT * FROM (
select 'TRUE' as success FROM DUAL
) WHERE 1=0
