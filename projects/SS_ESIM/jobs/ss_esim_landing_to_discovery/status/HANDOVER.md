# HANDOVER — ss_esim_landing_to_discovery (SS_ESIM_L2D) · R01

อัปเดต 2026-10-30 · owner `iamboy120123` · branch `job/SS_ESIM/ss_esim_landing_to_discovery/R01` · สถานะเต็ม `status/MIGRATION_STATUS.md` rev.15

## ทำไปแล้ว (ตาม `knowledge/WORKFLOW.md`)

| ขั้น | ผล |
|---|---|
| 03.1 preflight · G0 | ✅ PASS (PREFLIGHT 5/5) |
| 03.2 แปลง SQL · G1 | ✅ PASS — 12 task (SQL 9 · 999999 export → placeholder Q9 · 080000 cleanup → DELETE Q10 · 000000 → variable `v_max_partition`) |
| 03.3 รีวิว · G2 | 🟡 WAIVED (W1–W3: 5 ประเด็นที่ต้องใช้ข้อมูล Blendata) · `PHASE4_REVIEW_LOG` · `SQL_REVIEW` ✅ 5 · 🟡 5 · ⛔ 0 · คอมไพล์บน DEV 10/10 |
| 04 แพ็กเกจ · G3 | ✅ PASS — `output/odi_export/PKG_SS_ESIM_L2D.zip` (2 variable · 11 procedure · 13 step) เกรด B (`output/verify/grade.json`) |
| 05.2 Smart Import | ✅ เข้า DEV 2026-10-29 20:42 · Test Connection `DSS_ODI` ผ่าน · scenario `PKG_SS_ESIM_L2D` 001 generate แล้ว · G4 ยัง BLOCKED (ยังไม่มี Smart Export หลัง import — ไม่บังคับก่อนเทส) |
| Phase 6 DDL | `output/ddl/` + `output/dba/` (ชนิดจริงจาก DEV · fallback 0) — ตารางมีอยู่แล้วใน DEV **ห้ามรัน `01_create_tables.sql` บน DEV** |
| 05.3 ทดสอบ | ✅ `run_packs/rp01_20261029`: scenario session 301 สำเร็จ 13/13 · assertions **55/55 PASS** · cleanup ครบ · G5 auto ผ่าน / manual M1–M3 ค้าง |

แก้ kit ในงานนี้ (ต้อง `/kit-backport`): **K14** (ตัวตรวจ 4 ตัวรับ waiver G2) · **K15** (builder `seq` ใน dml manifest) · **K16** (`review_report` ชื่อ `task_<hex>` + odiRef ใน compile pack) · **K17** (`gen_ddl` อ่าน `input/oracle_ddl` + index เฉพาะ MERGE · `gen_dba_prereq` นับ TRUNCATE / external) — รายละเอียด `MIGRATION_STATUS.md` §6 · backup `*.bak-20261029`

## ขั้นถัดไป (1 ข้อ)

**ได้ผล P5 + P5b จาก Blendata** — ใครก็ได้ที่เข้า Blendata ได้ รัน `run_packs/rp00_preflight_20261029/P5_blendata_spark_conf.sql` และ `P5b_blendata_d1_checks.sql` แล้ววางผลที่ `input/run_results/rp00_preflight_20261029/` → `/read-results` → ปิด Q3 / waiver W1–W3 / G5.M1

## ⏳ รอใคร

| เรื่อง | รอ | ก่อน |
|---|---|---|
| Q3 Spark config + D1 (P5/P5b) — ปิด W1–W3, G5.M1–M3 | ทีม Blendata | G5 |
| Q14 ความยาวคอลัมน์ปลายทาง 4 จุด | DBA / Blendata | G6 |
| Q1 retention · Q4 ผู้เติม landing Prod · Q5 timezone · Q6 SMTP / ผู้รับ · Q7 work repo Prod / grant SNP_* · Q9 export SQL Server · Q10 `olderThan: -1` | SA / ทีมที่เกี่ยวข้อง | G4–G7 (ดู `OPEN_DECISIONS.md`) |
| ของเสริมหลังรอบพื้นฐาน ทีละอย่าง: Evaluate `v_lag_minutes` (Q2, ต้องมี sample จาก Studio) → OdiSendMail (Q6) → retry 2 × 60s (Q11, ต้องมี sample `KoRetry`) | SA + agent | G4 |
| G4.M1–M2 Smart Export จาก Studio หลัง import → `/sync-guid` | SA | G4 |

## รายการตาราง (table inventory · DSSDEV บน DEV)

ตารางทั้งหมด **มีอยู่แล้ว** ก่อนงานนี้ (ไม่ได้สร้างใหม่ · DDL อ้างอิงใน `output/ddl/01_create_tables.sql`) · ไม่มี error log table (fail-fast)

| ตาราง | งานนี้เขียน | ข้อมูลทดสอบค้าง |
|---|---|---|
| `TB_LANDING_SS_ESIM` | rp01 seed (S7a) | ไม่ค้าง — S7c `LANDING_LEFT = 0` |
| `TB_STAGING_SS_ESIM_CHECKPOINT_TEMP` / `_CHECKPOINT` | 020000 / 070000 | ไม่ค้าง (MAX กลับเป็น 202610120900) · แถว partition_date วันที่ 29 ต.ค. 1 แถวถูก 070000 ลบ คืนไม่ได้ |
| `TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS` / `_TEMP` | 010000 / 030000 / 090000 | status = `NULL | TRUE` (guard ของ 020000 ผ่าน) |
| `TB_STAGING_SS_ESIM_RAW_TEMP` | 040000 / 080000 | ว่าง |
| `TB_TRANSACTION_SS_ESIM_VALID` / `_REJECT` / `_TEMP` | 050100 / 050200 / 050300 (+ seed DUP ใน TEMP) | ไม่ค้าง — marker `/sa_test/rp01/` = 0 |

cleanup รอบหน้า: `run_packs/rp01_20261029/S7c_cleanup_DEV.sql` (Alt+X) ลบเฉพาะ marker `/sa_test/rp01/`

## เส้นตาย / สมมติฐาน / ข้อควรรู้

- ไม่มีล็อก import ค้าง (ผู้ใช้แจ้งว่า unlock แล้ว) แต่ **`status/IMPORT_LOG.md` ยังไม่มีแถว** — ตรวจด้วย `python tools/workspace.py status` ที่ root
- expected ของ rp01 มาจากการตีความ Spark SQL ไม่ใช่การรัน Spark (L37) — 55/55 PASS ≠ parity กับ Blendata
- สมมติฐาน: `escapedStringLiterals=false` · วันที่ผิดรูปได้ NULL · timezone ของ `now()` = DB (W1) · `ext_dss_checkpoint_tb_transaction_ss_esim_valid` มีใน DEV (คอมไพล์ผ่าน) แต่ไม่อยู่ใน DDL CSV — น่าจะเป็น view / synonym
- ห้ามรัน `convert_sql.py` ซ้ำ (เขียนทับ converted ที่แก้มือ — อยู่ใน git แล้ว)
- AI รัน SQL ได้เฉพาะเมื่อตั้ง `ORA_RO_PASSWORD` / `ORA_RW_PASSWORD` บนเครื่อง · ไม่มี = ใช้ DBeaver + `--record-human` (L40)
- ไฟล์ผลใน `input/run_results/` ไม่ขึ้น git (.gitignore) — อยู่บนเครื่องของ owner
- บทเรียนที่บันทึกแล้ว: L39–L42 · ยังไม่บันทึก: ไม่มี
