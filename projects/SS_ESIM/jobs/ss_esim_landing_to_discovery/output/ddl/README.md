# Target DDL — DRAFT (2026-10-29T20:57:32)

⚠️ **ไม่ใช่ DDL สำหรับ production** — ที่มาของชนิดข้อมูลแต่ละคอลัมน์:

| ที่มา | จำนวนคอลัมน์ | ความน่าเชื่อถือ |
|---|---|---|
| `known` — business logic ที่รู้แน่ (status, cdr_id, partition_date, …) | 0 | สูง |
| `existing` — ตารางจริงใน Oracle (all_tab_columns, K16) | 112 | ตรงกับ Dev |
| `schema` — schema block ใน export_workflow.json | 0 | ชนิดแน่ / ความยาวยังไม่แน่ |
| `expr` — อนุมานจาก expression ใน SQL | 0 | สูง |
| `profile` — ความยาวจริงจาก `input/run_results/profile_result.csv` (+50%) | 0 | สูง (ขึ้นกับช่วงข้อมูลที่ profile) |
| `fallback` — เดาไม่ได้ ใส่ VARCHAR2(4000) | 0 | **ต้องแก้** |

⏳ ยังไม่มี `input/run_results/profile_result.csv` — รัน `03_profile_source_lengths.sql` ฝั่ง Blendata แล้ว export ผลเป็น CSV

## ขั้นตอน

1. รัน `03_profile_source_lengths.sql` ฝั่ง Blendata → ได้ความยาวจริง
2. แทน `VARCHAR2(4000)` ที่มี `-- TODO` ด้วยความยาวจริง (+ เผื่อ margin)
3. ให้ DBA review เรื่อง tablespace / partition / index / NOT NULL constraint
4. รัน `01_create_tables.sql`

## สิ่งที่ DDL นี้ **ไม่ได้** กำหนดให้ (ต้องตัดสินใจเอง)

- `NOT NULL` / `PRIMARY KEY` / `FOREIGN KEY` — kit ไม่รู้ business constraint
- tablespace, storage, compression
- partition จริง (มีแต่ comment แนะนำจาก partition ฝั่ง Blendata)
- index อื่นนอกจาก unique index ของ merge key และ lookup index ด้านล่าง (เช่น local index เมื่อทำ partition จริง)
- 0 external object ที่ SQL อ้างถึงแต่ไม่ได้สร้างที่นี่: 

## Lookup index (generate จาก SQL ของ task อื่นที่อ่านตาราง append/merge ย้อนกลับทุก run)

| ตาราง | คอลัมน์ | index | ใช้เป็น | task |
|---|---|---|---|---|

⚠️ 040000 dedup เทียบ `CHK_DUPLICATE` กับ **ทั้ง history** ของ valid ∪ temp (ไม่มีขอบเขตเวลา) — index ช่วยได้ระดับหนึ่ง แต่ runtime ยังโตตาม history ต้องวัดใน parallel run (CUTOVER_RUNBOOK K1)

## รายคอลัมน์

