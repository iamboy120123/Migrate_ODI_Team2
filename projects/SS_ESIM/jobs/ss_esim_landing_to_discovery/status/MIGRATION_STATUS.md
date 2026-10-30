# Migration Status — ss_esim_landing_to_discovery (Blendata → ODI)

Updated: 2026-10-30 (rev.15) | SA: 41642975+iamboy120123@users.noreply.github.com

> สร้างโดย `setup_migrate.ps1` — Claude Code อัปเดตไฟล์นี้ด้วย `/update-status` ทุกครั้งที่จบ step

## 1. Scope

| รายการ | ค่า |
|---|---|
| Workflow | `ss_esim_landing_to_discovery` |
| Blendata export | `input/blendata/export_workflow.json` |
| ODI project / package | `SS_ESIM_L2D` / `PKG_SS_ESIM_L2D` |
| Logical schema / context | `DSS_ODI_LOG` / `DEV` |
| Landing | `DSSDEV.TB_LANDING_SS_ESIM` (rev.2: แก้จาก `1 tb_landing_ss_esim` ที่พิมพ์ผิดตอนเปิดงาน) |
| Schema mode | `odiref` (Q8) |
| Schedule | `30 * * * *` ODI Agent + Limit Concurrent Executions = 1 (Q5) |
| Excluded tasks | - (999999 = placeholder Q9 · 080000 = DELETE Q10 · 000000 = variable precheck) |

## 2. สถานะรายเฟส

| Phase | งาน | สถานะ |
|---|---|---|
| 0 | Setup / config (`setup_migrate.ps1`) + pre-flight | ✅ setup 2026-10-29 · ✅ pre-flight 5/5 (2026-10-29) → ✅ G0 PASS 2026-10-29 (`check_gate.py G0`) |
| 1 | Intake I1–I17 | 🔄 2026-10-29 — ปิดแล้ว I4, I12, I15 · ค้าง I10/I13 (หลัง convert / gen-export) · I14 รอ Q3 (`partitionOverwriteMode`) · I16 ยืนยัน project ซ้ำใน Studio |
| 1-3 | Extract + Convert | ✅ 2026-10-29 — 12 task (SQL 9 · export_jdbc 999999 · non-SQL 080000, 000000) · converted 10 ไฟล์ · ✅ G1 PASS 12/12 · V6 PASS · REVIEW_FLAGS PENDING 21 (convert_sql 17 + conversion-auditor 4) |
| 4 | SQL Review | 🔄 2026-10-29 รอบ 1 — sql-reviewer + semantic-verifier 020000/030000/040000/090000 · PHASE4_REVIEW_LOG 20 ประเด็น (FIXED 9 · NO_CHANGE 5 · OPEN 6) · 030000/090000 RESOLVED · ⛔ G2 BLOCKED (Q3 เปิด · PENDING 19 · OPEN 6) · 🟡 waiver W1–W3 (5 ประเด็นที่ขึ้นกับ Blendata, ✅ SA 2026-10-29) · Q13 `create_by` = USER ✅ · G2.M1 ✅ SA 2026-10-29 → 🟡 **G2 WAIVED** 2026-10-29 · ถัดไป `/gen-export` |
| 5 | DML + ODI Smart Import XML | ✅ 2026-10-29 build รอบ 2 (โครงพื้นฐาน) `output/odi_export/PKG_SS_ESIM_L2D.zip`: 2 variable · 11 procedure · 13 step (… 080000 → 999999 → 090000, K15) · validator 0 error · pre_delivery_gate FAIL 0 · V1/V2 PASS · retry (Q11) / Evaluate (Q2) / OdiSendMail (Q6) เลื่อนหลังรอบพื้นฐาน (SA) · SS_ESIM14 ไม่เคยรันผ่าน (SA) → ไม่ต้องเทียบตาม pre-delivery ข้อ 4 · SQL_REVIEW ✅ 5 · 🟡 5 · ⛔ 0 (⑥ คอมไพล์ DEV ผ่าน 10/10) · **เกรด B (ส่งได้ มีเงื่อนไข: waiver W1–W3)** · ✅ Smart Import เข้า DEV แล้ว 2026-10-29 20:42 (ผู้ใช้กด Finish ก่อนส่งภาพหน้า action — หลักฐาน `input/run_results/import_r1/`) |
| 6 | DDL / DBA prereq | 🔄 2026-10-29 `output/ddl/01_create_tables.sql` (8 ตาราง ชนิดจริงจาก DEV 112 คอลัมน์ · fallback 0) + `output/dba/` · V3/V6 PASS · ddl-dba-reviewer: FIX 1–3 แก้แล้ว (K17) · DECIDE: ความยาวคอลัมน์ปลายทางสั้นกว่าต้นทาง 4 จุด (ก่อน G6) · DEV ไม่ต้องรันอะไรก่อน Run Pack แรก (ห้ามรัน 01_create_tables.sql บน DEV — ORA-00955) |
| 7 | Validation (Dev run + L1/L2/L3) | 🔄 2026-10-29 Run Pack `rp01_20261029` (G3 PASS) + test-designer: D1_diagnose · S7a_seed_DEV (27 case, marker `/sa_test/rp01/`) · S7b_assertions · S7c_cleanup_DEV — ยังไม่ได้รัน · expected มาจากการตีความ Spark SQL ไม่ใช่การรัน Spark จริง (L37 — ยืนยันด้วย D1 Blendata) |
| 8 | Backfill / Cutover | ⏳ |

