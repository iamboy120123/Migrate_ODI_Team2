-- Load Strategy: overwrite (step 2/2)
INSERT INTO <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.TB_STAGING_SS_ESIM_CHECKPOINT (PARTITION_DATE, CHECKPOINT_PARTITION, PROCESS_DATE)
select CAST(TO_CHAR(process_date, 'YYYYMMDD') AS NUMBER) AS partition_date,checkpoint_partition,process_date from (select checkpoint_partition,process_date from <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.tb_staging_ss_esim_checkpoint_temp)
