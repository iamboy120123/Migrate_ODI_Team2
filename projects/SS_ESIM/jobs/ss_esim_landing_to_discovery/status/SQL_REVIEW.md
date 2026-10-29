# SQL_REVIEW — ผลตรวจ SQL ต่อ task

อัปเดต 2026-10-29 20:25 · สร้างโดย `scripts/checks/review_report.py` (/review-report) · ห้ามแก้มือ

**สรุป: ✅ 5 · 🟡 5 · ⛔ 0**  

| task | ①–③ รีวิว | ④ check_sql | ⑤ DML/XML | ⑥ คอมไพล์ | ⑦ sandbox | ความเร็ว | ผล |
|---|---|---|---|---|---|---|---|
| task_081c89ad18764c6ebe7fb2f7ed84d433_050200_append_ss_esim_reject | ✅ | ✅ | ✅ | ✅ | – | 🟡 1 | **🟡** |
| task_17e9202f814842e3b6d91fabe785f479_050300_append_ss_esim_temp | ✅ | ✅ | ✅ | ✅ | – | 🟡 1 | **🟡** |
| task_1b899dbbbe54449d8218e58bed2a044f_030000_running_ss_esim_landing_to_discovery_workflow_status | ✅ | ✅ | ✅ | ✅ | – | ดี | **✅** |
| task_44a662474c7f4ce2b1d603c3391c002d_999999_export_data_to_mssql | – | ✅ | ✅ | ✅ | – | ดี | **✅** |
| task_6451c19231b14139ab3d99b35ac9c734_020000_overwrite_ss_esim_checkpoint_temp | 🟡 | ✅ | ✅ | ✅ | – | 🟡 1 | **🟡** |
| task_6660be16ef9e43bfbcc8974256bb27f6_090000_success_ss_esim_landing_to_discovery_workflow_status | ✅ | ✅ | ✅ | ✅ | – | ดี | **✅** |
| task_8e949825ccb24a1eadf8c8d0f19bdf2b_070000_overwrite_ss_esim_checkpoint | – | ✅ | ✅ | ✅ | – | ดี | **✅** |
| task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp | 🟡 | ✅ | ✅ | ✅ | – | 🟡 3 | **🟡** |
| task_cc72e06e0d2b4dc29d37f72e1c729d1d_010000_check_success_ss_esim_landing_to_discovery_workflow_status | – | ✅ | ✅ | ✅ | – | ดี | **✅** |
| task_d60b3f0310094ab3bdbbad1eca43e81e_050100_append_ss_esim_valid | ✅ | ✅ | ✅ | ✅ | – | 🟡 1 | **🟡** |

## ต้องทำต่อ (⛔ ก่อน)

