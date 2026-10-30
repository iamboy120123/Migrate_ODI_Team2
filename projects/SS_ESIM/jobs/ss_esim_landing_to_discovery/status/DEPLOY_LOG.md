# DEPLOY_LOG — สิ่งที่คนทำในระบบจริง (DDL · ตั้งค่า · scenario)

> AI บันทึกแถวนี้เมื่อคนบอกว่าทำเสร็จ **พร้อมหลักฐาน** เท่านั้น (เช่น ผล SELECT ที่ยืนยันว่าตารางมีแล้ว) · ไม่มีหลักฐาน = ยังไม่ใส่แถว
> `/status` นับขั้น 05.1 ว่าเสร็จจากแถว `DDL` ที่มีวันที่และหลักฐานครบ

| รายการ | วันที่ | หลักฐาน | โดย | หมายเหตุ |
|---|---|---|---|---|
| DML run_packs/rp01_20261029/S7a_seed_DEV.sql | 2026-10-29 | คนรันใน DBeaver (Alt+X) 2026-10-29 21:29: SEED_VERDICT OK · landing 30/30 · preseed temp 1 · RUN_DEADLINE 2026-10-29 22:28 (input/run_results/rp01_20261029/S7a.csv) · status/DB_RUN_LOG.md | คนรันเอง | ฐาน DEV |
| DML run_packs/rp01_20261029/S7c_cleanup_DEV.sql | 2026-10-30 | คนรันใน DBeaver (Alt+X) 2026-10-30: *_LEFT = 0 ทุกตาราง · CKPT_MAX_NOW 202610120900 (เท่าก่อน seed) · status NULL/TRUE (input/run_results/rp01_20261029/S7c.csv) · status/DB_RUN_LOG.md | คนรันเอง | ฐาน DEV |
| DDL output/ddl/01_create_tables.sql (ไม่ได้รันบน DEV — ตารางมีอยู่แล้ว) | 2026-10-30 | ตาราง 8 ใบมีใน DSSDEV: `input/oracle_ddl/_shared_all_tab_columns.csv` (owner DSSDEV, ดึง 2026-10-28) ตรงกับ DDL 112 คอลัมน์ (V6 PASS) · คอมไพล์ DEV 10/10 (`output/verify/sql_compile.txt`) · rp01 scenario session 301 เขียนครบทุกตาราง + assertions 55/55 PASS · ห้ามรันบน DEV (ORA-00955) | agent (จากหลักฐานที่คนรัน) | ฐาน DEV · DDL ใช้กับ env ใหม่ (SIT/PROD) หลังปิด Q14 |
