-- ============================================================
-- ODI Procedure Body: task_6451c19231b14139ab3d99b35ac9c734_020000_overwrite_ss_esim_checkpoint_temp
-- Target Table      : DSSDEV.TB_STAGING_SS_ESIM_CHECKPOINT_TEMP
-- Generated         : 2026-10-29T18:11:04
-- Strategy          : overwrite-by-partition (I14 delete_by_partition: PARTITION_DATE)
-- Error Handling    : fail-fast
-- ============================================================

-- @@ODI_STEP: STEP_1_DELETE
-- Load Strategy: overwrite by partition (step 1/2) -- I14: DELETE เฉพาะ partition ที่กำลังจะโหลดใหม่ ไม่ TRUNCATE ทั้งตาราง
-- SELECT ข้างล่างต้องเหมือน step 2 ทุกประการ (แก้ที่เดียวต้องแก้ทั้งคู่)
DELETE FROM <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.TB_STAGING_SS_ESIM_CHECKPOINT_TEMP
WHERE PARTITION_DATE IN (
    SELECT DISTINCT PARTITION_DATE
    FROM (
select partition_date, case when rnk in(1, 2) or checkpoint_partition <=(nth_value(checkpoint_partition, 2) over( order by checkpoint_partition)) + 300 then checkpoint_partition else min(checkpoint_partition) over (partition by partition_date) end as checkpoint_partition , process_date FROM ( SELECT CAST(TO_CHAR(process_date, 'YYYYMMDD') AS NUMBER) AS partition_date, checkpoint_partition, DENSE_RANK() OVER ( ORDER BY checkpoint_partition ASC) as rnk, process_date FROM ( SELECT DISTINCT partition_minute AS checkpoint_partition , SYSDATE AS process_date FROM <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.tb_landing_ss_esim WHERE partition_minute < TO_NUMBER(TO_CHAR(SYSDATE-INTERVAL '5' MINUTE, 'YYYYMMDDHH24MI')) AND partition_minute >= ( SELECT COALESCE(MAX(checkpoint_partition), 0) AS checkpoint_partition FROM <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.tb_staging_ss_esim_checkpoint) AND 'TRUE' = UPPER(COALESCE(( SELECT success FROM <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.tb_staging_ss_esim_landing_to_discovery_workflow_status), 'TRUE'))))
    )
)

-- @@ODI_STEP: STEP_2_INSERT
-- Load Strategy: overwrite (step 2/2)
INSERT INTO <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.TB_STAGING_SS_ESIM_CHECKPOINT_TEMP (PARTITION_DATE, CHECKPOINT_PARTITION, PROCESS_DATE)
select partition_date, case when rnk in(1, 2) or checkpoint_partition <=(nth_value(checkpoint_partition, 2) over( order by checkpoint_partition)) + 300 then checkpoint_partition else min(checkpoint_partition) over (partition by partition_date) end as checkpoint_partition , process_date FROM ( SELECT CAST(TO_CHAR(process_date, 'YYYYMMDD') AS NUMBER) AS partition_date, checkpoint_partition, DENSE_RANK() OVER ( ORDER BY checkpoint_partition ASC) as rnk, process_date FROM ( SELECT DISTINCT partition_minute AS checkpoint_partition , SYSDATE AS process_date FROM <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.tb_landing_ss_esim WHERE partition_minute < TO_NUMBER(TO_CHAR(SYSDATE-INTERVAL '5' MINUTE, 'YYYYMMDDHH24MI')) AND partition_minute >= ( SELECT COALESCE(MAX(checkpoint_partition), 0) AS checkpoint_partition FROM <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.tb_staging_ss_esim_checkpoint) AND 'TRUE' = UPPER(COALESCE(( SELECT success FROM <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.tb_staging_ss_esim_landing_to_discovery_workflow_status), 'TRUE'))));