## 3. Package (ลำดับรันใน ODI)

_(เติมหลัง Phase 5)_

## 4. การตัดสินใจ (SA ตอบแล้ว 2026-10-29 · Q1, Q3–Q6 ยังมีค่าค้าง — V4 ยังนับว่าเปิด · รายละเอียด `status/OPEN_DECISIONS.md`)

| Q | เรื่อง | คำตอบ |
|---|---|---|
| Q1 | Landing retention | B ยังไม่ทราบ — ถามทีม ingestion (ก่อน G7) (เปิด) |
| Q2 | Fail-fast เมื่อ lag > 120 นาที | A ต้องการ |
| Q3 | Spark config Blendata | B ยังขอไม่ได้ (ต้องได้ก่อน G2) (เปิด) |
| Q4 | Data contract landing | A ตาม `all_tab_columns` + DESCRIBE จาก Blendata |
| Q5 | Schedule | A Scenario + Agent + กันรอบซ้อน |
| Q6 | แจ้งเตือน | A OdiSendMail KO path (ค่า SMTP / ผู้รับ = placeholder, ก่อน G4) |
| Q7 | Work repo | DEV = `DSSDEV` · user SELECT = `SYSTEM` (ข้อสังเกต G6.M4) · Prod ยังไม่ทราบ |
| Q8 | Schema qualification | A `odiref` |
| Q9 | Export SQL Server (999999) | A placeholder (GAP-02) |
| Q10 | Cleanup raw_temp (080000) | A DELETE ทั้งตารางตอนจบรอบ (GAP-03) |
| Q11 | Retry | A 2 ครั้ง × 60 วินาที |
| Q12 | Guard รอบล้มกลางทาง | A As-Is (GAP-01) |
| Q13 | `create_by` (`get_user()`) | A `USER` = login ของ ODI (known diff ใน parity) |

## 5. ยังค้าง

