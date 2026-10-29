# Open Decisions — ss_esim_landing_to_discovery (SS_ESIM_L2D)

รวมประเด็นที่ต้องให้ SA / ทีมตัดสินใจ — ตอบโดยใส่ X ในช่อง `[ ]` แล้วบอก Claude Code ให้อัปเดต kit ต่อ
ตัวเลือก **[แนะนำ]** คือคำแนะนำจากการวิเคราะห์ ไม่ใช่ค่าที่ตั้งไว้แล้ว

---

## Phase 0 — Environment & Config

### Q1. Landing retention
landing `tb_landing_ss_esim` เก็บย้อนหลังกี่วัน (กำหนด point of no return ของ rollback)

- [ ] A) ระบุ: ____ วัน
- [x] B) ยังไม่ทราบ — ต้องถามทีม ingestion

> **Q1 = B** ✅ SA 2026-10-29 (ตอบในแชต) · ไม่มี task ใน workflow ตั้ง retention ของ landing (มีแค่ 080000 บน raw_temp) → retention อยู่ฝั่งระบบที่เติม landing · **ค้าง:** จำนวนวันจากทีม ingestion — ต้องได้ก่อน G7 (G7.M1 backfill / rollback point of no return)

### Q2. Fail-fast เมื่อ landing ค้าง
ต้องการให้ package หยุดเมื่อ lag > 120 นาทีหรือไม่ (ต้องมี Evaluate Variable sample จาก Studio)

- [x] A) ต้องการ **[แนะนำ]**
- [ ] B) ไม่ต้อง — รันต่อแม้ landing ค้าง

> **Q2 = A (fail-fast เมื่อ `v_lag_minutes` > 120)** ✅ SA 2026-10-29 (ตอบในแชต) · ต้องได้ sample Evaluate Variable step จาก ODI Studio ก่อน `/gen-export` · เกณฑ์ 120 นาที (`precheck.landing_max_lag_minutes`) ทบทวนกับ pattern การมาของ landing จริง (ช่วงกลางคืน / วันหยุด)

### Q3. Spark config ของ Blendata (มีผลต่อความหมายของ SQL)
ข้อเท็จจริง (จากโปรเจกต์ก่อน): ค่าเหล่านี้ทำให้ผลของ SQL เดียวกันต่างกัน — `ansi.enabled` (CAST ที่แปลงไม่ได้ = error แทน NULL), `legacy.timeParserPolicy` (EXCEPTION ทำให้ workflow ล้มทั้งรอบเมื่อเจอวันที่ผิดรูป), `parser.escapedStringLiterals` (false = backslash ใน regex literal ถูกตัด → regex อาจไม่ match)
ขอทีม Blendata รันใน workspace ของ workflow นี้ แล้วกรอก:
- `SELECT version()`: ____ · `SET spark.sql.ansi.enabled`: ____ · `SET spark.sql.legacy.timeParserPolicy`: ____ · `SET spark.sql.parser.escapedStringLiterals`: ____ · `SET spark.sql.sources.partitionOverwriteMode`: ____ · `SET spark.sql.session.timeZone`: ____ · regex_test (ถ้า SQL มี regexp_replace/regexp_extract ที่มี backslash): รัน pattern จริงกับข้อความตัวอย่างบน Blendata แล้วจดผล — ใช้ตัดสินแทนการเดาจาก escapedStringLiterals (E26)
- [ ] A) ได้ค่าครบแล้ว **[แนะนำ — ต้องมีก่อนปิด Phase 4]**
- [x] B) ยังขอไม่ได้ — D1 (PySpark) รันทุกค่าที่เป็นไปได้ และถือว่ากฎถูกเฉพาะเมื่อผลตรงกันทุกแบบ

> **Q3 = B (ยังขอค่าไม่ได้)** ✅ SA 2026-10-29 (ตอบในแชต) · ผลกระทบ: D1 (PySpark) ต้องรันทุกค่าที่เป็นไปได้ · ยังต้องได้ค่าจริงก่อนปิด G2 (Phase 4) · `partitionOverwriteMode` ไม่ทราบ → I14 (DELETE เฉพาะ partition / ล้างทั้งตาราง) ของ 3 ตารางที่ sink = Overwrite + partitionBy(`partition_date`) ยังตัดสินไม่ได้: `tb_staging_ss_esim_checkpoint_temp` (020000) · `tb_staging_ss_esim_raw_temp` (040000) · `tb_staging_ss_esim_checkpoint` (070000)

