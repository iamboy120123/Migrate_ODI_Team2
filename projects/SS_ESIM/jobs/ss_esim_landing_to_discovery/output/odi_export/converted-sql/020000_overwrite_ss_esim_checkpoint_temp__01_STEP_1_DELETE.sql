DELETE FROM <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.TB_STAGING_SS_ESIM_CHECKPOINT_TEMP
WHERE PARTITION_DATE IN (
    SELECT DISTINCT PARTITION_DATE
    FROM (
select partition_date, case when rnk in(1, 2) or checkpoint_partition <=(nth_value(checkpoint_partition, 2) over( order by checkpoint_partition)) + 300 then checkpoint_partition else min(checkpoint_partition) over (partition by partition_date) end as checkpoint_partition , process_date FROM ( SELECT CAST(TO_CHAR(process_date, 'YYYYMMDD') AS NUMBER) AS partition_date, checkpoint_partition, DENSE_RANK() OVER ( ORDER BY checkpoint_partition ASC) as rnk, process_date FROM ( SELECT DISTINCT partition_minute AS checkpoint_partition , SYSDATE AS process_date FROM <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.tb_landing_ss_esim WHERE partition_minute < TO_NUMBER(TO_CHAR(SYSDATE-INTERVAL '5' MINUTE, 'YYYYMMDDHH24MI')) AND partition_minute >= ( SELECT COALESCE(MAX(checkpoint_partition), 0) AS checkpoint_partition FROM <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.tb_staging_ss_esim_checkpoint) AND 'TRUE' = UPPER(COALESCE(( SELECT success FROM <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.tb_staging_ss_esim_landing_to_discovery_workflow_status), 'TRUE'))))
    )
)
