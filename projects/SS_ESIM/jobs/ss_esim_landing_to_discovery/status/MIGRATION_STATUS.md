# Migration Status — ss_esim_landing_to_discovery (Blendata → ODI)

Updated: 2026-10-29 (rev.8) | SA: 41642975+iamboy120123@users.noreply.github.com

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
| 5 | DML + ODI Smart Import XML | ⏳ |
| 6 | DDL / DBA prereq | ⏳ (ตารางทั้ง 9 มีใน `all_tab_columns` DSSDEV แล้ว) |
| 7 | Validation (Dev run + L1/L2/L3) | ⏳ |
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
