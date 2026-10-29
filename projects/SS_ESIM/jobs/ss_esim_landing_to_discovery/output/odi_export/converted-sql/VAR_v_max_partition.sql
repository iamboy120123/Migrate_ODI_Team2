SELECT NVL(MAX(partition_minute), 0) FROM <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.tb_landing_ss_esim
