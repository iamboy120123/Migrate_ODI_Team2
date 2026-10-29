# PHASE4 REVIEW LOG — ss_esim_landing_to_discovery (Blendata → ODI)

Updated: 2026-10-29 · บันทึกผล Phase 4 (`/review-sql` → `sql-reviewer` → `semantic-verifier`) ต่อ task
ใช้โดย: gate **G2** (`verify_all.py` V4 — ทุก task ใน `status/REVIEW_FLAGS.md` ต้องมีแถวที่นี่ และไม่มีสถานะ `OPEN`) · G2.M1 (SA ตรวจไฟล์นี้)

## วิธีบันทึก

- 1 แถว = 1 ประเด็น ของ 1 task · คอลัมน์แรก = task id ตรงกับ `status/REVIEW_FLAGS.md` · **คอลัมน์สุดท้าย = สถานะ**
- สถานะ: `OPEN` (ยังไม่จบ) · `FIXED` (แก้ใน converted แล้ว, semantics เท่าเดิม) · `ACCEPTED` (ต่างจาก Spark แต่มี Q/ADR ที่ SA ปิดแล้ว) · `NO_CHANGE` (ตรวจแล้วไม่ต้องแก้)
- เปลี่ยน semantics = `ใช่` → ต้องมี Q ใน `status/OPEN_DECISIONS.md` (ปิดโดย SA) หรือ ADR ก่อนเป็น `ACCEPTED` — agent ห้ามตัดสินเอง
- semantic-verifier: `PASS` (หา counter-example ไม่ได้) · `FAIL <case>` · `-` (ยังไม่รัน)

## Spark config ที่ใช้ตีความ (Q3)

| config | ค่า (Blendata) | แหล่งที่มา |
|---|---|---|
| `spark.sql.ansi.enabled` | _(รอ Q3)_ | |
| `spark.sql.legacy.timeParserPolicy` | _(รอ Q3)_ | |
| `spark.sql.parser.escapedStringLiterals` | _(รอ Q3)_ | |

## บันทึกต่อ task