- [x] Pre-flight 2 / 3 / 5 (Topology · DDL · สิทธิ์ Smart Import) → 5/5 ✅ SA 2026-10-29
- [x] รัน `python scripts/checks/check_gate.py G0` ยืนยัน → ✅ G0 PASS 2026-10-29
- [x] Phase 1–3 `/convert` (rev.5)
- [ ] Phase 4 ปิด G2 — ค้าง: Q3 Spark config (ansi / timeParserPolicy / escapedStringLiterals / session.timeZone) → `/preflight` P5 · now()→SYSDATE timezone (Q3/Q5) · `get_user()` → `USER` ใน `create_by` (ต้องเปิด Q ใหม่ด้วย `/decide`) · b_no เมื่อ partner/sim_type NULL (D1: นับ IS NULL vs '' ใน landing Blendata) · D1: `DESCRIBE` status table บน Blendata
- [ ] ⚠️ ห้ามรัน `convert_sql.py` ซ้ำ — จะเขียนทับ converted ที่แก้มือแล้ว (020000, 030000, 040000, 090000) · kit นี้ไม่มี protected_files
- [ ] เสนอ kit rule จาก conversion-auditor (NULLS FIRST, regex `\`, flag now()/get_user(), BOOLEAN ตาม DDL, SPARKISM V1) → `/kit-backport` หลัง SA อนุมัติ
- [ ] Q3 ค่า Spark config จริง → ปลด I14 (DELETE เฉพาะ partition / ล้างทั้งตาราง) ของ 020000, 040000, 070000 · ก่อน G2
- [ ] `DESCRIBE tb_landing_ss_esim` จาก Blendata + รูปแบบข้อความของ `FIRST_INSTALLED` (Q4) · ก่อน `/review-sql`
- [ ] sample Evaluate Variable step จาก ODI Studio (Q2) · ก่อน `/gen-export`
- [ ] ค่า SMTP / ผู้รับ mail (Q6) · ก่อน G4
- [ ] retry 2 × 60 วินาที (Q11) — เลื่อนหลังรอบพื้นฐาน: sample `KoRetry` จาก `ZZ_REF` → K# builder (retry) → import Overwrite
- [ ] ความยาวคอลัมน์ปลายทาง 4 จุดสั้นกว่าต้นทาง (Q14) — DBA / Blendata ยืนยันค่าสูงสุดจริง · ก่อน G6
- [ ] Evaluate `v_lag_minutes <= 120` (Q2) แล้วค่อย OdiSendMail KO path (Q6) — SA ให้เลื่อนหลังรอบพื้นฐาน 2026-10-29 · เติมทีละอย่าง (Evaluate ก่อน) · ทั้งคู่ก่อน G4
- [ ] timezone ของ DAG / Blendata (`session.timeZone`) เทียบ `DBTIMEZONE` / `SESSIONTIMEZONE` ของ Oracle (Q5 / Q3)
- [ ] ผู้เติม landing ใน Prod (Q4) · ก่อน G6.M3
- [x] ADR-002 (variable precheck) → Accepted ✅ SA 2026-10-29 (Q2)
- [ ] DBA grant SELECT `DSSDEV.SNP_*` ให้ user read-only แทน `SYSTEM` (Q7)
- [ ] ยืนยันความหมาย `olderThan: -1` (Q10) · วิธี export SQL Server จริง (Q9) · schema work repo Prod (Q7) · ก่อน G6
- [ ] Landing retention (Q1) · ก่อน G7
- [ ] `/inputs` ขึ้น `[พร้อม]` (ของครบ) → build → **Smart Import ครั้งเดียว** → ทดสอบ (`/run-pack`)

## 6. Kit — สิ่งที่แก้/เพิ่ม

| # | ไฟล์ | รายละเอียด |
|---|---|---|
| K17 | `scripts/pipeline/gen_ddl.py` (backup `.bak-20261029`) | 2026-10-29 bug fix: `load_existing_columns` อ่านแค่ `input/run_results/*/*.csv` ไม่อ่าน `input/oracle_ddl/*.csv` (all_tab_columns ที่ใช้ตอน preflight) → fallback VARCHAR2(4000) 56 คอลัมน์ · แก้ให้อ่านทั้งสองที่ → existing 112 · fallback 0 · V6 PASS · (2) `gen_ddl.py` unique index เฉพาะ strategy merge (050300 append ไม่ได้ UX_ บน CDR_ID แล้ว) · (3) `gen_dba_prereq.py` (backup `.bak-20261029`): นับ TRUNCATE ตรง ๆ (0 → 3: 010000/030000/090000) + แทน odiRef ก่อนหา external object (0 → 4) · ผลจาก ddl-dba-reviewer · generic → `/kit-backport` |
| K16 | `scripts/checks/review_report.py` (backup `.bak-20261029`) | 2026-10-29 bug fix: ชื่อไฟล์แบบ `task_<hex>_<code>_…` ทำให้ `split('_')[0]` = `task` ทุกไฟล์ → flag/review ของ 040000/020000 ไปนับให้ทุก task และชั้น ⑤ หา procedure ใน XML ไม่เจอ (ชื่อใน XML ตัด `task_<hex>_` ออก) · แก้ให้ใช้ `task_<hex>` และชื่อ procedure · ผล: ⛔ 10 → ✅ 5 · 🟡 3 · ⛔ 2 · `--make-compile-pack` แทน `<%=odiRef.getSchemaName(...)%>` ด้วย `odi.work_user` (DSSDEV) ไม่งั้นคอมไพล์นอก ODI ไม่ได้ · generic → `/kit-backport` |
| K15 | `scripts/pipeline/build_odi_export.py` (backup `.bak-20261029`) | 2026-10-29 (SA อนุมัติในแชต): `seq_key` ใช้ช่อง `seq` (int) ใน `output/dml/_manifest.json` ถ้ามี แทนเลขหน้าชื่อ task · ตั้ง 999999 `seq = 85000` (หลัง 080000 ก่อน 090000 ตาม DAG) · generic → `/kit-backport` |
| K14 | `scripts/checks/check_inputs.py` (backup `.bak-20261029`) | 2026-10-29 (SA อนุมัติในแชต): (1) ข้าม DDL ของ task `kind=export_jdbc` (gen_dml SKIP → placeholder, Q9) · (2) REVIEW_FLAGS PENDING ไม่บล็อกเมื่อมี waiver G2 `REVIEW_FLAGS PENDING` ที่ open (ตรงกับ check_gate K11) → แสดงเป็นคำเตือน · (4) `scripts/checks/verify_all.py` V4 (backup `.bak-20261029`): REVIEW_FLAGS PENDING / PHASE4_REVIEW_LOG OPEN → WARN เมื่อมี waiver G2 ที่ open ครอบ (SA อนุมัติในแชต 2026-10-29) · (5) `scripts/checks/review_report.py` ชั้น ①–③: flag PENDING / review OPEN ใต้ waiver G2 ที่ open → 🟡 (ระบุ Wn) แทน ⛔ (SA อนุมัติในแชต 2026-10-29) · (3) `scripts/pipeline/build_odi_export.py` (backup `.bak-20261029`) ด่าน REVIEW_FLAGS PENDING → `[WARN]` เมื่อมี waiver เดียวกัน (SA อนุมัติในแชต 2026-10-29) · ⚠️ waiver ครอบ PENDING ทั้งหมดของ G2 — flag ใหม่นอก W1 จะไม่ถูก builder หยุด · generic → `/kit-backport` |

## 7. ไฟล์อ้างอิง

- `CLAUDE.md` — กฎของโปรเจกต์สำหรับ Claude Code
- `config/config.json` — config pipeline
- `status/PREFLIGHT_CHECKLIST.md` — gate ก่อน Phase 1 (อัปเดตด้วย `setup_migrate.ps1 -Mode InPlace`)
- `status/GAP_ANALYSIS.md` — GAP-01 … GAP-04

## 8. ประวัติ rev

| rev | วันที่ | สิ่งที่เปลี่ยน |
|---|---|---|
| 1 | 2026-10-29 | setup |
| 2 | 2026-10-29 | แก้ชื่อ landing · Intake รอบแรก ปิด Q1–Q12 (บางข้อมีค้าง) · GAP-01–04 · config `schema_mode=odiref`, `work_repo_schema=DSSDEV`, refresh_query ใส่ odiRef · หมายเหตุ: ทำจาก Cowork (shell บนเครื่องรันไม่ได้) — ยังไม่ได้รัน `wiki.py` / `check_inputs.py` / `job_status.py` |
| 3 | 2026-10-29 | Pre-flight 5/5 (ข้อ 2, 3, 5 ✅ SA) → G0 พร้อม |
| 4 | 2026-10-29 | `/gate G0` → ✅ PASS (PREFLIGHT 5/5) — แก้ช่อง Status ข้อ 2 ใน `PREFLIGHT_CHECKLIST.md` เป็น ✅ ตามที่ SA ยืนยันในแชต (rev.3 ลงแค่ Note/Checked by) · state-auditor: §4 ระบุ Q ที่ยังค้าง, §5 เพิ่ม Q4/Q5/ADR-002 · `INTAKE.md` I16 work repo schema = `DSSDEV` (Q7) · ADR-002 Accepted ✅ SA 2026-10-29 · บทเรียน L39 (ช่อง Status ของ preflight) ใน `knowledge/lessons-learned.md` → พร้อม Phase 1–3 (`/convert`) |
| 5 | 2026-10-29 | `/convert`: extract 12 task · convert 10 ไฟล์ · flag 17 + conversion-auditor 4 (040000 NULLS FIRST, regex `\`, get_user(); 020000 now() timezone) · G1 PASS · V6 PASS |
| 6 | 2026-10-29 | `/review-sql` รอบ 1: แก้ converted 020000 (guard UPPER 'TRUE'), 030000/090000 ('TRUE'), 040000 (concat→\|\|, REGEXP_SUBSTR, NULLS FIRST, TRUNC, regex `\(`) · check_sql (--ddl --partitions) 0 error 4 WARN · semantic-verifier: 010000/030000/090000 PASS, 020000/040000 NEEDS-D1 · G2 BLOCKED (Q3) |
| 7 | 2026-10-29 | `/preflight` P5: สร้าง `rp00_preflight_20261029` + เพิ่ม `P5b_blendata_d1_checks.sql` · รัน Blendata ไม่ได้ (ไม่มีผล) → waiver W1 ใน `status/GATES.md` (5 ประเด็นที่ขึ้นกับ Blendata · ปิดก่อน G5) · G2 ยัง BLOCKED |
| 7b | 2026-10-29 | Q13 = A (`create_by` = USER) ✅ SA · review log แถว get_user → ACCEPTED · waiver W2 (log OPEN) / W3 (flag PENDING) ขอบเขตเดียวกับ W1 · G2 เหลือ G2.M1 |
| 8 | 2026-10-29 | G2.M1 ✅ SA (ตรวจ PHASE4_REVIEW_LOG) → `check_gate.py G2` = 🟡 WAIVED (W1–W3, ปิดก่อน G5 เมื่อได้ผล P5/P5b) → พร้อม Phase 5 `/gen-export` |
| 9 | 2026-10-29 | `/gen-export` รอบ 1: I14 = delete_by_partition ×3 · concat_policy = plain_concat · K14 (check_inputs + builder รับ waiver W3 / ข้าม DDL export_jdbc) · DML manual 080000 (DELETE, Q10) + 999999 (placeholder, Q9) · check_inputs [พร้อม] · build + validate ผ่าน · xml-auditor: REGENERATE (ลำดับ step / retry / VE / SS_ESIM14) — ยังไม่ส่ง import |
| 10 | 2026-10-29 | K15 ลำดับ step (999999 ก่อน 090000) · build รอบ 2 reuse GlobalId 97/97 · SA: retry/Evaluate/OdiSendMail เลื่อนหลังรอบพื้นฐาน · SS_ESIM14 = งานทดสอบเก่า ไม่เคยรันผ่าน (จุดต่าง TRUNCATE→DELETE อธิบายได้ด้วย I14/Q10, CAST = TO_NUMBER, odiRef = Q8, 999999 = Q9) → พร้อม Smart Import |
| 11 | 2026-10-29 | `/review-report`: K16 (review_report bug fix + odiRef → DSSDEV ใน compile pack) · K14 ข้อ 4–5 (V4 / review_report รับ waiver G2) · 🟡 ทั้งหมด NO_CHANGE (SA) · ⑥ คอมไพล์: คนรันใน DBeaver (`_ALL_compile.sql`, แผน 4e6d869f89) ไม่มี error 10/10 — 999999 ผ่านด้วย แปลว่า `ext_dss_checkpoint_tb_transaction_ss_esim_valid` มีอยู่ใน DEV แต่ไม่อยู่ใน `_shared_all_tab_columns.csv` (สมมติฐาน: view/synonym — ตรวจตอนปิด Q9) · grade.py = B |
| 12 | 2026-10-29 | Smart Import `PKG_SS_ESIM_L2D.zip` เข้า DEV (import-lock โดยผู้ใช้) · ภาพหน้าจอ: project `SS_ESIM_L2D` + package chain v_max_partition → v_lag_minutes → 010000 … ตรงกับ build · Smart Import - Log 20:42:11 import procedure 050300…090000 · Topology ไม่มี object ซ้ำ (`DSS_ODI` / `DSS_ODI.DSSDEV` / `DSS_ODI_LOG` / context `DEV`) · Test Connection `DSS_ODI` หลัง import ผ่าน (ผู้ใช้แจ้ง 2026-10-29) · import-unlock แล้ว (ผู้ใช้แจ้ง) · Generate Scenario `PKG_SS_ESIM_L2D` 001 แล้ว (ผู้ใช้แจ้ง) · ถัดไป: `/gen-ddl` (ต้องมี `output/ddl/01_create_tables.sql` ก่อน Run Pack) → `/run-pack` |
| 13 | 2026-10-29 | `/gen-ddl`: K17 (gen_ddl อ่าน `input/oracle_ddl`, index เฉพาะ merge · gen_dba_prereq นับ TRUNCATE / หา external ใน odiref) · DDL 8 ตาราง fallback 0 · V3/V6 PASS · ddl-dba-reviewer: เหลือ DECIDE ความยาวคอลัมน์ (CDR_FILENAME 255<500, CP_ID ฯลฯ 20<100, B_NO 50<76, TYPE_ERROR 100<~147) |
| 14 | 2026-10-29 | `/run-pack` rp01_20261029: G3 PASS · V7 ไม่มี FAIL · test-designer เพิ่ม D1 / S7a / S7b / S7c + README (ข้าม S1 import แล้ว · ห้ามรัน S2a บน DEV) · สมมติฐานที่ต้องยืนยันด้วย D1: mapping ECP_ESIM_SalesT/AWN ใน DEV, landing ไม่มีแถวจริงหลัง checkpoint · cleanup คืนค่าไม่ได้: status / status_temp / raw_temp ทั้งตาราง |
| 15 | 2026-10-30 | rp01 รอบทดสอบแรกบน DEV: D1 ผ่านทุกข้อบังคับ · S7a seed 30/30 (OK, 29 ต.ค. 21:29) · scenario `PKG_SS_ESIM_L2D` session 301 รัน 30 ต.ค. 09:13 สำเร็จ 13/13 step (ภาพ Operator ในแชต — ยังไม่ได้บันทึกลงโฟลเดอร์) · S7b assertions **55/55 PASS** (`input/run_results/rp01_20261029/S7b.csv`, REPORT.md) · expected มาจากการตีความ Spark ไม่ใช่การรัน Spark จริง (L37 / waiver W1) · S7c cleanup: `*_LEFT` = 0 ทุกตาราง · checkpoint MAX กลับเป็น 202610120900 · status NULL|TRUE (`S7c.csv`) |
