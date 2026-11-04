# VERIFY REPORT — ss_esim_landing_to_discovery

Generated: 2026-11-04 09:38:09 · `python scripts/checks/verify_all.py`

## ✅ V1 Static

- ✅ py_compile scripts/ ผ่านทุกไฟล์
- ✅ กฎ ODI step บน converted SQL 10 ไฟล์

## ✅ V2 Build

- ✅ PROJ_EXPORT.xml ใหม่กว่าไฟล์ต้นทางทั้งหมด
- ✅ validate_odi_xml --source-check: error 0 warn 0
- ✅ SQL ใน XML ตรงกับ DML ครบ 17 step
- ℹ️ Studio: ยังไม่มี Smart Export ที่ใหม่กว่า PROJ_EXPORT.xml ใน input/odi_reference/ (ต้องมีหลัง import — G4)

## ✅ V3 Portability

- ✅ schema `DSSDEV.` hardcode 0 จุด ใน 0 ไฟล์

## ⚠️ V4 State consistency

- ✅ MIGRATION_STATUS rev.18 (2026-11-03)
- ℹ️ OPEN_DECISIONS: 15 ข้อ · ยังเปิด 6 (Q1, Q3, Q4, Q5, Q6, Q14)
- ⚠️ Q1 (Landing retention): ตัวเลือกที่ติ๊กคือยังไม่ทราบ/ยังขอไม่ได้ → ยังนับว่าเปิด
- ⚠️ Q3 (Spark config ของ Blendata (มีผ): ตัวเลือกที่ติ๊กคือยังไม่ทราบ/ยังขอไม่ได้ → ยังนับว่าเปิด
- ⚠️ Q4 (Data contract ของ landing `tb_): ติ๊กแล้วแต่ยังไม่กรอกค่า 1 บรรทัด (เช่น `- ผู้เติม landing ใน Prod: ____`) → ยังนับว่าเปิด
- ⚠️ Q5 (Schedule และ timezone): ติ๊กแล้วแต่ยังไม่กรอกค่า 1 บรรทัด (เช่น `- cron เดิมของ DAG: ____ · timezone ของ DAG: ____ · `SELECT `) → ยังนับว่าเปิด
- ⚠️ Q6 (แจ้งเตือนและ recovery): ติ๊กแล้วแต่ยังไม่กรอกค่า 1 บรรทัด (เช่น `- ช่องทาง / SMTP: ____ · ผู้รับ WARNING: ____ · ผู้รับ CRITI`) → ยังนับว่าเปิด
- ✅ PREFLIGHT 5/5
- ℹ️ ADR 3 ฉบับ · Proposed 0
- ⚠️ REVIEW_FLAGS PENDING 19 (waiver W3)
- ⚠️ PHASE4_REVIEW_LOG ยังมีรายการ OPEN: task_6451c19231b14139ab3d99b35ac9c734_020000_overwrite_ss_esim_checkpoint_temp, task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp (waiver W2)

## ✅ V5 Runtime

- ℹ️ Run Pack ล่าสุด: rp_g4_diag
- ℹ️ ยังไม่มี REPORT.md (pack รอคนรัน)
- ℹ️ assertions ล่าสุดมาจาก rp01_20261029
- ✅ assertions PASS 55/55

## ⚠️ V6 Schema / data contract

- ✅ DDL fallback VARCHAR2(4000) 0 คอลัมน์
- ✅ target ใน DML มีใน DDL ครบ 8 ตาราง
- ⚠️ DDL เก่ากว่า DML manifest — รัน gen_ddl.py ใหม่
- ℹ️ ยังไม่มีผล all_tab_columns ของ landing/source ใน input/run_results/ (/preflight → P3)

## ⚠️ V7 Run Pack hygiene

- ✅ Run Pack 6 ชุด 35 สคริปต์ + SQL ใน output/dba|backfill|ddl|validation: ไม่มี SET/SPOOL/EXEC/'/'
- ⚠️ rp_compile: ไม่มี README.md
- ⚠️ rp_g4_diag: ไม่มี README.md
- ⚠️ rp_g4_diag/D1_var_name_conflict.sql: 3 statement แต่ README ไม่บอก Execute Script (Alt+X)
- ⚠️ rp_import_check: ไม่มี README.md

## ⚠️ V8 Traceability

- ✅ traceability 12 task — output/verify/TRACEABILITY.md
- ⚠️ spec ยังไม่เติม 11 task (/design): 010000_check_success_ss_esim_landing_to_discovery_workflow_status, 020000_overwrite_ss_esim_checkpoint_temp, 030000_running_ss_esim_landing_to_discovery_workflow_status, 040000_overwrite_ss_esim_raw_temp, 050100_append_ss_esim_valid

## ✅ V9 Release readiness

- ℹ️ backfill pack: ยังไม่มี output/backfill/00_README.md (/cutover)
- ℹ️ status/CUTOVER_RUNBOOK.md: ยังไม่มี (/cutover → cutover-planner)
- ℹ️ validation: ยังไม่มี output/validation/ (/validation)

## ✅ V12 Hook self-test

- ✅ hook self-test 57 เคส ผ่านทั้งหมด