- 🟡 ความเร็ว `task_081c89ad18764c6ebe7fb2f7ed84d433_050200_append_ss_esim_reject`: CROSS JOIN (ตรวจว่าตั้งใจ)
- 🟡 ความเร็ว `task_17e9202f814842e3b6d91fabe785f479_050300_append_ss_esim_temp`: CROSS JOIN (ตรวจว่าตั้งใจ)
- 🟡 `task_6451c19231b14139ab3d99b35ac9c734_020000_overwrite_ss_esim_checkpoint_temp` flag (waiver W3): [FLAG] BOOLEAN literal true/false - Oracle 19c ไม่มี BOOLEAN — ถามผู้ใช้: ไม่ต้องแก้ใช่ไหม → บันทึก NO_CHANGE พร้อมเหตุผลใน PHASE4_REVIEW_LOG
- 🟡 `task_6451c19231b14139ab3d99b35ac9c734_020000_overwrite_ss_esim_checkpoint_temp` flag (waiver W3): [FLAG] BOOLEAN literal true/false - Oracle 19c ไม่มี BOOLEAN — ถามผู้ใช้: ไม่ต้องแก้ใช่ไหม → บันทึก NO_CHANGE พร้อมเหตุผลใน PHASE4_REVIEW_LOG
- 🟡 `task_6451c19231b14139ab3d99b35ac9c734_020000_overwrite_ss_esim_checkpoint_temp` flag (waiver W3): [FLAG][conversion-auditor] now() → SYSDATE: timezone (sessio — ถามผู้ใช้: ไม่ต้องแก้ใช่ไหม → บันทึก NO_CHANGE พร้อมเหตุผลใน PHASE4_REVIEW_LOG
- 🟡 `task_6451c19231b14139ab3d99b35ac9c734_020000_overwrite_ss_esim_checkpoint_temp` review OPEN (waiver W2): now() → SYSDATE: timezone (conversion-auditor) — ถามผู้ใช้: ไม่ต้องแก้ใช่ไหม → บันทึก NO_CHANGE พร้อมเหตุผลใน PHASE4_REVIEW_LOG
- 🟡 ความเร็ว `task_6451c19231b14139ab3d99b35ac9c734_020000_overwrite_ss_esim_checkpoint_temp`: DISTINCT (ตรวจว่าจำเป็น)
- 🟡 `task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp` flag (waiver W3): [CRITICAL] TO_DATE(...) ต้องตรวจ format mask — ถามผู้ใช้: ไม่ต้องแก้ใช่ไหม → บันทึก NO_CHANGE พร้อมเหตุผลใน PHASE4_REVIEW_LOG
- 🟡 `task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp` flag (waiver W3): [CRITICAL] TO_DATE(...) ต้องตรวจ format mask — ถามผู้ใช้: ไม่ต้องแก้ใช่ไหม → บันทึก NO_CHANGE พร้อมเหตุผลใน PHASE4_REVIEW_LOG
- 🟡 `task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp` flag (waiver W3): [CRITICAL] split/reverse/array index ไม่มีใน Oracle ต้องใช้  — ถามผู้ใช้: ไม่ต้องแก้ใช่ไหม → บันทึก NO_CHANGE พร้อมเหตุผลใน PHASE4_REVIEW_LOG
- 🟡 `task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp` flag (waiver W3): [CRITICAL] split/reverse/array index ไม่มีใน Oracle ต้องใช้  — ถามผู้ใช้: ไม่ต้องแก้ใช่ไหม → บันทึก NO_CHANGE พร้อมเหตุผลใน PHASE4_REVIEW_LOG
- 🟡 `task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp` flag (waiver W3): [CRITICAL] split/reverse/array index ไม่มีใน Oracle ต้องใช้  — ถามผู้ใช้: ไม่ต้องแก้ใช่ไหม → บันทึก NO_CHANGE พร้อมเหตุผลใน PHASE4_REVIEW_LOG
- 🟡 `task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp` flag (waiver W3): [CRITICAL] regexp_extract -> REGEXP_SUBSTR(...,1,1,NULL,n);  — ถามผู้ใช้: ไม่ต้องแก้ใช่ไหม → บันทึก NO_CHANGE พร้อมเหตุผลใน PHASE4_REVIEW_LOG
- 🟡 `task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp` flag (waiver W3): [CRITICAL] regexp_extract -> REGEXP_SUBSTR(...,1,1,NULL,n);  — ถามผู้ใช้: ไม่ต้องแก้ใช่ไหม → บันทึก NO_CHANGE พร้อมเหตุผลใน PHASE4_REVIEW_LOG
- 🟡 `task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp` flag (waiver W3): [CRITICAL] concat() หลาย arg: Spark คืน NULL ถ้ามี arg เป็น  — ถามผู้ใช้: ไม่ต้องแก้ใช่ไหม → บันทึก NO_CHANGE พร้อมเหตุผลใน PHASE4_REVIEW_LOG
- 🟡 `task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp` flag (waiver W3): [CRITICAL] concat() หลาย arg: Spark คืน NULL ถ้ามี arg เป็น  — ถามผู้ใช้: ไม่ต้องแก้ใช่ไหม → บันทึก NO_CHANGE พร้อมเหตุผลใน PHASE4_REVIEW_LOG
- 🟡 `task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp` flag (waiver W3): [CRITICAL] concat() หลาย arg: Spark คืน NULL ถ้ามี arg เป็น  — ถามผู้ใช้: ไม่ต้องแก้ใช่ไหม → บันทึก NO_CHANGE พร้อมเหตุผลใน PHASE4_REVIEW_LOG
- 🟡 `task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp` flag (waiver W3): [CRITICAL] concat() หลาย arg: Spark คืน NULL ถ้ามี arg เป็น  — ถามผู้ใช้: ไม่ต้องแก้ใช่ไหม → บันทึก NO_CHANGE พร้อมเหตุผลใน PHASE4_REVIEW_LOG
- 🟡 `task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp` flag (waiver W3): [CRITICAL] concat() หลาย arg: Spark คืน NULL ถ้ามี arg เป็น  — ถามผู้ใช้: ไม่ต้องแก้ใช่ไหม → บันทึก NO_CHANGE พร้อมเหตุผลใน PHASE4_REVIEW_LOG
- 🟡 `task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp` flag (waiver W3): [CRITICAL] concat() หลาย arg: Spark คืน NULL ถ้ามี arg เป็น  — ถามผู้ใช้: ไม่ต้องแก้ใช่ไหม → บันทึก NO_CHANGE พร้อมเหตุผลใน PHASE4_REVIEW_LOG
- 🟡 `task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp` flag (waiver W3): [CRITICAL][conversion-auditor] window ORDER BY: Spark ASC =  — ถามผู้ใช้: ไม่ต้องแก้ใช่ไหม → บันทึก NO_CHANGE พร้อมเหตุผลใน PHASE4_REVIEW_LOG
- 🟡 `task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp` flag (waiver W3): [CRITICAL][conversion-auditor] regex literal `\`: Spark (esc — ถามผู้ใช้: ไม่ต้องแก้ใช่ไหม → บันทึก NO_CHANGE พร้อมเหตุผลใน PHASE4_REVIEW_LOG
- 🟡 `task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp` flag (waiver W3): [FLAG][conversion-auditor] get_user() → USER: create_by จะเป — ถามผู้ใช้: ไม่ต้องแก้ใช่ไหม → บันทึก NO_CHANGE พร้อมเหตุผลใน PHASE4_REVIEW_LOG
- 🟡 `task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp` review OPEN (waiver W2): concat(partner,'_ESIM_',sim_type) — ถามผู้ใช้: ไม่ต้องแก้ใช่ไหม → บันทึก NO_CHANGE พร้อมเหตุผลใน PHASE4_REVIEW_LOG
- 🟡 `task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp` review OPEN (waiver W2): regexp_replace literal `\` (conversion-auditor) — ถามผู้ใช้: ไม่ต้องแก้ใช่ไหม → บันทึก NO_CHANGE พร้อมเหตุผลใน PHASE4_REVIEW_LOG
- 🟡 `task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp` review OPEN (waiver W2): now() → SYSDATE (process_date, cdr_id) — ถามผู้ใช้: ไม่ต้องแก้ใช่ไหม → บันทึก NO_CHANGE พร้อมเหตุผลใน PHASE4_REVIEW_LOG
- 🟡 `task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp` review OPEN (waiver W2): TO_TIMESTAMP + REGEXP_LIKE 14 หลัก — ถามผู้ใช้: ไม่ต้องแก้ใช่ไหม → บันทึก NO_CHANGE พร้อมเหตุผลใน PHASE4_REVIEW_LOG
- 🟡 ความเร็ว `task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp`: UNION ที่อาจควรเป็น UNION ALL (ต้องเรียง + ตัดซ้ำ)
- 🟡 ความเร็ว `task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp`: CROSS JOIN (ตรวจว่าตั้งใจ)
- 🟡 ความเร็ว `task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp`: DISTINCT (ตรวจว่าจำเป็น)
- 🟡 ความเร็ว `task_d60b3f0310094ab3bdbbad1eca43e81e_050100_append_ss_esim_valid`: CROSS JOIN (ตรวจว่าตั้งใจ)

## ความหมาย

- ✅ ผ่าน · 🟡 ต้องมีคนดูและบันทึกเหตุผล · ⛔ ห้าม build · – ยังไม่ได้ตรวจชั้นนี้
- ⑥ สร้าง pack ด้วย `--make-compile-pack` แล้วรัน `run_pack.py rp_compile --compile` (ตามโหมดการเช็กฐานของงาน)
- ⑦ sandbox ยังรอทีมตัดสิน (ฐานชั่วคราวบนเครื่อง ไม่นับเป็นฐานของงาน)
- ความเร็ว: รูปแบบ SQL ที่ช้า + แผนการรัน (EXPLAIN PLAN: python scripts/runpack/run_sql.py output/sql/converted --explain · ถามก่อนเสมอ) · เตือนเท่านั้น · บล็อกการส่งเฉพาะเมื่อเกินกรอบเวลา batch (ขั้น 05.3)
