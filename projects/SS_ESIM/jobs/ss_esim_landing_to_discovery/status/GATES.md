# GATES — ss_esim_landing_to_discovery (Blendata → ODI)

เกณฑ์ผ่านแต่ละช่วงของงาน · ประเมินด้วย `python scripts/checks/check_gate.py G<n>` (หรือ `/gate G<n>`)

- **Auto** = สคริปต์ตรวจจาก state files + `output/verify/verify.json` (agent แก้ผลเองไม่ได้)
- **Manual** = SA ติ๊ก `[x]` พร้อม `✅ SA YYYY-MM-DD` ในบรรทัดเดียวกัน (hook `guard_owned_files` บังคับ — agent บันทึกแทนได้เฉพาะเมื่อ SA บอกในแชต)
- ผลของ gate: **PASS** · **BLOCKED** (บอกข้อที่ขาด) · **WAIVED** (มี waiver ที่ SA อนุมัติใน Waiver log)
- Verify ที่ gate ใช้: V1–V9 (`python scripts/checks/verify_all.py`) — ดูรายละเอียดใน docstring ของ `scripts/checks/verify_all.py` และ `knowledge/reference/claude-system.md`

| Gate | ก่อนเข้า | Auto | Manual | ผู้อนุมัติ |
|---|---|---|---|---|
| G0 Environment | Phase 1 (ข้อมูลจริง) | PREFLIGHT 5/5 | — | SA |
| G1 Extraction | Phase 4 | ทุก task มี converted SQL หรือมีการตัดสินใจ (excluded / manual step) | — | agent |
| G2 Review | Phase 5 | REVIEW_FLAGS มีไฟล์ + PENDING 0 · `status/PHASE4_REVIEW_LOG.md` ครอบคลุม task ที่ถูก flag + ไม่มี OPEN · Q Spark config ปิดแล้ว · V1 PASS | M1 | agent + SA |
| G3 Build | สร้าง Run Pack | V1 + V2 PASS (validator 0 error, XML ไม่ stale, SQL ใน XML = DML) | — | agent |
| G4 Import | Phase 7 Dev run (หลัง Smart Import ครั้งเดียว — หลักฐานทดสอบ ไม่ใช่ input ของ build) | Smart Export จาก Studio (หลัง import) มี code = DML ทุก step · GlobalId map ตรงกับ Studio (V2) | M1, M2 | SA |
| G5 Dev test | Pre-Prod | assertions ของ Run Pack ล่าสุด PASS ครบ · REPORT ไม่ค้าง · V7 Run Pack hygiene / V8 traceability ไม่ FAIL | M1–M3 | SA |
| G6 Pre-Prod | Cutover | OPEN_DECISIONS เปิด 0 · ADR ทั้งหมด Accepted · schema hardcode 0 · DDL fallback 0 + V6 ไม่ FAIL (DML↔DDL, data contract) | M1–M4 | SA + DBA |
| G7 Go-live | Prod | G6 auto ผ่าน · V9: backfill pack ไม่ stale, `status/CUTOVER_RUNBOOK.md` มี Rollback / Go-No-go / Parallel run ไม่มี TBD, validation พร้อม · Q retention ปิดแล้ว | M1–M4 | Business + SA |

## Manual checklist

### G2
- [x] G2.M1 SA ตรวจ `status/PHASE4_REVIEW_LOG.md` แล้ว และทุกข้อที่เปลี่ยน semantics มี Q ที่ปิดแล้ว (หรือ semantic-verifier = PASS) ✅ SA 2026-10-29 (ตอบในแชต)

### G4
- [ ] G4.M1 Smart Import แบบ **Overwrite** สำหรับ procedure/package ที่เปลี่ยน และตรวจใน Studio ว่า code เป็นเวอร์ชันใหม่
- [ ] G4.M2 Topology: logical schema `DSS_ODI_LOG` / context `DEV` / data server login ตรงกับ config (pre-flight ข้อ 2)
- [ ] G4.M3 เทียบ Data Server `UserName` และ Physical Schema (`SchemaName` / `WorkSchemaName`) ใน Smart Export (`input/odi_reference/`) กับ `odi.work_user` ใน config และ Q ที่ตัดสินเรื่อง work user / prefix ใน `status/OPEN_DECISIONS.md` ว่าตรงกัน (AI อ่านจากไฟล์เทียบเอง ไม่ถาม SA)