### Q4. Data contract ของ landing `tb_landing_ss_esim`
ข้อเท็จจริง: landing ใน Oracle ที่ Spark JDBC สร้างมักมีชนิดต่างจาก Blendata (เช่น timestamp = TIMESTAMP(6), string = VARCHAR2(255), partition = NUMBER(19)) — กฎแปลงขึ้นกับชนิดจริง
- [x] A) ใช้ชนิดตาม `all_tab_columns` ของ Oracle Dev + ขอ `DESCRIBE` จาก Blendata มาเทียบ **[แนะนำ]**
- [ ] B) กำหนด DDL landing ใหม่เอง (ต้องแจ้งทีมที่เติม landing)
- ผู้เติม landing ใน Prod: ____

> **Q4 = A** ✅ SA 2026-10-29 (ตอบในแชต) · ชนิดจริง DEV: `FIRST_INSTALLED` VARCHAR2(100) (ใช้ใน `date_format(first_installed,'yyyyMMdd')` ของ 050100 / 050300 → ต้องรู้รูปแบบข้อความวันที่จริงเพื่อเขียน `TO_DATE` แบบ FX) · `PROCESS_DATE` TIMESTAMP(6) · `PARTITION_DATE/HOUR/MINUTE` NUMBER(19) · `RAW_DATA` CLOB · **ค้าง:** ผล `DESCRIBE tb_landing_ss_esim` จาก Blendata (ขอก่อน `/review-sql`) · ผู้เติม landing ใน Prod (ก่อน G6.M3) · คอลัมน์ที่ชนิดไม่ตรง → GAP แยกรายคอลัมน์

### Q5. Schedule และ timezone
ข้อเท็จจริง: Airflow ใช้ **UTC** เป็น default ถ้า DAG ไม่กำหนด timezone · SQL มักใช้ `SYSDATE` (เวลาของ DB server)
- cron เดิมของ DAG: ____ · timezone ของ DAG: ____ · `SELECT DBTIMEZONE, SESSIONTIMEZONE, SYSTIMESTAMP FROM dual` (Dev/Prod): ____
- ตัวเลือก schedule ใน ODI:
  - [x] A) Scenario + ODI Agent schedule + กันรอบซ้อน (Limit Concurrent Executions / guard flag) **[แนะนำ]**
  - [ ] B) Load Plan
  - [ ] C) scheduler ภายนอก (`startscen`) — ระบุ: ____

> **Q5 = A (Scenario + ODI Agent schedule `30 * * * *` + Limit Concurrent Executions = 1)** ✅ SA 2026-10-29 (ตอบในแชต) · cron เดิมจาก `export_workflow.json` `scheduleTime` = `30 * * * *` (ทุกชั่วโมง นาทีที่ 30) · **ค้าง:** timezone ของ DAG/Blendata (`session.timeZone` — Q3) เทียบ `DBTIMEZONE` / `SESSIONTIMEZONE` ของ Oracle Dev/Prod เพราะ `workflow_process_date` = `now()` → `SYSDATE`

### Q6. แจ้งเตือนและ recovery
ข้อเท็จจริง: task recover ของ Blendata (ถ้ามี) มักถูก exclude · ODI KO path แจ้งเตือนได้เฉพาะเมื่อ session เริ่มแล้ว (Agent ล่ม = เงียบ)
- ช่องทาง / SMTP: ____ · ผู้รับ WARNING: ____ · ผู้รับ CRITICAL: ____
- [x] A) OdiSendMail ใน KO path + runbook "Restart session เดิม" + missing-run check จากภายนอก **[แนะนำ]**
- [ ] B) monitoring ภายนอกอ่าน `SNP_SESSION` อย่างเดียว

> **Q6 = A** ✅ SA 2026-10-29 (ตอบในแชต) · As-Is: Blendata ปิดการแจ้งเตือนทุก task (`notifiedRunFailed*: false` ใน `export_workflow.json`) → To-Be เพิ่ม alert = GAP-04 (M) · **ค้าง:** SMTP host / ผู้ส่ง / ผู้รับ WARNING / CRITICAL · ระบบ missing-run check นอก ODI
> 2026-10-29: SA ขอข้ามค่าการส่ง mail ไปก่อน → build ใส่ OdiSendMail แบบ placeholder (ค่า SMTP / ผู้รับ = TBD) · **ต้องได้ค่าจริงก่อน G4 (Smart Import)**