| ตาราง | คอลัมน์ | ชนิด | ที่มา | สถานะ | หมายเหตุ |
|---|---|---|---|---|---|
| TB_STAGING_SS_ESIM_CHECKPOINT | PARTITION_DATE | NUMBER(19) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_CHECKPOINT | CHECKPOINT_PARTITION | NUMBER(19) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_CHECKPOINT | PROCESS_DATE | TIMESTAMP(6) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_CHECKPOINT_TEMP | PARTITION_DATE | NUMBER(19) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_CHECKPOINT_TEMP | CHECKPOINT_PARTITION | NUMBER(19) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_CHECKPOINT_TEMP | PROCESS_DATE | TIMESTAMP(6) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS | RUNNING | VARCHAR2(5) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS | WORKFLOW_PROCESS_DATE | VARCHAR2(14) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS | SUCCESS | VARCHAR2(5) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS_TEMP | SUCCESS | VARCHAR2(20) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_RAW_TEMP | PARTITION_DATE | NUMBER(19) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_RAW_TEMP | CDR_ID | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_RAW_TEMP | CDR_TYPE | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_RAW_TEMP | PARTNER | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_RAW_TEMP | OWNER | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_RAW_TEMP | ICCID | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_RAW_TEMP | FIRST_INSTALLED | TIMESTAMP(6) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_RAW_TEMP | PROFILE_TYPE | VARCHAR2(20) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_RAW_TEMP | EID | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_RAW_TEMP | SIM_TYPE | VARCHAR2(20) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_RAW_TEMP | CP_ID | VARCHAR2(20) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_RAW_TEMP | SERVICE_ID | NUMBER(10) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_RAW_TEMP | PRICE_RATE_TYPE | VARCHAR2(20) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_RAW_TEMP | NETWORK_TYPE | VARCHAR2(20) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_RAW_TEMP | INVOICING_CO_ID | VARCHAR2(20) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_RAW_TEMP | SHARE_BASIS | VARCHAR2(20) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_RAW_TEMP | CDR_FILENAME | VARCHAR2(255) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_RAW_TEMP | CHK_DUPLICATE | VARCHAR2(255) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_RAW_TEMP | SOURCE_PATH | VARCHAR2(500) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_RAW_TEMP | FILTER_ERROR | VARCHAR2(100) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_RAW_TEMP | FILTER_ERROR_MSG | VARCHAR2(2000) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_RAW_TEMP | TYPE_ERROR | VARCHAR2(100) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_RAW_TEMP | TYPE_ERROR_MSG | VARCHAR2(2000) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_RAW_TEMP | MAPPING_ERROR | VARCHAR2(100) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_RAW_TEMP | MAPPING_ERROR_MSG | VARCHAR2(2000) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_RAW_TEMP | STATUS | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_RAW_TEMP | FILTER_DTM | TIMESTAMP(6) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_RAW_TEMP | B_NO | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_RAW_TEMP | CREATE_BY | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_RAW_TEMP | PROCESS_DATE | TIMESTAMP(6) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_RAW_TEMP | WORKFLOW_PROCESS_DATE | VARCHAR2(14) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_STAGING_SS_ESIM_RAW_TEMP | FILE_DATE | TIMESTAMP(6) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_REJECT | PARTITION_DATE | NUMBER(19) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_REJECT | CDR_ID | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_REJECT | CDR_TYPE | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_REJECT | PARTNER | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_REJECT | OWNER | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_REJECT | ICCID | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_REJECT | FIRST_INSTALLED | TIMESTAMP(6) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_REJECT | PROFILE_TYPE | VARCHAR2(20) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_REJECT | EID | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_REJECT | SIM_TYPE | VARCHAR2(20) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_REJECT | CDR_FILENAME | VARCHAR2(255) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_REJECT | CHK_DUPLICATE | VARCHAR2(255) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_REJECT | CDR_SOURCE_PATH | VARCHAR2(500) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_REJECT | FILTER_DTM | TIMESTAMP(6) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_REJECT | CREATE_BY | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_REJECT | PROCESS_DATE | TIMESTAMP(6) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_REJECT | STATUS | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_REJECT | FILTER_ERROR | VARCHAR2(1000) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_REJECT | ERR_MSG | VARCHAR2(2000) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_REJECT | WORKFLOW_PROCESS_DATE | VARCHAR2(14) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_TEMP | PARTITION_DATE | NUMBER(19) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_TEMP | CDR_ID | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_TEMP | CDR_TYPE | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_TEMP | PARTNER | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_TEMP | OWNER | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_TEMP | ICCID | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_TEMP | FIRST_INSTALLED | TIMESTAMP(6) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_TEMP | PROFILE_TYPE | VARCHAR2(20) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_TEMP | EID | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_TEMP | SIM_TYPE | VARCHAR2(20) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_TEMP | CDR_FILENAME | VARCHAR2(255) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_TEMP | CHK_DUPLICATE | VARCHAR2(255) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_TEMP | CDR_SOURCE_PATH | VARCHAR2(500) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_TEMP | FILTER_DTM | TIMESTAMP(6) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_TEMP | CREATE_BY | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_TEMP | PROCESS_DATE | TIMESTAMP(6) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_TEMP | STATUS | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_TEMP | B_NO | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_TEMP | MAPPING_ERROR | VARCHAR2(1000) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_TEMP | ERR_MSG | VARCHAR2(2000) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_TEMP | WORKFLOW_PROCESS_DATE | VARCHAR2(14) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_TEMP | FILE_DATE | TIMESTAMP(6) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_VALID | PARTITION_DATE | NUMBER(19) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_VALID | CDR_ID | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_VALID | CDR_TYPE | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_VALID | PARTNER | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_VALID | OWNER | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_VALID | ICCID | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_VALID | FIRST_INSTALLED | TIMESTAMP(6) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_VALID | PROFILE_TYPE | VARCHAR2(20) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_VALID | EID | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_VALID | SIM_TYPE | VARCHAR2(20) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_VALID | CP_ID | VARCHAR2(20) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_VALID | SERVICE_ID | NUMBER(10) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_VALID | BEFORE_SHARING | NUMBER(18,6) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_VALID | PRICE_RATE_TYPE | VARCHAR2(20) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_VALID | NETWORK_TYPE | VARCHAR2(20) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_VALID | INVOICING_CO_ID | VARCHAR2(20) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_VALID | SHARE_BASIS | VARCHAR2(20) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_VALID | CDR_FILENAME | VARCHAR2(255) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_VALID | CHK_DUPLICATE | VARCHAR2(255) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_VALID | FILTER_DTM | TIMESTAMP(6) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_VALID | CREATE_BY | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_VALID | REMAP_DTM | TIMESTAMP(6) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_VALID | REMAP_BY | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_VALID | PROCESS_DATE | TIMESTAMP(6) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_VALID | TRANSACTION_UNITS | VARCHAR2(20) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_VALID | STATUS | VARCHAR2(50) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_VALID | WORKFLOW_PROCESS_DATE | VARCHAR2(14) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
| TB_TRANSACTION_SS_ESIM_VALID | FILE_DATE | TIMESTAMP(6) | existing | ยืนยันแล้ว | ชนิดจริงใน Oracle (all_tab_columns) |
