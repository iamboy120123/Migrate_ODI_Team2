# Migration Status — ss_esim_landing_to_discovery (Blendata → ODI)

Updated: 2026-10-29 (rev.3) | SA: 41642975+iamboy120123@users.noreply.github.com

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
| 0 | Setup / config (`setup_migrate.ps1`) + pre-flight | ✅ setup 2026-10-29 · ✅ pre-flight 5/5 (2026-10-29) → G0 (ยืนยันด้วย `/gate G0`) |
| 1 | Intake I1–I17 | 🔄 2026-10-29 — ปิดแล้ว I4, I12, I15 · ค้าง I10/I13 (หลัง convert / gen-export) · I14 รอ Q3 (`partitionOverwriteMode`) · I16 ยืนยัน project ซ้ำใน Studio |
| 1-3 | Extract + Convert | ⏳ |
| 4 | SQL Review | ⏳ |
| 5 | DML + ODI Smart Import XML | ⏳ |
| 6 | DDL / DBA prereq | ⏳ (ตารางทั้ง 9 มีใน `all_tab_columns` DSSDEV แล้ว) |
| 7 | Validation (Dev run + L1/L2/L3) | ⏳ |
| 8 | Backfill / Cutover | ⏳ |

## 3. Package (ลำดับรันใน ODI)

_(เติมหลัง Phase 5)_

## 4. การตัดสินใจที่ปิดแล้ว (2026-10-29 · รายละเอียด `status/OPEN_DECISIONS.md`)

| Q | เรื่อง | คำตอบ |
|---|---|---|
| Q1 | Landing retention | B ยังไม่ทราบ — ถามทีม ingestion (ก่อน G7) |
| Q2 | Fail-fast เมื่อ lag > 120 นาที | A ต้องการ |
| Q3 | Spark config Blendata | B ยังขอไม่ได้ (ต้องได้ก่อน G2) |
| Q4 | Data contract landing | A ตาม `all_tab_columns` + DESCRIBE จาก Blendata |
| Q5 | Schedule | A Scenario + Agent + กันรอบซ้อน |
| Q6 | แจ้งเตือน | A OdiSendMail KO path (ค่า SMTP / ผู้รับ = placeholder, ก่อน G4) |
| Q7 | Work repo | DEV = `DSSDEV` · user SELECT = `SYSTEM` (ข้อสังเกต G6.M4) · Prod ยังไม่ทราบ |
| Q8 | Schema qualification | A `odiref` |
| Q9 | Export SQL Server (999999) | A placeholder (GAP-02) |
| Q10 | Cleanup raw_temp (080000) | A DELETE ทั้งตารางตอนจบรอบ (GAP-03) |
| Q11 | Retry | A 2 ครั้ง × 60 วินาที |
| Q12 | Guard รอบล้มกลางทาง | A As-Is (GAP-01) |

## 5. ยังค้าง

- [x] Pre-flight 2 / 3 / 5 (Topology · DDL · สิทธิ์ Smart Import) → 5/5 ✅ SA 2026-10-29
- [ ] รัน `python scripts/checks/check_gate.py G0` ยืนยัน → Phase 1–3 (`/convert`)
- [ ] Q3 ค่า Spark config จริง → ปลด I14 (DELETE เฉพาะ partition / ล้างทั้งตาราง) ของ 020000, 040000, 070000 · ก่อน G2
- [ ] `DESCRIBE tb_landing_ss_esim` จาก Blendata + รูปแบบข้อความของ `FIRST_INSTALLED` (Q4) · ก่อน `/review-sql`
- [ ] sample Evaluate Variable step จาก ODI Studio (Q2) · ก่อน `/gen-export`
- [ ] ค่า SMTP / ผู้รับ mail (Q6) · ก่อน G4
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