### Q7. Work repository
ตาราง `SNP_*` อยู่ใน schema ของ work repository (Dev อาจเป็น `SYSTEM`) — ต้องรู้เพื่อ query log ใน Run Pack
- schema ของ work repo (Dev): `DSSDEV` · (Prod): ยังไม่ทราบ · user ที่มีสิทธิ์ SELECT: `SYSTEM`
- [x] A) กรอกครบแล้ว (ใส่ `odi.work_repo_schema` ใน config ด้วย) — บางส่วน

> **Q7 (บางส่วน)** ✅ SA 2026-10-29 (ตอบในแชต) · config `odi.work_repo_schema = "DSSDEV"` · **ข้อสังเกต:** (1) work repo อยู่ schema เดียวกับตารางงาน (`DSSDEV`) → DDL / cleanup ของงานต้องไม่แตะ `SNP_*` · (2) user ที่ query `SNP_*` = `SYSTEM` — ขัดกับ G6.M4 (Prod ห้ามใช้ user system) และไม่ควรใช้กับ Run Pack · แนะนำขอ DBA grant SELECT บน `DSSDEV.SNP_*` ให้ user read-only ของทีม · **ค้าง:** schema work repo ของ Prod (ก่อน G6)

---

## Workflow (setup_migrate) (2026-10-29)

### Q8. Schema qualification ของตารางใน step SQL (D-R2 ↔ kit odi-step-sql ข้อ 6)
ข้อเท็จจริง: คู่มือบังคับ qualify schema ทุกตาราง (`check_sql.py` D-R2 = ERROR, เคยเกิด ORA-00942 — lessons-learned L25 / เคส 19) · kit ห้าม hardcode schema (V3 ต้อง = 0 ก่อน G6) เพราะ schema ของ Prod อาจต่าง · ผล `check_sql.py` ล่าสุด: `output/verify/sql_check_converted.txt`
ยังไม่รู้: login / owner ของตารางใน SIT และ Prod เป็น user เดียวกันหรือไม่ · ตาราง external / master อยู่ schema เดียวกันหรือไม่
- [x] A) `schema_mode = odiref` ใน config — kit เติม `<%=odiRef.getSchemaName("<logical schema>","D")%>.` หน้าทุกตาราง (SELECT + ตารางปลายทางใน DML, K3) · portable ข้าม environment · ผ่าน D-R2 ไม่ต้อง waiver · ไม่ต้องแก้ generator · Run Pack ต้องแทน tag เป็น schema จริงก่อนรันใน DBeaver **[แนะนำ — ใช้จริงแล้ว SS_PAYMENT_3BB_VDO: Smart Import + Dev run ผ่าน]**
- [ ] B) `schema_mode = literal` (ค่าตั้งต้น) — hardcode `target_table_prefix` (เช่น `dssdev.`) · check_sql ผ่าน แต่ V3 FAIL และต้อง build ใหม่เมื่อ Prod ใช้ schema อื่น
- [ ] C) ไม่ qualify (ชื่อตารางเปล่า) — **kit 2.8.x ไม่รองรับ**: `convert_sql.py` / `check_inputs.py` หยุดเมื่อ prefix ว่าง → ต้องแก้ kit (K#) + บังคับ data server login = owner ทุก environment (G4.M2, G6.M4) + waiver D-R2 ใน `status/GATES.md`

> **Q8 ปิดแล้ว: A (`schema_mode = odiref`)** ✅ SA 2026-10-29 (ตอบในแชต) · ผล: `config.json` `schema_mode=odiref` + refresh_query ของ v_max_partition / v_lag_minutes ใช้ `<%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.` · ไม่ต้อง waiver D-R2

---

## Intake (2026-10-29)

### Q9. Export ไป SQL Server (task `999999_export_data_to_mssql`)
ข้อเท็จจริง: task ส่ง `tb_transaction_ss_esim_valid` (7 วันล่าสุด และ `workflow_process_date` > checkpoint ใน `ext_dss_checkpoint_tb_transaction_ss_esim_valid`) ไป SQL Server ผ่าน JDBC · Smart Export DEV มีแค่ data server Oracle (`XEPDB1`) — ไม่มี SQL Server ใน Topology
- [x] A) placeholder step ใน package (ไม่ทำอะไร มีหมายเหตุ) — ลำดับ step ครบ แต่ข้อมูลยังไม่ถึง SQL Server จนกว่าจะทำ export จริง **[แนะนำ]**
- [ ] B) step จริงไป SQL Server ในรอบนี้ (ต้องเพิ่ม data server SQL Server ใน Topology + รู้ที่อยู่ตาราง checkpoint `ext_dss_…`)
- [ ] C) ไม่ย้ายมา ODI — ระบบอื่นส่งแทน (ต้องมี business ยืนยันผู้รับผิดชอบ)

