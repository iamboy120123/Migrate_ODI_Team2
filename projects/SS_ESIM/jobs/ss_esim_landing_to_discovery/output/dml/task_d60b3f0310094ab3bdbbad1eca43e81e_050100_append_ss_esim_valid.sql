-- ============================================================
-- ODI Procedure Body: task_d60b3f0310094ab3bdbbad1eca43e81e_050100_append_ss_esim_valid
-- Target Table      : DSSDEV.TB_TRANSACTION_SS_ESIM_VALID
-- Generated         : 2026-10-29T18:11:04
-- Strategy          : append (smart->sinkOption.mode=Append)
-- Error Handling    : fail-fast
-- ============================================================

-- @@ODI_STEP: STEP_1_INSERT
-- Load Strategy: append (Blendata sinkOption.mode = Append)
-- ไม่มี TRUNCATE โดยเจตนา - task นี้เป็น append ใน source
INSERT INTO <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.TB_TRANSACTION_SS_ESIM_VALID (PARTITION_DATE, CDR_ID, CDR_TYPE, PARTNER, OWNER, ICCID, FIRST_INSTALLED, PROFILE_TYPE, EID, SIM_TYPE, CP_ID, SERVICE_ID, BEFORE_SHARING, PRICE_RATE_TYPE, NETWORK_TYPE, INVOICING_CO_ID, SHARE_BASIS, CDR_FILENAME, CHK_DUPLICATE, FILTER_DTM, CREATE_BY, REMAP_DTM, REMAP_BY, PROCESS_DATE, TRANSACTION_UNITS, STATUS, WORKFLOW_PROCESS_DATE, FILE_DATE)
SELECT CAST(TO_CHAR(first_installed, 'YYYYMMDD') AS NUMBER) AS partition_date ,cdr_id ,cdr_type ,partner ,owner ,iccid ,first_installed ,profile_type ,eid ,sim_type ,cp_id ,service_id ,before_sharing ,price_rate_type ,network_type ,invoicing_co_id ,share_basis ,cdr_filename ,chk_duplicate ,filter_dtm ,create_by ,remap_dtm ,remap_by ,process_date ,transaction_units ,status ,workflow_process_date,file_date FROM ( SELECT cdr_id ,cdr_type ,partner ,owner ,iccid ,first_installed ,profile_type ,eid ,sim_type ,cp_id ,service_id ,null as before_sharing ,price_rate_type ,network_type ,invoicing_co_id ,share_basis ,cdr_filename ,chk_duplicate ,filter_dtm ,create_by ,null as remap_dtm ,null as remap_by ,SYSDATE as process_date ,'1' as transaction_units ,status ,workflow_process_date, file_date FROM <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.tb_staging_ss_esim_raw_temp CROSS JOIN ( SELECT COUNT(*) AS chk_dup_append FROM <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.tb_transaction_ss_esim_valid WHERE status = 'MAP' AND workflow_process_date = (SELECT workflow_process_date FROM <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.tb_staging_ss_esim_landing_to_discovery_workflow_status) ) WHERE status = 'MAP' AND chk_dup_append = 0 );
