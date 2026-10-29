-- 02_preflight_checks.sql  (generated 2026-10-29T20:57:56)
-- Project: SS_ESIM_L2D
-- รันทั้งไฟล์แล้วดูผล - ทุก check ต้องได้ผลตามคอลัมน์ EXPECTED ก่อนเริ่ม Phase 6 Smart Import

-- [1] COMPATIBLE ต้อง >= 12.2 (ชื่อ target ยาวสุด 60 ตัวอักษร เกิน 30)
SELECT 'COMPATIBLE' AS check_name, value, '>= 12.2' AS expected
FROM   v$parameter WHERE name = 'compatible';

-- [2] target table ต้องมีครบ 8 ตาราง
SELECT 'TARGET_TABLES' AS check_name, COUNT(*) AS found, 8 AS expected
FROM   all_tables
WHERE  owner IN ('DSSDEV')
AND    table_name IN (
         'TB_TRANSACTION_SS_ESIM_REJECT',
         'TB_TRANSACTION_SS_ESIM_TEMP',
         'TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS',
         'TB_STAGING_SS_ESIM_CHECKPOINT_TEMP',
         'TB_STAGING_SS_ESIM_CHECKPOINT',
         'TB_STAGING_SS_ESIM_RAW_TEMP',
         'TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS_TEMP',
         'TB_TRANSACTION_SS_ESIM_VALID');

-- [2b] ตารางที่ยังขาด
SELECT t.tbl AS missing_target_table
FROM  (SELECT column_value AS tbl FROM TABLE(sys.odcivarchar2list(
         'TB_TRANSACTION_SS_ESIM_REJECT',
         'TB_TRANSACTION_SS_ESIM_TEMP',
         'TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS',
         'TB_STAGING_SS_ESIM_CHECKPOINT_TEMP',
         'TB_STAGING_SS_ESIM_CHECKPOINT',
         'TB_STAGING_SS_ESIM_RAW_TEMP',
         'TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS_TEMP',
         'TB_TRANSACTION_SS_ESIM_VALID'))) t
WHERE NOT EXISTS (SELECT 1 FROM all_tables a
                  WHERE a.owner IN ('DSSDEV') AND a.table_name = t.tbl);

-- [3] error log table: ข้าม (error_handling = 'fail-fast')
--     DML ไม่มี LOG ERRORS clause แล้ว ตามมาตรฐาน Smart Export ของทีม

-- [4] สิทธิ์ของ ODI work user (work user = DSSDEV ตาม config odi.work_user / Q16)
SELECT 'PRIVS' AS check_name, privilege, table_name
FROM   all_tab_privs
WHERE  grantee = UPPER('DSSDEV')
AND    table_name IN (
         'TB_TRANSACTION_SS_ESIM_REJECT',
         'TB_TRANSACTION_SS_ESIM_TEMP',
         'TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS',
         'TB_STAGING_SS_ESIM_CHECKPOINT_TEMP',
         'TB_STAGING_SS_ESIM_CHECKPOINT',
         'TB_STAGING_SS_ESIM_RAW_TEMP',
         'TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS_TEMP',
         'TB_TRANSACTION_SS_ESIM_VALID')
ORDER  BY table_name, privilege;
-- ผลว่าง = ไม่มี grant ตรงบนตาราง (ยังไม่ใช่ไม่มีสิทธิ์: อาจได้ผ่าน role/ANY privilege) -> ดูสิทธิ์จริงของ session ด้านล่าง
SELECT 'ANY_TABLE_PRIVS' AS check_name, privilege
FROM   session_privs
WHERE  privilege IN ('SELECT ANY TABLE', 'INSERT ANY TABLE', 'UPDATE ANY TABLE', 'DELETE ANY TABLE')
ORDER  BY privilege;
-- สิทธิ์ขั้นต่ำที่คำนวณจาก DML จริงของแต่ละ target (ถ้าเป็น owner ข้ามได้):
--   TB_TRANSACTION_SS_ESIM_REJECT                                INSERT
--   TB_TRANSACTION_SS_ESIM_TEMP                                  INSERT
--   TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS      INSERT  (+TRUNCATE)
--   TB_STAGING_SS_ESIM_CHECKPOINT_TEMP                           DELETE, INSERT, SELECT
--   TB_STAGING_SS_ESIM_CHECKPOINT                                DELETE, INSERT, SELECT
--   TB_STAGING_SS_ESIM_RAW_TEMP                                  DELETE, INSERT, SELECT
--   TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS_TEMP INSERT  (+TRUNCATE)
--   TB_TRANSACTION_SS_ESIM_VALID                                 INSERT
-- TRUNCATE ต้องใช้ DROP ANY TABLE หรือเป็น owner เอง (ดู check [6])

-- [5] source object ที่ SQL อ้างถึงแต่ไม่ได้ generate โดย kit นี้ (external/view)
--     คำนวณจาก FROM/JOIN ใน converted SQL หักด้วย target ของทุก task:
--   EXT_DSS_CHECKPOINT_TB_TRANSACTION_SS_ESIM_VALID    ใช้ใน task 999999
--   EXT_DSS_TB_MASTER_CDR_TYPE                         ใช้ใน task 040000
--   EXT_DSS_VW_SERVICE_MAPPING_BNO_KEY                 ใช้ใน task 040000
--   TB_LANDING_SS_ESIM                                 ใช้ใน task 020000, 040000
SELECT 'EXTERNAL_OBJECTS' AS check_name, object_name, object_type, owner
FROM   all_objects
WHERE  object_name IN ('EXT_DSS_CHECKPOINT_TB_TRANSACTION_SS_ESIM_VALID',
                       'EXT_DSS_TB_MASTER_CDR_TYPE',
                       'EXT_DSS_VW_SERVICE_MAPPING_BNO_KEY',
                       'TB_LANDING_SS_ESIM')
ORDER  BY object_name;
-- expected: ครบ 4 object (ถ้าขาด = SQL จะ fail ตอนรัน ไม่ใช่ตอน import)
-- ODI work user ต้องมี SELECT บนทุก object ข้างบน (หรือผ่าน synonym)

-- [6] สิทธิ์ TRUNCATE ของ ODI work user
--     TRUNCATE เป็น DDL: ต้องเป็น owner ของตาราง หรือมี DROP ANY TABLE
--     DML ใช้ TRUNCATE TABLE ตรง ๆ (truncate_style=plain) หรือห่อ BEGIN EXECUTE IMMEDIATE (execute_immediate) — รันด้วยสิทธิ์ของ session
SELECT 'IS_OWNER' AS check_name,
       CASE WHEN UPPER('DSSDEV') IN ('DSSDEV') THEN 'YES - ไม่ต้องขอ DROP ANY TABLE'
            ELSE 'NO - ต้องมี DROP ANY TABLE' END AS result
FROM   dual;

-- ใช้ session_privs (สิทธิ์ที่ session นี้ใช้ได้จริง รวมที่ได้ผ่าน role เช่น DBA) - ต้องรันด้วย user เดียวกับที่ ODI ต่อ DB
-- (all_sys_privs ไม่มีใน Oracle -> ORA-00942 / dba_sys_privs ไม่นับสิทธิ์ที่มาจาก role)
SELECT 'DROP_ANY_TABLE' AS check_name, COUNT(*) AS granted, '1 ถ้าไม่ได้เป็น owner (รันด้วย DSSDEV)' AS expected
FROM   session_privs
WHERE  privilege = 'DROP ANY TABLE';