> **Q9 = A (placeholder)** ✅ SA 2026-10-29 (ตอบในแชต) · ทำตอน `/gen-export`: entry `manual: true` ใน `output/dml/_manifest.json` (ไม่มี target_table) · **ค้าง (ต้องปิดก่อน G6):** วิธี export จริง + data server SQL Server + ที่อยู่ตาราง checkpoint `ext_dss_checkpoint_tb_transaction_ss_esim_valid` + ผู้ใช้ข้อมูลฝั่ง SQL Server / ผลกระทบถ้าข้อมูลขาดช่วง

### Q10. Cleanup ตารางพัก (task `080000_cleanup_ss_esim_raw_temp`)
ข้อเท็จจริง: Blendata `service-job-table-retention` บน `tb_staging_ss_esim_raw_temp` ตั้ง `olderThan: -1` · step ที่อ่าน raw_temp (050100–050300) รันก่อน 080000 ทั้งหมด · raw_temp แบ่ง partition ตาม `partition_date` (`config/partitions_check.csv`) → TRUNCATE ทั้งตารางติด P4
- [x] A) ล้างทั้งตารางด้วย `DELETE FROM <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.tb_staging_ss_esim_raw_temp` ตอนจบรอบ **[แนะนำ]**
- [ ] B) placeholder จนกว่า Blendata ยืนยันความหมายของ `-1`
- [ ] C) TRUNCATE (ต้อง waiver P4)

> **Q10 = A (DELETE ทั้งตาราง ตอนจบรอบ)** ✅ SA 2026-10-29 (ตอบในแชต) · ทำตอน `/gen-export`: entry non-SQL ของ 080000 ใน `output/dml/_manifest.json` · สมมติฐาน: `olderThan: -1` = ล้างทั้งหมด — **ยืนยันกับทีม Blendata ก่อน G6** · เฝ้าดูเวลา DELETE ใน Dev run (ถ้าช้าเกิน batch window → พิจารณา C + waiver)

### Q11. Retry ของ step เมื่อล้ม
ข้อเท็จจริง: `export_workflow.json` ทุก task `retry: true`, `retryRound: 2`, `retryDelay: 1 minutes` ยกเว้น `999999_export_data_to_mssql` (`retry: false`) · kit `error_handling: fail-fast`
- [x] A) ตั้งเหมือน Blendata: ทุก step ใน package Number of attempts on failure = 2, Time between attempts = 60 วินาที แล้วค่อยไป KO path **[แนะนำ]**
- [ ] B) ไม่ retry — ล้มครั้งแรกหยุดทันที

> **Q11 = A (retry 2 ครั้ง × 60 วินาที ทุก step)** ✅ SA 2026-10-29 (ตอบในแชต) · ยกเว้น: placeholder 999999 (Blendata ไม่ retry) และ Evaluate Variable ของ lag precheck (Q2 — หยุดทันที ไม่ retry) · เงื่อนไข: แต่ละ step ต้อง idempotent / commit ครั้งเดียวตอนจบ — ตรวจใน `/review-sql` (Phase 4)

### Q12. Guard ของรอบที่ล้มกลางทาง (I15)
ข้อเท็จจริง: 030000 overwrite status = `running` (success = NULL) · 020000 อ่าน landing เฉพาะเมื่อ `COALESCE(success, TRUE) = TRUE` → รอบที่ล้มกลางทางไม่ทำให้รอบใหม่หยุด · ล้มหลัง 050x แต่ก่อน 070000 → append ซ้ำ (GAP-01)
- [x] A) As-Is ทุกอย่าง + บันทึก GAP-01 ให้ business รับทราบ · แก้เป็นรอบปรับปรุงแยก **[แนะนำ]**
- [ ] B) แก้ตอนย้าย (ลบ `workflow_process_date` ที่ค้างก่อน append / หยุดเมื่อรอบก่อน running)

> **Q12 = A (As-Is)** ✅ SA 2026-10-29 (ตอบในแชต) · GAP-01 disposition A · ต้องมี test case ล้มกลางทางใน Run Pack (G5)
