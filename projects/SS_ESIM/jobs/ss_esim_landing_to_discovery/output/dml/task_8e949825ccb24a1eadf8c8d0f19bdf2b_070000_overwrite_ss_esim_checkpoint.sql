-- ============================================================
-- ODI Procedure Body: task_8e949825ccb24a1eadf8c8d0f19bdf2b_070000_overwrite_ss_esim_checkpoint
-- Target Table      : DSSDEV.TB_STAGING_SS_ESIM_CHECKPOINT
-- Generated         : 2026-10-29T18:11:04
-- Strategy          : overwrite-by-partition (I14 delete_by_partition: PARTITION_DATE)
-- Error Handling    : fail-fast
-- ============================================================

-- @@ODI_STEP: STEP_1_DELETE
-- Load Strategy: overwrite by partition (step 1/2) -- I14: DELETE เฉพาะ partition ที่กำลังจะโหลดใหม่ ไม่ TRUNCATE ทั้งตาราง
-- SELECT ข้างล่างต้องเหมือน step 2 ทุกประการ (แก้ที่เดียวต้องแก้ทั้งคู่)
DELETE FROM <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.TB_STAGING_SS_ESIM_CHECKPOINT
WHERE PARTITION_DATE IN (
    SELECT DISTINCT PARTITION_DATE
    FROM (
select CAST(TO_CHAR(process_date, 'YYYYMMDD') AS NUMBER) AS partition_date,checkpoint_partition,process_date from (select checkpoint_partition,process_date from <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.tb_staging_ss_esim_checkpoint_temp)
    )
)

-- @@ODI_STEP: STEP_2_INSERT
-- Load Strategy: overwrite (step 2/2)
INSERT INTO <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.TB_STAGING_SS_ESIM_CHECKPOINT (PARTITION_DATE, CHECKPOINT_PARTITION, PROCESS_DATE)
select CAST(TO_CHAR(process_date, 'YYYYMMDD') AS NUMBER) AS partition_date,checkpoint_partition,process_date from (select checkpoint_partition,process_date from <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.tb_staging_ss_esim_checkpoint_temp);
