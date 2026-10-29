-- ============================================================
-- ODI Procedure Body: task_6660be16ef9e43bfbcc8974256bb27f6_090000_success_ss_esim_landing_to_discovery_workflow_status
-- Target Table      : DSSDEV.TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS
-- Generated         : 2026-10-29T18:11:04
-- Strategy          : overwrite (smart->sinkOption.mode=overwrite)
-- Error Handling    : fail-fast
-- ============================================================

-- @@ODI_STEP: STEP_1_TRUNCATE
-- Load Strategy: overwrite (step 1/2)
TRUNCATE TABLE <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS;

-- @@ODI_STEP: STEP_2_INSERT
-- Load Strategy: overwrite (step 2/2)
INSERT INTO <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS (SUCCESS)
select 'TRUE' as success FROM DUAL;
