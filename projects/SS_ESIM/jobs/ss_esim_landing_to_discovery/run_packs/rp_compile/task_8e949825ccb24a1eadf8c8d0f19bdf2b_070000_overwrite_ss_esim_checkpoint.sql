-- คอมไพล์ task_8e949825ccb24a1eadf8c8d0f19bdf2b_070000_overwrite_ss_esim_checkpoint.sql กับฐานจริงแบบไม่ดึงข้อมูล (WHERE 1=0) · SELECT อย่างเดียว
SELECT * FROM (
select CAST(TO_CHAR(process_date, 'YYYYMMDD') AS NUMBER) AS partition_date,checkpoint_partition,process_date from (select checkpoint_partition,process_date from DSSDEV.tb_staging_ss_esim_checkpoint_temp)
) WHERE 1=0
