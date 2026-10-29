-- Load Strategy: overwrite (step 2/2)
INSERT INTO <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS (RUNNING, WORKFLOW_PROCESS_DATE)
select 'TRUE' as running,TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') workflow_process_date FROM DUAL
