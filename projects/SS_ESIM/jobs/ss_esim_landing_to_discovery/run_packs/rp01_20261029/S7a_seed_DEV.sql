-- ============================================================
-- S7a_seed_DEV.sql  (rp01_20261029 / SS_ESIM_L2D)  -- Oracle DEV เท่านั้น, user DSSDEV
-- หลาย statement -> รันด้วย **Execute Script (Alt+X) ครั้งเดียว** แล้วดูผล SELECT สุดท้ายทันที
-- ยังไม่ได้ทดสอบกับ DBeaver ของผู้ใช้
--
-- Marker: input_source_name / cdr_filename LIKE '/sa_test/rp01/%'  (ลบด้วย S7c_cleanup_DEV.sql)
-- ข้อมูลทดสอบ: 1 แถว = 1 เงื่อนไข (ดูรายการ case ใน S7b_assertions.sql)
--
-- Partition (YYYYMMDDHH24MI เป็น NUMBER) คำนวณจาก SYSDATE ใน statement เดียว:
--   P1 = SYSDATE-310 นาที   (แถวปกติเกือบทั้งหมด)
--   P2 = SYSDATE-309 นาที   (ต้องถูกประมวลผล, กลายเป็น MAX checkpoint ใหม่)
--   P3 = SYSDATE-10 นาที    (เกินกรอบ +300 ของ 020000 -> ต้องค้างไว้รอบหน้า)
--   PF = SYSDATE+65 นาที    (อนาคต -> ต้องไม่ถูกหยิบเพราะ < SYSDATE-5 นาที ของ 020000)
--   PE = MAX(checkpoint) เดิม (ขอบ = checkpoint -> 020000 หยิบ (>=) แต่ 040000 ไม่หยิบ (>)) -- ใส่เฉพาะเมื่อ MAX > 0
--
-- *** เส้นตาย ***
--   - ต้องรัน scenario PKG_SS_ESIM_L2D ภายใน 60 นาทีหลัง seed (SEED_VERDICT บอกเวลา)
--     ถ้าช้ากว่านั้น แถว PF จะถูกหยิบ และ case C26 จะ FAIL (ไม่ใช่ความผิดของ package)
--   - config.precheck.landing_max_lag_minutes = 120 นาที: package รอบนี้ยังไม่มี Evaluate/precheck step
--     จึงไม่บังคับ แต่ถ้าเพิ่ม precheck ภายหลัง ต้องรันภายใน 120 นาทีหลัง seed ด้วย
--   - seed ได้เฉพาะเวลา 05:15-23:59 (P1..P3 ต้องอยู่วันเดียวกัน เพื่อให้เลข +300 ของ 020000 คาดผลได้)
--   - ระหว่าง seed ถึงรัน ห้ามมีรอบอื่นของ workflow นี้ (scheduler ใน DEV) มาหยิบข้อมูลไปก่อน
--
-- Guard: ถ้าเงื่อนไขไม่ครบ INSERT จะได้ 0 แถว (ไม่ error) -> SEED_VERDICT = STOP -> รัน D1_diagnose.sql ดูข้อที่ไม่ผ่าน
--   (เวลา < 05:15 · MAX checkpoint >= P1 · มี marker ค้าง · status table > 1 แถว · success ไม่ใช่ TRUE/NULL
--    · มีแถว landing จริงหลัง checkpoint · ICCID SATRP01% มีอยู่แล้วใน valid/temp)
--
-- หมายเหตุ data contract: FIRST_INSTALLED เป็น VARCHAR2(100) จึงใส่ string วันที่ผิดได้จริง (TYP)
--   '' ใน Oracle = NULL (C10 ทดสอบว่า '' ก็เป็น MAN เหมือน Spark nullif(x,''))
-- ============================================================

INSERT INTO DSSDEV.TB_LANDING_SS_ESIM
  (BODY_TAG, PARTNER, OWNER, ICCID, FIRST_INSTALLED, PROFILE_TYPE, EID, SIM_TYPE,
   RAW_DATA, NUMBER_OF_COLS, PROCESS_DATE, INPUT_SOURCE_NAME,
   PARTITION_DATE, PARTITION_HOUR, PARTITION_MINUTE)
SELECT x.bt, x.pa, x.ow, x.ic, x.fi, x.pt, x.ei, x.st,
       TO_CLOB(x.bt || '|' || x.pa || '|' || x.ow || '|' || x.ic || '|' || x.fi || '|' || x.pt || '|' || x.ei || '|' || x.st),
       8, CAST(SYSDATE AS TIMESTAMP), x.fn,
       TRUNC(x.pm / 10000), TRUNC(x.pm / 100), x.pm
