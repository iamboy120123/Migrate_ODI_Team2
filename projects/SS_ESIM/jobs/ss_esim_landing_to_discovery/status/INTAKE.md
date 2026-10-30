# INTAKE — คำถาม I1–I17 (ตาม knowledge/reference/intake-questions.md) — SS_ESIM_L2D

Updated: 2026-10-29 · สร้างโดย `setup_migrate.ps1` จาก `config/config.json` · ใช้กับ `/intake` · ข้อเหล่านี้ใช้ตัว `I` เพื่อไม่ชนกับ Q ของ `status/OPEN_DECISIONS.md` · รายละเอียดต่อข้อ: `knowledge/reference/intake-questions.md`

- ver 6: I1, I2, I5, I9, I11, I17 ตอบจากไฟล์ / ค่าเริ่มต้นแล้ว (ไม่ถาม) · I4, I7, I8, I13, I14, I16 ถามเป็นคำยืนยันครั้งเดียว · ตารางที่ตัด/ลด: knowledge/reference/intake-questions.md หัวข้อ "ver 6"
- ✅ = มีคำตอบพร้อมแหล่งที่มา · ⬜ = ต้องถาม SA (ทีละข้อ ตามกฎการถามใน intake-questions.md) · ⚠️ = ตอบแล้วแต่มีเงื่อนไขค้าง
- คำตอบที่มาจาก config = ค่าที่ตั้งตอน setup — SA ยืนยันอีกครั้งตอน `/intake`

| # | หัวข้อ | คำตอบ | แหล่งที่มา | สถานะ |
|---|---|---|---|---|
| I1 | โฟลเดอร์งาน Blendata ต้นทาง | `input/blendata/export_workflow.json` | config `paths.input_export_workflow` | ✅ |
| I2 | ไฟล์ reference SmartExport จาก repository ปลายทาง | `input/odi_reference/_shared_smart_export_DEV_20261028.xml` | config `odi.*`, `input/odi_reference/` | ✅ |
| I3 | โครงสร้างคอลัมน์ตารางปลายทาง (DDL) | `input/oracle_ddl/_shared_all_tab_columns.csv` | `input/oracle_ddl/`, rp00 P3 | ✅ |
| I4 | Oracle schema และวิธี qualify | schema `DSSDEV` (logical schema `DSS_ODI_LOG`) · qualify ด้วย `schema_mode=odiref` (Q8 = A) | Smart Export + Q8 ✅ SA 2026-10-29 | ✅ |
| I5 | ODI ProjectName | SS_ESIM_L2D | config `odi.project_name` | ✅ |
| I6 | ProjectCode / prefix เดิมที่ต้อง rename | SS_ESIM_L2D | config `odi.project_code` | ✅ |
| I7 | FolderName | SS_ESIM_L2D | config `odi.folder_name` | ✅ |
| I8 | PackageName | PKG_SS_ESIM_L2D | config `odi.package_name` | ✅ |
| I9 | path ไฟล์ปลายทาง | output/odi_export/PROJ_EXPORT.xml | builder md15 (build_odi_export.py) | ✅ |
| I10 | ความพร้อมของ SQL | 12 task extract ครบ (G1 PASS) · converted 10 ไฟล์ · `SQL_REVIEW` ✅ 5 · 🟡 5 · ⛔ 0 · คอมไพล์ DEV 10/10 · flag 19 PENDING ใต้ waiver W1–W3 (G2 WAIVED) | `/convert`, `/review-sql`, `/review-report` 2026-10-29 | ✅ |
| I11 | สถาปัตยกรรม Procedure / Mapping / ผสม | Procedure 1 task = 1 procedure (ADR-001) — task ต่าง technology พิจารณา Mapping แยก | ADR-001 | ✅ |
| I12 | ทาสก์ที่ implement ตรง ๆ ไม่ได้ | `999999_export_data_to_mssql` → placeholder step (Q9 = A) · `000000_recover_landing_ss_esim` → แทนด้วย variable precheck `v_max_partition` (config `replaces_tasks`) · `080000_cleanup_ss_esim_raw_temp` (table-retention, non-SQL) → DELETE ทั้งตารางตอนจบรอบ (Q10 = A) | Q9, Q10 ✅ SA 2026-10-29 · config | ⚠️ ค้างยืนยัน: export SQL Server (Q9) · ความหมาย `olderThan: -1` (Q10) |
| I13 | ลำดับ step chain | v_max_partition → v_lag_minutes → 010000 → 020000 → 030000 → 040000 → 050100 → 050200 → 050300 → 070000 → 080000 → 999999 → 090000 (999999 ก่อน 090000 ตาม DAG, K15) · ตรงกับ package ใน Studio (ภาพ Operator session 301) | `.design/03_package_flow.md`, `output/dml/_manifest.json` | ✅ |
| I14 | overwrite / append / upsert + column list | load strategy `smart` · partition: `config/partitions_check.csv` | config, D-R7 | ✅ I14 = delete_by_partition ทั้ง 3 ตาราง (020000, 040000, 070000) — SA 2026-10-29 · `config/partitions_check.csv` |
| I15 | step สถานะ (success / running / checkpoint) | 030000 `running` → 090000 `success` (overwrite ทั้งตาราง) · guard ใน 020000 `COALESCE(success, TRUE)` · checkpoint ขยับที่ 070000 · ย้ายแบบ As-Is (Q12 = A) — ความเสี่ยง append ซ้ำ = GAP-01 | raw SQL `export_workflow.json` · Q12 ✅ SA 2026-10-29 | ✅ |
| I16 | สภาพ repository ปลายทาง | ODI 14.1.2 · work repo schema `DSSDEV` (Q7) · context `DEV` · logical schema `DSS_ODI_LOG` · variables: v_max_partition, v_lag_minutes | config `odi.*`, rp00 P4 | ✅ Smart Import 2026-10-29 สร้าง project ใหม่ `SS_ESIM_L2D` (ไม่ทับ SS_ESIM14) · หลักฐาน `input/run_results/import_r1/` |
| I17 | รูปแบบ output | Smart Import XML จาก kit + เอกสารส่งมอบ (`HANDOVER.md`, table inventory) | setup_migrate.ps1 (generator = kit) | ✅ |