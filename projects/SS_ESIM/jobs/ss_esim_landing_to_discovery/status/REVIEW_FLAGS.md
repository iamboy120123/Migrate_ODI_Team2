# status/REVIEW_FLAGS.md

Generated: 2026-10-29T17:14:39
AI Mode: `manual`

SQL ที่ถูกแปลงอัตโนมัติแล้วแต่ยังต้องผ่านการตรวจทาน (โดย AI ถ้า auto, โดย SA ถ้า manual)
ก่อนเข้า Phase 5 (gen_dml.py) ทุกแถวต้องมี status = RESOLVED

| Task ID | Reason | Snippet | Status |
|---|---|---|---|
| task_1b899dbbbe54449d8218e58bed2a044f_030000_running_ss_esim_landing_to_discovery_workflow_status | [FLAG] BOOLEAN literal true/false - Oracle 19c ไม่มี BOOLEAN ใน SQL ต้อง map เป็น NUMBER(1) | `true` | RESOLVED |
| task_6451c19231b14139ab3d99b35ac9c734_020000_overwrite_ss_esim_checkpoint_temp | [FLAG] BOOLEAN literal true/false - Oracle 19c ไม่มี BOOLEAN ใน SQL ต้อง map เป็น NUMBER(1) | `TRUE` | PENDING |
| task_6451c19231b14139ab3d99b35ac9c734_020000_overwrite_ss_esim_checkpoint_temp | [FLAG] BOOLEAN literal true/false - Oracle 19c ไม่มี BOOLEAN ใน SQL ต้อง map เป็น NUMBER(1) | `TRUE` | PENDING |
| task_6660be16ef9e43bfbcc8974256bb27f6_090000_success_ss_esim_landing_to_discovery_workflow_status | [FLAG] BOOLEAN literal true/false - Oracle 19c ไม่มี BOOLEAN ใน SQL ต้อง map เป็น NUMBER(1) | `true` | RESOLVED |
| task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp | [CRITICAL] TO_DATE(...) ต้องตรวจ format mask | `to_date(raw_.first_installed)` | PENDING |
| task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp | [CRITICAL] TO_DATE(...) ต้องตรวจ format mask | `to_date(raw_.first_installed)` | PENDING |
| task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp | [CRITICAL] split/reverse/array index ไม่มีใน Oracle ต้องใช้ REGEXP_SUBSTR | `reverse(` | PENDING |
| task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp | [CRITICAL] split/reverse/array index ไม่มีใน Oracle ต้องใช้ REGEXP_SUBSTR | `split(` | PENDING |
| task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp | [CRITICAL] split/reverse/array index ไม่มีใน Oracle ต้องใช้ REGEXP_SUBSTR | `)[0]` | PENDING |
| task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp | [CRITICAL] regexp_extract -> REGEXP_SUBSTR(...,1,1,NULL,n); regexp_replace semantics ต่างกัน | `regexp_replace(type_error,': Invalid [A-Z]+ type \\(Raw=[\\S]*\\)` | PENDING |
| task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp | [CRITICAL] regexp_extract -> REGEXP_SUBSTR(...,1,1,NULL,n); regexp_replace semantics ต่างกัน | `regexp_extract(reverse(split(input_source_name,'/')` | PENDING |
| task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp | [CRITICAL] concat() หลาย arg: Spark คืน NULL ถ้ามี arg เป็น NULL แต่ || ของ Oracle ไม่คืน | `concat( CASE WHEN mapping.cp_id is null THEN 'cp_id is NULL\|' else '' end ,CASE` | PENDING |
| task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp | [CRITICAL] concat() หลาย arg: Spark คืน NULL ถ้ามี arg เป็น NULL แต่ || ของ Oracle ไม่คืน | `concat(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS'),LPAD(TO_CHAR(1), 3, '0'),LPAD(TO_CHA` | PENDING |
| task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp | [CRITICAL] concat() หลาย arg: Spark คืน NULL ถ้ามี arg เป็น NULL แต่ || ของ Oracle ไม่คืน | `concat( CASE WHEN partner is null THEN 'partner is NULL\|' else '' end ,CASE WHEN` | PENDING |
| task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp | [CRITICAL] concat() หลาย arg: Spark คืน NULL ถ้ามี arg เป็น NULL แต่ || ของ Oracle ไม่คืน | `concat( CASE WHEN CASE WHEN REGEXP_LIKE(SUBSTR(first_installed, 1, 14), '^[0-9]{` | PENDING |
| task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp | [CRITICAL] concat() หลาย arg: Spark คืน NULL ถ้ามี arg เป็น NULL แต่ || ของ Oracle ไม่คืน | `concat('first_installed: Invalid TIMESTAMP type (Raw=',coalesce(first_installed,` | PENDING |
| task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp | [CRITICAL] concat() หลาย arg: Spark คืน NULL ถ้ามี arg เป็น NULL แต่ || ของ Oracle ไม่คืน | `concat(partner,'_ESIM_',sim_type)` | PENDING |
| task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp | [CRITICAL][conversion-auditor] window ORDER BY: Spark ASC = NULLS FIRST, Oracle = NULLS LAST · file_date ไม่ match → Spark '' / Oracle NULL → แถวที่ได้ rn=1 (MAP/UNMAP vs DUP) เปลี่ยน · ต้องเติม NULLS FIRST | `ROW_NUMBER() over(PARTITION BY chk_duplicate,status ORDER BY file_date)` | PENDING |
| task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp | [CRITICAL][conversion-auditor] regex literal `\`: Spark (escapedStringLiterals=false) ยุบเป็น `\` แต่ Oracle ไม่ยุบ → ต้องเขียน `\(` `\S` `\d` (รอ Q3) | `': Invalid [A-Z]+ type \(Raw=[\S]*\)'` | PENDING |
| task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp | [FLAG][conversion-auditor] get_user() → USER: create_by จะเป็น login ของ ODI agent ไม่ใช่ user ของ Blendata — SA ยืนยันค่า | `USER AS create_by` | PENDING |
| task_6451c19231b14139ab3d99b35ac9c734_020000_overwrite_ss_esim_checkpoint_temp | [FLAG][conversion-auditor] now() → SYSDATE: timezone (session.timeZone, Q3/Q5) + ความละเอียด µs → วินาที กระทบจุดตัด partition_minute และ process_date (เหตุผลเดียวกันใช้กับ 030000, 040000, 050100, 050200, 050300) | `TO_CHAR(SYSDATE-INTERVAL '5' MINUTE, 'YYYYMMDDHH24MI')` | PENDING |
