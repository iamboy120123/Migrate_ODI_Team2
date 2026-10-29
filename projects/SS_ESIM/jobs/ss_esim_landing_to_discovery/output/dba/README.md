# Phase 6 — DBA Prerequisites (SS_ESIM_L2D)

Generated: 2026-10-29T20:57:56 | target tables: 8

## ลำดับการรัน

1. สร้าง/ยืนยัน target table ทั้งหมดจาก `output/ddl/01_create_tables.sql` (DRAFT — ยืนยันความยาวคอลัมน์กับ `output/ddl/03_profile_source_lengths.sql` ก่อนรัน CREATE TABLE จริง)
2. `01_create_error_log_tables.sql` — ใช้เฉพาะเมื่อ error_handling = errlog
3. `02_preflight_checks.sql` — ต้องผ่านทุก check ก่อนรัน package
4. **Smart Import** `output/odi_export/<package>.zip` เข้า ODI **Dev** (ทำครั้งเดียว หลังข้อ 1–3 เสร็จ; ไม่ใช่ Import Project)
5. รัน package ใน Dev 1 รอบ แล้วไป Phase 7 (`output/validation/`)

## Target tables

error_handling = `fail-fast` → ไม่มี error log table (DML ไม่มี `LOG ERRORS`)

| Target |
|---|
| `DSSDEV.TB_TRANSACTION_SS_ESIM_REJECT` |
| `DSSDEV.TB_TRANSACTION_SS_ESIM_TEMP` |
| `DSSDEV.TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS` |
| `DSSDEV.TB_STAGING_SS_ESIM_CHECKPOINT_TEMP` |
| `DSSDEV.TB_STAGING_SS_ESIM_CHECKPOINT` |
| `DSSDEV.TB_STAGING_SS_ESIM_RAW_TEMP` |
| `DSSDEV.TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS_TEMP` |
| `DSSDEV.TB_TRANSACTION_SS_ESIM_VALID` |

## ⚠️ ต้องยืนยันก่อนรัน

- **TRUNCATE**: 3 procedure ใช้ `TRUNCATE TABLE` ซึ่งเป็น DDL (010000, 030000, 090000) — ODI work user ต้องเป็น owner
  ของตาราง หรือมี `DROP ANY TABLE` ถ้าให้ไม่ได้ ต้องเปลี่ยนเป็น `DELETE` (ช้ากว่าและกิน UNDO)
- **data type ของคอลัมน์ boolean** (`success`, `running`): converted SQL ส่งค่า string `'TRUE'`
  DDL เป็น `VARCHAR2(5)` (D2-revised — ดู status/PHASE4_REVIEW_LOG.md)
- **`cdr_id` ต้องเป็น VARCHAR2** (050300 append มี keyColumns=cdr_id ใน Blendata แต่ไม่ได้ใช้เป็น merge key)
- **`effective_date` / `expired_date` ต้องเป็น DATE/TIMESTAMP** (converted SQL ใช้ `TRUNC()`)
- **partition**: source เป็น Spark partitioned by `partition_date` — ถ้า target ทำ partition ด้วย
  ให้พิจารณา `TRUNCATE PARTITION` แทน `TRUNCATE TABLE`
- **Non-SQL tasks** (080000/000000; 999999 นอก scope ตาม config.scope): ดูสถานะและ design เต็มที่ `output/odi_export/NON_SQL_TASKS_DESIGN.md`

## External source objects (4) — kit ไม่ได้สร้างให้

| Object | ใช้ใน task | schema prefix ใน SQL |
|---|---|---|
| `EXT_DSS_CHECKPOINT_TB_TRANSACTION_SS_ESIM_VALID` | 999999 | มี |
| `EXT_DSS_TB_MASTER_CDR_TYPE` | 040000 | มี |
| `EXT_DSS_VW_SERVICE_MAPPING_BNO_KEY` | 040000 | มี |
| `TB_LANDING_SS_ESIM` | 020000, 040000 | มี |

## ⚠️ ความยาวชื่อ object

- TB_STAGING_SS_ESIM_CHECKPOINT_TEMP (34 ตัวอักษร) เกิน 30 - ใช้ได้เฉพาะเมื่อ COMPATIBLE >= 12.2
- TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS (55 ตัวอักษร) เกิน 30 - ใช้ได้เฉพาะเมื่อ COMPATIBLE >= 12.2
- TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS_TEMP (60 ตัวอักษร) เกิน 30 - ใช้ได้เฉพาะเมื่อ COMPATIBLE >= 12.2
