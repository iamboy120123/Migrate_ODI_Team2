-- ============================================================
-- ODI Procedure Body: task_cc72e06e0d2b4dc29d37f72e1c729d1d_010000_check_success_ss_esim_landing_to_discovery_workflow_status
-- Target Table      : DSSDEV.TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS_TEMP
-- Generated         : 2026-10-29T18:11:04
-- Strategy          : overwrite (smart->sinkOption.mode=overwrite)
-- Error Handling    : fail-fast
-- ============================================================

-- @@ODI_STEP: STEP_1_TRUNCATE
-- Load Strategy: overwrite (step 1/2)
TRUNCATE TABLE <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS_TEMP;

-- @@ODI_STEP: STEP_2_INSERT
-- Load Strategy: overwrite (step 2/2)
INSERT INTO <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS_TEMP (SUCCESS)
select success from <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.tb_staging_ss_esim_landing_to_discovery_workflow_status;
