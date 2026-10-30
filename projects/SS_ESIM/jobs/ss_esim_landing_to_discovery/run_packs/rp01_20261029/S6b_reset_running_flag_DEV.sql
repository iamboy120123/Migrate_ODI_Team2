-- S6b reset flag running (ADR-006 O11) — **Oracle Dev เท่านั้น** รันเป็น DSSDEV · Execute Script (Alt+X)
-- ใช้เมื่อรอบทดสอบล้มกลางทางแล้ว running = 'TRUE' ค้าง (รอบถัดไปจะเจอ ORA-20003 หลังเพิ่ม guard)
-- ผลเท่ากับจบ step 080000 (success = 'TRUE') · ห้ามใช้ใน SIT/PROD — ใช้ runbook ADR-007
SELECT 'BEFORE' AS t, running, success, workflow_process_date FROM DSSDEV.TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS;
DELETE FROM DSSDEV.TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS WHERE running = 'TRUE';
INSERT INTO DSSDEV.TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS (success) SELECT 'TRUE' FROM dual WHERE NOT EXISTS (SELECT 1 FROM DSSDEV.TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS);
COMMIT;
SELECT 'AFTER' AS t, running, success, workflow_process_date FROM DSSDEV.TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS;
