-- คอมไพล์ task_cc72e06e0d2b4dc29d37f72e1c729d1d_010000_check_success_ss_esim_landing_to_discovery_workflow_status.sql กับฐานจริงแบบไม่ดึงข้อมูล (WHERE 1=0) · SELECT อย่างเดียว
SELECT * FROM (
select success from DSSDEV.tb_staging_ss_esim_landing_to_discovery_workflow_status
) WHERE 1=0
