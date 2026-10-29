# Run Pack rp00_preflight_20261029 — Pre-flight (Phase 0 / G0)

Generated: 2026-10-29T17:27:17 · `python scripts/runpack/gen_preflight_pack.py` · work user `DSSDEV` · source object 11 ตัว (จาก raw SQL)

ทุกไฟล์ Oracle เป็น **SELECT เดียว** → Ctrl+Enter ได้ · export CSV (มี header) ลง `{res_dir.as_posix()}/` ชื่ออะไรก็ได้ · P5 รันใน Blendata (ไม่ใช่ Oracle)

| # | ที่รัน | ไฟล์ | ใช้ยืนยัน | ผลที่คาด |
|---|---|---|---|---|
| P1 | Oracle Dev | `P1_oracle_env.sql` | PREFLIGHT 2 (login = work user) · NLS/timezone → `knowledge/environment-facts.md` · Q5 schedule/timezone | DB 19.x · IS_WORK_USER = YES |
| P2 | Oracle Dev | `P2_oracle_privileges.sql` | PREFLIGHT 5 (สิทธิ์) · G6.M4 | CREATE TABLE / CREATE PROCEDURE / quota |
| P3 | Oracle Dev | `P3_source_columns.sql` | PREFLIGHT 3 · **Q4 data contract** · lessons L1 (ชนิดจริงของ landing ก่อนแปลง SQL) | ไม่มีแถว MISSING_OBJECT |
| P4 | Oracle Dev | `P4_work_repo_schema.sql` | **Q7 work repository** · `config.odi.work_repo_schema` (ปัจจุบัน `DSSDEV`) | owner ไม่ใช่ SYSTEM |
| P5 | Blendata | `P5_blendata_spark_conf.sql` | **Q3 Spark config** · lessons L7–L9 | ค่าของทุก key |

## หลังรันเสร็จ

1. วางผลทั้งหมดใน `input/run_results/rp00_preflight_20261029/`
2. ใน Claude Code พิมพ์ `/preflight` อีกครั้ง — agent จะอ่านผล สรุปข้อที่ผ่าน/ไม่ผ่าน และบันทึกข้อเท็จจริงใน `knowledge/environment-facts.md`
3. SA ติ๊ก ✅ ใน `status/PREFLIGHT_CHECKLIST.md` และตอบ Q3 / Q4 / Q7 ใน `status/OPEN_DECISIONS.md` เอง (agent ติ๊กแทนไม่ได้)