### G5
- [ ] G5.M1 D1: `scripts/testing/run_d1.py` รัน raw Spark SQL ทุก config ใน matrix แล้วผลของทุก task คงที่ (STABLE) · task ที่ผลต่างตาม config (CONFIG-DEPENDENT) ต้องยืนยัน config กับ Blendata แล้วมี Q ปิด — เก็บผลไว้เทียบกับ Oracle ที่ G5.M2
- [ ] G5.M2 D2 หรือ D3: เทียบผลกับ Blendata ระดับแถวด้วย `scripts/testing/compare_results.py` แล้ว diff = 0 (ยกเว้นส่วนต่างที่ยอมรับ)
- [ ] G5.M3 L1 / L2 / L3 validation ตรงกับ Blendata

### G6
- [ ] G6.M1 Re-test บน Oracle 19c (ถ้า Dev ไม่ใช่ 19c)
- [ ] G6.M2 DDL final — SA/DBA review ชนิด/ความยาว/index/tablespace แล้ว (fallback `VARCHAR2(4000)` ตรวจ auto ใน V6 · ใช้ `ddl-dba-reviewer`)
- [ ] G6.M3 ยืนยัน data contract ของ landing ใน Prod และผู้รับผิดชอบเติม landing
- [ ] G6.M4 Work repository ของ Prod ไม่อยู่ใน schema SYSTEM / ไม่ใช้ user system

### G7
- [ ] G7.M1 Backfill ครบตาม retention (Q1)
- [ ] G7.M2 Parallel run กับ Blendata N รอบ ผลตรงกัน
- [ ] G7.M3 Rollback rehearsal ผ่าน
- [ ] G7.M4 Business sign-off

## Waiver log

| ID | Gate | ข้อที่ยกเว้น | ขอบเขต / เงื่อนไข | อนุมัติโดย | สถานะ |
|---|---|---|---|---|---|
| W1 | G2 | Spark config | Q3 (Spark config ของ Blendata) ยังเปิด เพราะรัน Blendata ไม่ได้ (P5/P5b ของ `rp00_preflight_20261029` ไม่มีผล) · ยกเว้นเฉพาะ 5 ประเด็นใน `status/PHASE4_REVIEW_LOG.md` ที่ขึ้นกับ Blendata: 040000 regex `\(` (สมมติ escapedStringLiterals=false) · 040000 TO_TIMESTAMP (สมมติวันที่ผิดรูป = NULL) · 020000 + 040000 now()→SYSDATE timezone (Q3/Q5) · 040000 b_no เมื่อ partner/sim_type NULL (D1) · **ไม่ครอบคลุม** `get_user()` → `create_by` (ต้อง `/decide`) และ G2.M1 · **ปิดเมื่อ** ได้ผล P5 + P5b จากผู้ที่เข้า Blendata ได้ ก่อนผ่าน G5 — ค่าไม่ตรงสมมติฐาน = แก้ converted SQL แล้ว build ใหม่ | ✅ SA 2026-10-29 (ตอบในแชต) | open |
| W2 | G2 | PHASE4_REVIEW_LOG ยังมีรายการ OPEN | ขอบเขตเดียวกับ W1: OPEN ที่เหลือ 5 แถวคือประเด็นที่ขึ้นกับ Blendata ซึ่ง SA อนุมัติใน W1 (`get_user()` ปิดแล้วด้วย Q13) · แถว OPEN ใหม่ที่ไม่ใช่ 5 ประเด็นนี้ = ไม่ครอบคลุม · ปิดพร้อม W1 | ✅ SA 2026-10-29 (ตอบในแชต · waiver W1) | open |
| W3 | G2 | REVIEW_FLAGS PENDING | ขอบเขตเดียวกับ W1: flag ของ 020000 / 040000 ค้าง PENDING เพราะมีแถว OPEN ใต้ W1 (ประเด็นอื่นของ 2 task นี้ FIXED / NO_CHANGE แล้ว) · ปิดพร้อม W1 → เปลี่ยน flag เป็น RESOLVED | ✅ SA 2026-10-29 (ตอบในแชต · waiver W1) | open |
