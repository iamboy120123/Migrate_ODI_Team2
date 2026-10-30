-- ============================================================
-- S7c_cleanup_DEV.sql  (rp01_20261029 / SS_ESIM_L2D)  -- Oracle DEV เท่านั้น, user DSSDEV
-- หลาย statement -> รันด้วย **Execute Script (Alt+X)** ครั้งเดียว แล้วดูผล SELECT สุดท้าย (ทุกช่อง *_LEFT ต้องเป็น 0)
-- รัน "หลัง" export ผล S7b_assertions.sql แล้วเท่านั้น (ลบแล้วตรวจย้อนไม่ได้)
-- ยังไม่ได้ทดสอบกับ DBeaver ของผู้ใช้
--
-- ลบเฉพาะแถว marker '/sa_test/rp01/%' :
--   1) checkpoint / checkpoint_temp: แถวที่ checkpoint_partition = partition ของแถว marker (P1, P2)
--      และ > partition ของแถว EDGE (= MAX checkpoint เดิม) -> MAX checkpoint กลับเป็นค่าเดิมก่อนรัน
--      (ต้องลบก่อน landing เพราะใช้ landing marker เป็นตัวอ้าง)
--   2) valid / temp (รวม PRESEED) / reject / raw_temp: cdr_filename marker
--   3) landing: input_source_name marker
--
-- สิ่งที่ cleanup นี้ "คืนค่าไม่ได้" (บันทึกไว้ให้ SA ทราบ):
--   - 070000 ลบแถว checkpoint ที่ partition_date = วันที่รันทั้งหมดก่อน insert ใหม่ -> แถวเดิมของวันนั้นที่ค่า < MAX เดิมหายไป
--     (MAX เดิมยังอยู่ เพราะแถว EDGE ทำให้ค่านั้นถูกเขียนกลับ) -- ดูจำนวนที่ D1 ITEM 7 ก่อนรัน
--   - 070000 คัดลอก checkpoint_temp ของวันอื่นที่ค้างอยู่กลับเข้า checkpoint (เขียนทับ partition_date เหล่านั้น)
--   - ถ้ามี checkpoint เดิม: P3 ถูกแทนด้วย MIN = ค่าเดิม (M) -> เกิดแถว M ซ้ำ 1 แถวใน checkpoint / checkpoint_temp (ไม่กระทบ MAX)
--   - status table ถูก 030000/090000 เขียนทับ -> ค้างเป็น running NULL / success 'TRUE' / workflow_process_date NULL
--     (สถานะปกติหลังรอบสำเร็จ) ค่าเดิมก่อนรันดูได้จาก D1 ITEM 11
--   - status_temp (010000) ถูก TRUNCATE + INSERT ค่า success ก่อนรัน
--   - raw_temp: 080000 ลบทั้งตาราง (รวมแถวที่ไม่ใช่ marker ถ้ามี) -- ดู D1 ITEM 18
-- ============================================================

DELETE FROM DSSDEV.TB_STAGING_SS_ESIM_CHECKPOINT k
WHERE k.checkpoint_partition IN (
        SELECT l.partition_minute FROM DSSDEV.TB_LANDING_SS_ESIM l
        WHERE l.input_source_name LIKE '/sa\_test/rp01/%' ESCAPE '\'
          AND l.input_source_name NOT LIKE '/sa\_test/rp01/EDGE\_%' ESCAPE '\')
  AND k.checkpoint_partition > COALESCE((
        SELECT MAX(e.partition_minute) FROM DSSDEV.TB_LANDING_SS_ESIM e
        WHERE e.input_source_name LIKE '/sa\_test/rp01/EDGE\_%' ESCAPE '\'), -1);

DELETE FROM DSSDEV.TB_STAGING_SS_ESIM_CHECKPOINT_TEMP k
WHERE k.checkpoint_partition IN (
        SELECT l.partition_minute FROM DSSDEV.TB_LANDING_SS_ESIM l
        WHERE l.input_source_name LIKE '/sa\_test/rp01/%' ESCAPE '\'
          AND l.input_source_name NOT LIKE '/sa\_test/rp01/EDGE\_%' ESCAPE '\')
  AND k.checkpoint_partition > COALESCE((
        SELECT MAX(e.partition_minute) FROM DSSDEV.TB_LANDING_SS_ESIM e
        WHERE e.input_source_name LIKE '/sa\_test/rp01/EDGE\_%' ESCAPE '\'), -1);

DELETE FROM DSSDEV.TB_TRANSACTION_SS_ESIM_VALID  WHERE cdr_filename LIKE '/sa\_test/rp01/%' ESCAPE '\';

DELETE FROM DSSDEV.TB_TRANSACTION_SS_ESIM_TEMP   WHERE cdr_filename LIKE '/sa\_test/rp01/%' ESCAPE '\';

DELETE FROM DSSDEV.TB_TRANSACTION_SS_ESIM_REJECT WHERE cdr_filename LIKE '/sa\_test/rp01/%' ESCAPE '\';

DELETE FROM DSSDEV.TB_STAGING_SS_ESIM_RAW_TEMP   WHERE cdr_filename LIKE '/sa\_test/rp01/%' ESCAPE '\';

DELETE FROM DSSDEV.TB_LANDING_SS_ESIM            WHERE input_source_name LIKE '/sa\_test/rp01/%' ESCAPE '\';

COMMIT;

-- ตรวจ: *_LEFT ต้องเป็น 0 ทุกช่อง · CKPT_MAX_NOW ต้องเท่ากับ CKPT_MAX = M ใน D1 (ITEM 4) ก่อน seed
SELECT (SELECT COUNT(*) FROM DSSDEV.TB_LANDING_SS_ESIM            WHERE input_source_name LIKE '/sa\_test/rp01/%' ESCAPE '\') AS LANDING_LEFT,
       (SELECT COUNT(*) FROM DSSDEV.TB_STAGING_SS_ESIM_RAW_TEMP   WHERE cdr_filename LIKE '/sa\_test/rp01/%' ESCAPE '\') AS RAW_TEMP_LEFT,
       (SELECT COUNT(*) FROM DSSDEV.TB_TRANSACTION_SS_ESIM_VALID  WHERE cdr_filename LIKE '/sa\_test/rp01/%' ESCAPE '\') AS VALID_LEFT,
       (SELECT COUNT(*) FROM DSSDEV.TB_TRANSACTION_SS_ESIM_TEMP   WHERE cdr_filename LIKE '/sa\_test/rp01/%' ESCAPE '\') AS TEMP_LEFT,
       (SELECT COUNT(*) FROM DSSDEV.TB_TRANSACTION_SS_ESIM_REJECT WHERE cdr_filename LIKE '/sa\_test/rp01/%' ESCAPE '\') AS REJECT_LEFT,
       (SELECT COALESCE(MAX(checkpoint_partition), 0) FROM DSSDEV.TB_STAGING_SS_ESIM_CHECKPOINT) AS CKPT_MAX_NOW,
       (SELECT NVL(MAX(NVL(running, 'NULL') || '|' || NVL(success, 'NULL')), 'NO ROW')
          FROM DSSDEV.TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS) AS STATUS_RUNNING_SUCCESS
FROM DUAL;
