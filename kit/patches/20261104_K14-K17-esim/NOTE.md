# K14–K17 (SS_ESIM) — การแก้ kit จากงาน ss_esim_landing_to_discovery

- จากงาน: projects/SS_ESIM/jobs/ss_esim_landing_to_discovery
- วันที่ promote: 2026-11-04 · โดย: iamboy120123
- บทเรียนที่เกี่ยวข้อง: L41 (สคริปต์สมมติชื่อไฟล์ `<code>_name.sql` / schema hardcode) · L42 (waiver อ่านไม่ครบทุกตัวตรวจ)
- ไฟล์: check_inputs.py · review_report.py · verify_all.py · build_odi_export.py · gen_dba_prereq.py · gen_ddl.py · gen_design_docs.py

## รายละเอียด (จาก status/MIGRATION_STATUS.md §6 ของงาน)

| K# | ไฟล์ | การแก้ |
|---|---|---|
| K17 | `scripts/pipeline/gen_ddl.py` (backup `.bak-20261029`) | 2026-10-29 bug fix: `load_existing_columns` อ่านแค่ `input/run_results/*/*.csv` ไม่อ่าน `input/oracle_ddl/*.csv` (all_tab_columns ที่ใช้ตอน preflight) → fallback VARCHAR2(4000) 56 คอลัมน์ · แก้ให้อ่านทั้งสองที่ → existing 112 · fallback 0 · V6 PASS · (2) `gen_ddl.py` unique index เฉพาะ strategy merge (050300 append ไม่ได้ UX_ บน CDR_ID แล้ว) · (3) `gen_dba_prereq.py` (backup `.bak-20261029`): นับ TRUNCATE ตรง ๆ (0 → 3: 010000/030000/090000) + แทน odiRef ก่อนหา external object (0 → 4) · ผลจาก ddl-dba-reviewer · generic → `/kit-backport` |
| K15b | `scripts/pipeline/gen_design_docs.py` (backup `.bak-20261030`) | 2026-10-30: ใช้ช่อง `seq` ใน dml manifest แบบเดียวกับ builder (K15) → `.design/03_package_flow.md` เรียง 999999 ก่อน 090000 ตรงกับ package |
| K16 | `scripts/checks/review_report.py` (backup `.bak-20261029`) | 2026-10-29 bug fix: ชื่อไฟล์แบบ `task_<hex>_<code>_…` ทำให้ `split('_')[0]` = `task` ทุกไฟล์ → flag/review ของ 040000/020000 ไปนับให้ทุก task และชั้น ⑤ หา procedure ใน XML ไม่เจอ (ชื่อใน XML ตัด `task_<hex>_` ออก) · แก้ให้ใช้ `task_<hex>` และชื่อ procedure · ผล: ⛔ 10 → ✅ 5 · 🟡 3 · ⛔ 2 · `--make-compile-pack` แทน `<%=odiRef.getSchemaName(...)%>` ด้วย `odi.work_user` (DSSDEV) ไม่งั้นคอมไพล์นอก ODI ไม่ได้ · generic → `/kit-backport` |
| K15 | `scripts/pipeline/build_odi_export.py` (backup `.bak-20261029`) | 2026-10-29 (SA อนุมัติในแชต): `seq_key` ใช้ช่อง `seq` (int) ใน `output/dml/_manifest.json` ถ้ามี แทนเลขหน้าชื่อ task · ตั้ง 999999 `seq = 85000` (หลัง 080000 ก่อน 090000 ตาม DAG) · generic → `/kit-backport` |
| K14 | `scripts/checks/check_inputs.py` (backup `.bak-20261029`) | 2026-10-29 (SA อนุมัติในแชต): (1) ข้าม DDL ของ task `kind=export_jdbc` (gen_dml SKIP → placeholder, Q9) · (2) REVIEW_FLAGS PENDING ไม่บล็อกเมื่อมี waiver G2 `REVIEW_FLAGS PENDING` ที่ open (ตรงกับ check_gate K11) → แสดงเป็นคำเตือน · (4) `scripts/checks/verify_all.py` V4 (backup `.bak-20261029`): REVIEW_FLAGS PENDING / PHASE4_REVIEW_LOG OPEN → WARN เมื่อมี waiver G2 ที่ open ครอบ (SA อนุมัติในแชต 2026-10-29) · (5) `scripts/checks/review_report.py` ชั้น ①–③: flag PENDING / review OPEN ใต้ waiver G2 ที่ open → 🟡 (ระบุ Wn) แทน ⛔ (SA อนุมัติในแชต 2026-10-29) · (3) `scripts/pipeline/build_odi_export.py` (backup `.bak-20261029`) ด่าน REVIEW_FLAGS PENDING → `[WARN]` เมื่อมี waiver เดียวกัน (SA อนุมัติในแชต 2026-10-29) · ⚠️ waiver ครอบ PENDING ทั้งหมดของ G2 — flag ใหม่นอก W1 จะไม่ถูก builder หยุด · generic → `/kit-backport` |