| Task | ประเด็น / flag | ผลตรวจ (sql-reviewer) | การแก้ใน converted | เปลี่ยน semantics? | semantic-verifier | Q / ADR | สถานะ |
|---|---|---|---|---|---|---|---|
| task_1b899dbbbe54449d8218e58bed2a044f_030000_running_ss_esim_landing_to_discovery_workflow_status | BOOLEAN `true` | ORA-00904 · RUNNING = VARCHAR2(5) | `select true as running` → `select 'TRUE' as running` | ไม่ | PASS | - | FIXED |
| task_6660be16ef9e43bfbcc8974256bb27f6_090000_success_ss_esim_landing_to_discovery_workflow_status | BOOLEAN `true` | ORA-00904 · SUCCESS = VARCHAR2(5) | `select true as success` → `select 'TRUE' as success` | ไม่ | PASS | - | FIXED |
| task_6451c19231b14139ab3d99b35ac9c734_020000_overwrite_ss_esim_checkpoint_temp | BOOLEAN `TRUE = COALESCE(success, TRUE)` | ORA-00904 · SUCCESS = VARCHAR2(5) · ข้อมูลเดิมจาก Spark อาจเป็น `'true'` ตัวเล็ก (E20) | → `'TRUE' = UPPER(COALESCE(success, 'TRUE'))` | ไม่ (NULL/ไม่มีแถว ผ่าน · `'FALSE'` ไม่ผ่าน เหมือนเดิม) · ก่อน cutover `DUMP(success)` | PASS · NEEDS-D1: `DESCRIBE`/`SELECT *` status table บน Blendata หลัง 030000 และ 090000 (ชนิด success + พฤติกรรมรอบพังกลางทาง) | - | FIXED |
| task_6451c19231b14139ab3d99b35ac9c734_020000_overwrite_ss_esim_checkpoint_temp | nth_value / DENSE_RANK window frame | default frame เท่ากัน (RANGE UNBOUNDED PRECEDING..CURRENT ROW) · แถวแรก NULL ทั้งคู่ ครอบด้วย `rnk in(1,2)` | - | ไม่ | PASS | - | NO_CHANGE |
| task_6451c19231b14139ab3d99b35ac9c734_020000_overwrite_ss_esim_checkpoint_temp | NULL ordering ใน window | checkpoint_partition ไม่เป็น NULL (filter `<` ตัดแล้ว) + DISTINCT | - | ไม่ | PASS | - | NO_CHANGE |
| task_6451c19231b14139ab3d99b35ac9c734_020000_overwrite_ss_esim_checkpoint_temp | now() → SYSDATE: timezone (conversion-auditor) | SYSDATE = TZ ของ OS ฝั่ง DB · Spark = `session.timeZone` (ไม่ทราบ) → cutoff `partition_minute` / `partition_date` / `workflow_process_date` อาจเลื่อน · ใช้กับ 030000, 040000, 0501xx ด้วย | ยังไม่แก้ (ขึ้นกับ Q3 / Q5) | รอ Q3/Q5 | DIFF ถ้า TZ ไม่ตรง (รอ Q3/Q5) | Q3, Q5 | OPEN |
| task_6451c19231b14139ab3d99b35ac9c734_020000_overwrite_ss_esim_checkpoint_temp | now() → SYSDATE: precision µs → วินาที | ค่าคงที่ทั้ง statement ไม่กระทบ filter/rank · ต่างที่ค่า process_date | - | ไม่ (known diff ใน aggregate parity ของ process_date) | PASS | - | NO_CHANGE |
| task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp | concat() ที่ทำด้วย CASE (mapping_error 5 arg · filter_error 6 arg · type_error 1 arg) | ORA-00909 · arg เป็น `CASE..ELSE '' END` ไม่เป็น NULL ใน Spark · ไม่มี error: Spark `''` / Oracle NULL — จุดใช้ต่อเป็น IS NULL/IS NOT NULL สอดคล้องแล้ว | `concat( CASE` → `( CASE` (3) · `end ,CASE` → `end \|\| CASE` (9) | ไม่ | PASS | - | FIXED |
| task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp | concat() cdr_id 3 arg | ORA-00909 · ไม่มี arg ที่เป็น NULL | → `TO_CHAR(SYSDATE,..) \|\| LPAD(..) \|\| LPAD(..)` | ไม่ | PASS | - | FIXED |
| task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp | concat() ข้อความ type_error 3 arg | ORA-00909 · Spark ใช้ coalesce อยู่แล้ว · `\|\|` ถือ NULL เป็น '' | → `'first_installed: Invalid TIMESTAMP type (Raw=' \|\| first_installed \|\| ')\|'` | ไม่ | PASS | - | FIXED |
| task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp | concat(partner,'_ESIM_',sim_type) | ORA-00909 · ถ้า partner/sim_type เป็น NULL จริง Spark ได้ b_no NULL / Oracle ได้ `'_ESIM_x'` · แถวนั้น status = MAN อยู่แล้ว (filter_error) · join mapping อาจติดฝั่ง Oracle ถ้ามี b_no `'<partner>_ESIM_'` (semantic-verifier) | → `partner \|\| '_ESIM_' \|\| sim_type` | ขึ้นกับข้อมูล (D1) | DIFF (ทฤษฎี): partner/sim_type NULL จริงใน Spark → b_no NULL vs Oracle `'ECP_ESIM_'` อาจ join mapping ติด · NEEDS-D1: นับ partner/sim_type IS NULL vs = '' ใน landing ของ Blendata | - | OPEN |
| task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp | split / reverse / [0] + regexp_extract | ไม่มีใน Oracle (ORA-00904) · README test data: file_date = `20260827100000` → regex ใน Spark match จริง · ไม่ match: Spark `''` / Oracle NULL (ดูแถว NULLS FIRST) | → `REGEXP_SUBSTR(REGEXP_SUBSTR(input_source_name,'[^/]*$'),'(.+)(_)([0-9]{8}_[0-9]{6})(_)(.+[.].+)',1,1,NULL,3)` | ไม่ | PASS | - | FIXED |
| task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp | ROW_NUMBER ORDER BY file_date — ลำดับ NULL (conversion-auditor) | Spark ASC = NULLS FIRST · Oracle = NULLS LAST → MAP/DUP สลับ (README FN01–03) | → `ORDER BY file_date NULLS FIRST` | ไม่ (ทำให้เท่า Spark) | PASS | - | FIXED |
| task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp | to_date(raw_.first_installed) ×2 ไม่มี mask | ที่ชั้นนี้ first_installed เป็น TIMESTAMP แล้ว · Spark `to_date(ts)` = ตัดเวลา | → `TRUNC(raw_.first_installed)` (2) | ไม่ | PASS | - | FIXED |
| task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp | regexp_replace literal `\` (conversion-auditor) | Oracle ไม่ยุบ `\` → ไม่ match · `[\S]` ใน bracket = ตัวอักษร `\` / `S` | → `': Invalid [A-Z]+ type \(Raw=\S*\)'` (ถูกเมื่อ escapedStringLiterals=false — หลักฐานจาก README ชี้ว่าเป็น false) | รอ Q3 ยืนยัน | ขึ้นกับ Q3/Q5 (ไม่ใช่ DIFF ใหม่) | Q3 | OPEN |
| task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp | now() → SYSDATE (process_date, cdr_id) | เหมือนแถว now() ของ 020000 | ยังไม่แก้ | รอ Q3/Q5 | ขึ้นกับ Q3/Q5 (ไม่ใช่ DIFF ใหม่) | Q3, Q5 | OPEN |
| task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp | get_user() → USER (conversion-auditor) | create_by จะเป็น login ของ ODI แทน user ของ Blendata | ยังไม่แก้ | ใช่ (ค่าที่เก็บต่าง) | ขึ้นกับ Q3/Q5 (ไม่ใช่ DIFF ใหม่) | Q13 ✅ SA 2026-10-29 | ACCEPTED |
| task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp | nullif(x,'') ถูกถอด | Oracle '' = NULL อยู่แล้ว | - | ไม่ | PASS | - | NO_CHANGE |
| task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp | coalesce(iccid,'') → LEFT JOIN dup | Oracle ได้ NULL join ไม่ติด · แถว iccid NULL = MAN ก่อนเช็ก DUP · rn=-99 | - | ไม่ (ในทางปฏิบัติ) | PASS | - | NO_CHANGE |
| task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp | TO_TIMESTAMP + REGEXP_LIKE 14 หลัก | LEGACY timeParserPolicy อาจ lenient (เดือน 13) · CORRECTED = NULL ตรงกับ Oracle | - | รอ Q3 | ขึ้นกับ Q3/Q5 (ไม่ใช่ DIFF ใหม่) | Q3 | OPEN |

## ประวัติ

- 2026-10-29: get_user() → USER = ACCEPTED (Q13 = A) · OPEN ที่เหลือ 5 = ประเด็นที่ขึ้นกับ Blendata ภายใต้ waiver W1–W3 (`status/GATES.md`)
- 2026-10-29: /review-sql รอบ 1 — sql-reviewer 020000/030000/040000/090000 · 20 ประเด็น (FIXED 9 · NO_CHANGE 5 · OPEN 6) · semantic-verifier: 010000/030000/090000 PASS · 020000, 040000 NEEDS-D1 (b_no NULL → OPEN)
- 2026-10-29: สร้างจาก kit 2.8.1 (2026-10-14)
