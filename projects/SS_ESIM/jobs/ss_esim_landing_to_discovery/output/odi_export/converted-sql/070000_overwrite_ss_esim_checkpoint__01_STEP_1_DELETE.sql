DELETE FROM <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.TB_STAGING_SS_ESIM_CHECKPOINT
WHERE PARTITION_DATE IN (
    SELECT DISTINCT PARTITION_DATE
    FROM (
select CAST(TO_CHAR(process_date, 'YYYYMMDD') AS NUMBER) AS partition_date,checkpoint_partition,process_date from (select checkpoint_partition,process_date from <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.tb_staging_ss_esim_checkpoint_temp)
    )
)
