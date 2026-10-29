-- คอมไพล์ task_1b899dbbbe54449d8218e58bed2a044f_030000_running_ss_esim_landing_to_discovery_workflow_status.sql กับฐานจริงแบบไม่ดึงข้อมูล (WHERE 1=0) · SELECT อย่างเดียว
SELECT * FROM (
select 'TRUE' as running,TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') workflow_process_date FROM DUAL
) WHERE 1=0
