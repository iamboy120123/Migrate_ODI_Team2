-- ============================================================
-- ODI Procedure Body: task_0a7791409dbc4c789e892d888f5e1a51_080000_cleanup_ss_esim_raw_temp
-- Target Table      : DSSDEV.TB_STAGING_SS_ESIM_RAW_TEMP
-- Generated         : 2026-10-29 (manual entry, non-SQL task service-job-table-retention)
-- Strategy          : cleanup -- Q10 = A (DELETE ทั้งตาราง ตอนจบรอบ, olderThan: -1 = ล้างทั้งหมด -- ยืนยันกับทีม Blendata ก่อน G6)
-- Error Handling    : fail-fast
-- ============================================================

-- @@ODI_STEP: STEP_1_DELETE
DELETE FROM <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.TB_STAGING_SS_ESIM_RAW_TEMP