FROM (
  SELECT c.cid, c.ptn, c.bt, c.pa, c.ow, c.ic, c.fi, c.pt, c.ei, c.st, c.fn,
         CASE c.ptn WHEN 'P1' THEN g.p1 WHEN 'P2' THEN g.p2 WHEN 'P3' THEN g.p3
                    WHEN 'PF' THEN g.pf WHEN 'PE' THEN g.m END AS pm,
         g.go, g.m
  FROM (
    --          case                    ptn   body  partner owner  iccid         first_installed       profile       eid      sim_type        file
    SELECT 'C01' cid, 'P1' ptn, '02' bt, 'ECP' pa, 'AWN' ow, 'SATRP0101' ic, '20260101100000' fi, 'Production' pt, 'SAT01' ei, 'SalesT' st, '/sa_test/rp01/PGZ_ESIM_INVENTORY1_20261029_100000_1.txt' fn FROM DUAL UNION ALL
    SELECT 'C02', 'P1', '02', 'ECP', 'AWN', 'SATRP0102', '20260101100000', 'Production', 'SAT02', 'Step',        '/sa_test/rp01/PGZ_ESIM_INVENTORY1_20261029_100000_1.txt' FROM DUAL UNION ALL
    SELECT 'C03', 'P1', '02', 'ECP', '3BB', 'SATRP0103', '20260101100000', 'Production', 'SAT03', 'SalesT',      '/sa_test/rp01/PGZ_ESIM_INVENTORY1_20261029_100000_1.txt' FROM DUAL UNION ALL
    SELECT 'C04', 'P1', '02', 'ECP', 'AWN', 'SATRP0104', '20240101100000', 'Production', 'SAT04', 'SalesT',      '/sa_test/rp01/PGZ_ESIM_INVENTORY1_20261029_100000_1.txt' FROM DUAL UNION ALL
    SELECT 'C05', 'P1', '02', 'ECP', 'AWN', 'SATRP0105', '20260101100000', 'Production', 'SAT05', 'Sales_Gable', '/sa_test/rp01/PGZ_ESIM_INVENTORY1_20261029_100000_1.txt' FROM DUAL UNION ALL
    SELECT 'C06', 'P1', '02', NULL,  'AWN', 'SATRP0106', '20260101100000', 'Production', 'SAT06', 'SalesT',      '/sa_test/rp01/PGZ_ESIM_INVENTORY1_20261029_100000_1.txt' FROM DUAL UNION ALL
    SELECT 'C07', 'P1', '02', 'ECP', 'AWN', 'SATRP0107', '20260101100000', 'Production', 'SAT07', NULL,          '/sa_test/rp01/PGZ_ESIM_INVENTORY1_20261029_100000_1.txt' FROM DUAL UNION ALL
    SELECT 'C08', 'P1', '02', 'ECP', 'AWN', NULL,        '20260101100000', 'Production', 'SAT08', 'SalesT',      '/sa_test/rp01/PGZ_ESIM_INVENTORY1_20261029_100000_1.txt' FROM DUAL UNION ALL
    SELECT 'C09', 'P1', '02', 'ECP', 'AWN', 'SATRP0109', NULL,             'Production', 'SAT09', 'SalesT',      '/sa_test/rp01/PGZ_ESIM_INVENTORY1_20261029_100000_1.txt' FROM DUAL UNION ALL
    SELECT 'C10', 'P1', '02', 'ECP', 'AWN', 'SATRP0110', '20260101100000', '',           'SAT10', 'SalesT',      '/sa_test/rp01/PGZ_ESIM_INVENTORY1_20261029_100000_1.txt' FROM DUAL UNION ALL
    SELECT 'C11', 'P1', '02', ' ',   'AWN', 'SATRP0111', '20260101100000', 'Production', 'SAT11', 'SalesT',      '/sa_test/rp01/PGZ_ESIM_INVENTORY1_20261029_100000_1.txt' FROM DUAL UNION ALL
    SELECT 'C12', 'P1', '02', 'ECP', 'AWN', 'SATRP0112', '20230229000000', 'Production', 'SAT12', 'SalesT',      '/sa_test/rp01/PGZ_ESIM_INVENTORY1_20261029_100000_1.txt' FROM DUAL UNION ALL
    SELECT 'C13', 'P1', '02', 'ECP', 'AWN', 'SATRP0113', '20241301000000', 'Production', 'SAT13', 'SalesT',      '/sa_test/rp01/PGZ_ESIM_INVENTORY1_20261029_100000_1.txt' FROM DUAL UNION ALL
    SELECT 'C14', 'P1', '02', 'ECP', 'AWN', 'SATRP0114', '20240101240000', 'Production', 'SAT14', 'SalesT',      '/sa_test/rp01/PGZ_ESIM_INVENTORY1_20261029_100000_1.txt' FROM DUAL UNION ALL
    SELECT 'C15', 'P1', '02', 'ECP', 'AWN', 'SATRP0115', 'ABCDEFGHIJKLMN', 'Production', 'SAT15', 'SalesT',      '/sa_test/rp01/PGZ_ESIM_INVENTORY1_20261029_100000_1.txt' FROM DUAL UNION ALL
    SELECT 'C16', 'P1', '02', 'ECP', 'AWN', 'SATRP0116', '20260101100000123', 'Production', 'SAT16', 'SalesT',   '/sa_test/rp01/PGZ_ESIM_INVENTORY1_20261029_100000_1.txt' FROM DUAL UNION ALL
    SELECT 'C17', 'P1', '02', 'ecp', 'AWN', 'SATRP0117', '20260101100000', 'Production', 'SAT17', 'SalesT',      '/sa_test/rp01/PGZ_ESIM_INVENTORY1_20261029_100000_1.txt' FROM DUAL UNION ALL
    SELECT 'C18A','P1', '02', 'ECP', 'AWN', 'SATRP0118', '20260101100000', 'Production', 'SAT18A','SalesT',      '/sa_test/rp01/PGZ_ESIM_INVENTORY1_20261029_100000_1.txt' FROM DUAL UNION ALL
    SELECT 'C18B','P1', '02', 'ECP', 'AWN', 'SATRP0118', '20260101100000', 'Production', 'SAT18B','SalesT',      '/sa_test/rp01/PGZ_ESIM_INVENTORY1_20261029_101000_2.txt' FROM DUAL UNION ALL
    SELECT 'C19A','P1', '02', 'ECP', 'AWN', 'SATRP0119', '20260101100000', 'Production', 'SAT19A','SalesT',      '/sa_test/rp01/PGZ_ESIM_INVENTORY1_20261029_103000.txt'   FROM DUAL UNION ALL
    SELECT 'C19B','P1', '02', 'ECP', 'AWN', 'SATRP0119', '20260101100000', 'Production', 'SAT19B','SalesT',      '/sa_test/rp01/PGZ_ESIM_INVENTORY1_20261029_102000_3.txt' FROM DUAL UNION ALL
    SELECT 'C20A','P1', '02', 'ECP', 'AWN', 'SATRP0120', '20260101100000', 'Production', 'SAT20A','SalesT',      '/sa_test/rp01/PGZ_ESIM_INVENTORY1_20261029_100000_1.txt' FROM DUAL UNION ALL
    SELECT 'C20B','P1', '02', 'ECP', 'AWN', 'SATRP0120', '20260101100000', 'Production', 'SAT20B','SalesT',      '/sa_test/rp01/PGZ_ESIM_INVENTORY1_20261029_100000_1.txt' FROM DUAL UNION ALL
    SELECT 'C21', 'P1', '02', 'ECP', 'AWN', 'SATRP0121', '20260101100000', 'Production', 'SAT21', 'SalesT',      '/sa_test/rp01/PGZ_ESIM_INVENTORY1_20261029_100000_1.txt' FROM DUAL UNION ALL
    SELECT 'C22', 'P1', '02', 'ECP', 'AWN', 'SATRP0122', '20260101100000', 'Production', NULL,    'SalesT',      '/sa_test/rp01/PGZ_ESIM_INVENTORY1_20261029_100000_1.txt' FROM DUAL UNION ALL
    SELECT 'C23', 'P1', '01', 'ECP', 'AWN', 'SATRP0123', '20260101100000', 'Production', 'SAT23', 'SalesT',      '/sa_test/rp01/PGZ_ESIM_INVENTORY1_20261029_100000_1.txt' FROM DUAL UNION ALL
    SELECT 'C24', 'P2', '02', 'ECP', 'AWN', 'SATRP0124', '20260101100000', 'Production', 'SAT24', 'SalesT',      '/sa_test/rp01/PGZ_ESIM_INVENTORY1_20261029_100000_1.txt' FROM DUAL UNION ALL
    SELECT 'C25', 'P3', '02', 'ECP', 'AWN', 'SATRP0125', '20260101100000', 'Production', 'SAT25', 'SalesT',      '/sa_test/rp01/PGZ_ESIM_INVENTORY1_20261029_100000_1.txt' FROM DUAL UNION ALL
    SELECT 'C26', 'PF', '02', 'ECP', 'AWN', 'SATRP0126', '20260101100000', 'Production', 'SAT26', 'SalesT',      '/sa_test/rp01/PGZ_ESIM_INVENTORY1_20261029_100000_1.txt' FROM DUAL UNION ALL
    SELECT 'C27', 'PE', '02', 'ECP', 'AWN', 'SATRP0127', '20260101100000', 'Production', 'SAT27', 'SalesT',      '/sa_test/rp01/EDGE_PGZ_ESIM_INVENTORY1_20261029_090000_9.txt' FROM DUAL
  ) c
  CROSS JOIN (
    SELECT b.p1, b.p2, b.p3, b.pf, b.m,
           CASE WHEN b.hhmi < '0515'   THEN 'STOP_TIME_BEFORE_0515'
                WHEN b.m >= b.p1       THEN 'STOP_CKPT_NOT_BEFORE_P1'
                WHEN b.n_marker > 0    THEN 'STOP_MARKER_EXISTS_RUN_S7C'
                WHEN b.n_iccid > 0     THEN 'STOP_ICCID_SATRP01_EXISTS'
                WHEN b.n_status > 1    THEN 'STOP_STATUS_MULTI_ROWS'
                WHEN b.st_ok <> 'Y'    THEN 'STOP_STATUS_SUCCESS_NOT_TRUE'
                WHEN b.n_real > 0      THEN 'STOP_REAL_LANDING_AFTER_CKPT'
                ELSE 'GO' END AS go
    FROM (
      SELECT TO_CHAR(SYSDATE, 'HH24MI') AS hhmi,
             TO_NUMBER(TO_CHAR(SYSDATE - INTERVAL '310' MINUTE, 'YYYYMMDDHH24MI')) AS p1,
             TO_NUMBER(TO_CHAR(SYSDATE - INTERVAL '309' MINUTE, 'YYYYMMDDHH24MI')) AS p2,
             TO_NUMBER(TO_CHAR(SYSDATE - INTERVAL '10' MINUTE,  'YYYYMMDDHH24MI')) AS p3,
             TO_NUMBER(TO_CHAR(SYSDATE + INTERVAL '65' MINUTE,  'YYYYMMDDHH24MI')) AS pf,
             (SELECT COALESCE(MAX(checkpoint_partition), 0) FROM DSSDEV.TB_STAGING_SS_ESIM_CHECKPOINT) AS m,
             (SELECT COUNT(*) FROM DSSDEV.TB_LANDING_SS_ESIM WHERE input_source_name LIKE '/sa\_test/rp01/%' ESCAPE '\') AS n_marker,
             (SELECT COUNT(*) FROM DSSDEV.TB_TRANSACTION_SS_ESIM_VALID WHERE chk_duplicate LIKE 'SATRP01%')
             + (SELECT COUNT(*) FROM DSSDEV.TB_TRANSACTION_SS_ESIM_TEMP WHERE chk_duplicate LIKE 'SATRP01%') AS n_iccid,
             (SELECT COUNT(*) FROM DSSDEV.TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS) AS n_status,
             (SELECT CASE WHEN UPPER(COALESCE(MAX(success), 'TRUE')) = 'TRUE' THEN 'Y' ELSE 'N' END
                FROM DSSDEV.TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS) AS st_ok,
             (SELECT COUNT(*) FROM DSSDEV.TB_LANDING_SS_ESIM l
               WHERE l.partition_minute > (SELECT COALESCE(MAX(checkpoint_partition), 0) FROM DSSDEV.TB_STAGING_SS_ESIM_CHECKPOINT)
                 AND l.partition_minute <= TO_NUMBER(TO_CHAR(SYSDATE + INTERVAL '70' MINUTE, 'YYYYMMDDHH24MI'))
                 AND (l.input_source_name IS NULL OR l.input_source_name NOT LIKE '/sa\_test/%' ESCAPE '\')) AS n_real
      FROM DUAL
    ) b
  ) g
) x
WHERE x.go = 'GO'
  AND (x.ptn <> 'PE' OR x.m > 0);

-- C21 (cross-run DUP): แถว "เคยลงแล้วรอบก่อน" ใน TB_TRANSACTION_SS_ESIM_TEMP ด้วย chk_duplicate เดียวกัน
-- workflow_process_date = '19000101000000' เพื่อไม่ชน guard chk_dup_append ของ 050300 · ใส่เฉพาะเมื่อ seed landing สำเร็จ
INSERT INTO DSSDEV.TB_TRANSACTION_SS_ESIM_TEMP
  (PARTITION_DATE, CDR_ID, CDR_TYPE, PARTNER, OWNER, ICCID, FIRST_INSTALLED, PROFILE_TYPE, EID, SIM_TYPE,
   CDR_FILENAME, CHK_DUPLICATE, FILTER_DTM, CREATE_BY, PROCESS_DATE, STATUS, B_NO, WORKFLOW_PROCESS_DATE)
SELECT 20260101, 'SATRP01PRESEED', '1', 'ECP', 'AWN', 'SATRP0121', TIMESTAMP '2026-01-01 10:00:00', 'Production', NULL, 'Step',
       '/sa_test/rp01/PRESEED_cross_run_dup.txt', 'SATRP0121', CAST(SYSDATE AS TIMESTAMP), USER, CAST(SYSDATE AS TIMESTAMP),
       'UNMAP', 'ECP_ESIM_Step', '19000101000000'
FROM DUAL
WHERE EXISTS (SELECT 1 FROM DSSDEV.TB_LANDING_SS_ESIM
               WHERE input_source_name LIKE '/sa\_test/rp01/%' ESCAPE '\' AND eid = 'SAT21')
  AND NOT EXISTS (SELECT 1 FROM DSSDEV.TB_TRANSACTION_SS_ESIM_TEMP
                   WHERE cdr_filename = '/sa_test/rp01/PRESEED_cross_run_dup.txt');

COMMIT;

-- ตรวจทันที: SEED_VERDICT ต้องขึ้นต้นด้วย OK (29 แถวเมื่อ checkpoint ว่าง / 30 แถวเมื่อมี checkpoint เดิม + preseed 1)
SELECT CASE WHEN s.n_land = s.exp_land AND s.n_pre = 1
            THEN 'OK - run PKG_SS_ESIM_L2D before ' || s.deadline
            ELSE 'STOP - seed blocked or partial, run D1_diagnose.sql' END AS SEED_VERDICT,
       s.n_land AS LANDING_ROWS_SEEDED, s.exp_land AS LANDING_ROWS_EXPECTED, s.n_pre AS PRESEED_TEMP_ROWS,
       s.p1 AS P1, s.p2 AS P2, s.p3 AS P3_DEFERRED, s.pf AS PF_FUTURE, s.pe AS PE_EDGE_EQ_CKPT,
       s.m AS CKPT_MAX_BEFORE_RUN, s.deadline AS RUN_DEADLINE
FROM (
  SELECT (SELECT COUNT(*) FROM DSSDEV.TB_LANDING_SS_ESIM WHERE input_source_name LIKE '/sa\_test/rp01/%' ESCAPE '\') AS n_land,
         (SELECT CASE WHEN COALESCE(MAX(checkpoint_partition), 0) > 0 THEN 30 ELSE 29 END FROM DSSDEV.TB_STAGING_SS_ESIM_CHECKPOINT) AS exp_land,
         (SELECT COUNT(*) FROM DSSDEV.TB_TRANSACTION_SS_ESIM_TEMP WHERE cdr_filename = '/sa_test/rp01/PRESEED_cross_run_dup.txt') AS n_pre,
         (SELECT MAX(partition_minute) FROM DSSDEV.TB_LANDING_SS_ESIM WHERE input_source_name LIKE '/sa\_test/rp01/%' ESCAPE '\' AND eid = 'SAT01') AS p1,
         (SELECT MAX(partition_minute) FROM DSSDEV.TB_LANDING_SS_ESIM WHERE input_source_name LIKE '/sa\_test/rp01/%' ESCAPE '\' AND eid = 'SAT24') AS p2,
         (SELECT MAX(partition_minute) FROM DSSDEV.TB_LANDING_SS_ESIM WHERE input_source_name LIKE '/sa\_test/rp01/%' ESCAPE '\' AND eid = 'SAT25') AS p3,
         (SELECT MAX(partition_minute) FROM DSSDEV.TB_LANDING_SS_ESIM WHERE input_source_name LIKE '/sa\_test/rp01/%' ESCAPE '\' AND eid = 'SAT26') AS pf,
         (SELECT MAX(partition_minute) FROM DSSDEV.TB_LANDING_SS_ESIM WHERE input_source_name LIKE '/sa\_test/rp01/%' ESCAPE '\' AND eid = 'SAT27') AS pe,
         (SELECT COALESCE(MAX(checkpoint_partition), 0) FROM DSSDEV.TB_STAGING_SS_ESIM_CHECKPOINT) AS m,
         (SELECT TO_CHAR(MIN(process_date) + INTERVAL '60' MINUTE, 'YYYY-MM-DD HH24:MI')
            FROM DSSDEV.TB_LANDING_SS_ESIM WHERE input_source_name LIKE '/sa\_test/rp01/%' ESCAPE '\') AS deadline
  FROM DUAL
) s;
