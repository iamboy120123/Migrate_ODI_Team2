-- ============================================================
-- ODI Procedure Body: task_17e9202f814842e3b6d91fabe785f479_050300_append_ss_esim_temp
-- Target Table      : DSSDEV.TB_TRANSACTION_SS_ESIM_TEMP
-- Generated         : 2026-10-29T18:11:04
-- Strategy          : append (smart->sinkOption.mode=Append, keyColumns=cdr_id ignored)
-- Error Handling    : fail-fast
-- ============================================================

-- @@ODI_STEP: STEP_1_INSERT
-- Load Strategy: append (Blendata sinkOption.mode = Append)
-- ไม่มี TRUNCATE โดยเจตนา - task นี้เป็น append ใน source
INSERT INTO <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.TB_TRANSACTION_SS_ESIM_TEMP (PARTITION_DATE, CDR_ID, CDR_TYPE, PARTNER, OWNER, ICCID, FIRST_INSTALLED, PROFILE_TYPE, EID, SIM_TYPE, CDR_FILENAME, CHK_DUPLICATE, CDR_SOURCE_PATH, FILTER_DTM, CREATE_BY, PROCESS_DATE, STATUS, B_NO, MAPPING_ERROR, ERR_MSG, WORKFLOW_PROCESS_DATE, FILE_DATE)
SELECT CAST(TO_CHAR(first_installed, 'YYYYMMDD') AS NUMBER) AS partition_date ,cdr_id ,cdr_type ,partner ,owner ,iccid ,first_installed ,profile_type ,eid ,sim_type ,cdr_filename ,chk_duplicate ,cdr_source_path ,filter_dtm ,create_by ,process_date ,status, b_no ,mapping_error ,err_msg ,workflow_process_date,file_date FROM ( SELECT cdr_id ,cdr_type ,partner ,owner ,iccid ,first_installed ,profile_type ,eid ,sim_type ,cdr_filename ,chk_duplicate ,source_path AS cdr_source_path ,filter_dtm ,create_by ,SYSDATE as process_date ,status, b_no ,mapping_error ,mapping_error_msg AS err_msg ,workflow_process_date,file_date FROM <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.tb_staging_ss_esim_raw_temp CROSS JOIN ( SELECT COUNT(*) AS chk_dup_append FROM <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.tb_transaction_ss_esim_temp WHERE workflow_process_date = (SELECT  workflow_process_date FROM <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.tb_staging_ss_esim_landing_to_discovery_workflow_status) ) WHERE status = 'UNMAP' AND chk_dup_append = 0 );
