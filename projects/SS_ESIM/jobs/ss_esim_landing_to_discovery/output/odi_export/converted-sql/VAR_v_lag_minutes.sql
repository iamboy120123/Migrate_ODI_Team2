SELECT NVL(ROUND((SYSDATE - TO_DATE(TO_CHAR(MAX(partition_minute)), 'YYYYMMDDHH24MI')) * 1440), 999999) FROM <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.tb_landing_ss_esim
