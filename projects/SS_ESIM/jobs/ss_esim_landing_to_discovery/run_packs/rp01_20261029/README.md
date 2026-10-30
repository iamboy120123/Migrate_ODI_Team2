# Run Pack rp01_20261029 — ss_esim_landing_to_discovery (v2)

Updated: 2026-10-29T21:09:41 | Project `SS_ESIM_L2D` | Context `DEV` | User `DSSDEV`

**S0 (agent ทำแล้ว):** `validate_odi_xml.py` — [RESULT] ✅ ผ่าน — error 0, warn 0

- สคริปต์ SQL ทุกไฟล์เป็น **SELECT เดียว** — รันใน DBeaver / SQL Developer / sqlplus ได้ (ไม่มี SET/SPOOL แล้ว)
- ผลลัพธ์: export เป็น **CSV มี header** วางใน `input/run_results/rp01_20261029/` — **ชื่อไฟล์อะไรก็ได้** (reader จำจาก header); ภาพหน้าจอ .png ก็วางได้
- เสร็จแล้วบอก agent หรือรัน `python scripts/runpack/read_run_results.py --pack run_packs/rp01_20261029`

| Step | ที่ไหน | ทำอะไร | ผล | หยุดถ้า |
|---|---|---|---|---|
| S1 | ODI Studio | `S1_odi_smart_import.md` | Smart Export .xml | Import Actions ขึ้น Create / Create Copy |
| S2a | Oracle Dev (DSSDEV) | `S2a_create_tables_DRAFT.sql` — **เฉพาะถ้ายังไม่มีตาราง** (script หลาย statement: รันแบบ Execute Script) | — | — |
| S2b | Oracle Dev (DSSDEV) | `S2b_preflight.sql` | CSV | — |
| S2c | Oracle Dev | `S2c_compatible_optional.sql` (option — ต้องมีสิทธิ์ v$parameter) | CSV | — |
| S2d | Oracle Dev (DSSDEV) | `S2d_existing_indexes.sql` — index จริงเทียบกับที่ DDL เสนอ (unique key ของ MERGE) | CSV | — |
| S3 | Blendata | `S3a_blendata_stack_smoke_test.sql` → `S3b_blendata_profile.sql` (รวมผลทุก query เป็น CSV เดียว) | CSV | S3a error |
| S3-ALT | Oracle Dev (DSSDEV) | `S3_ALT_oracle_landing_profile.sql` — แทน S3 **หลัง landing มีข้อมูล** | CSV | landing ว่าง |
| S4 | ODI Studio | ติ๊ก `odi_checklist.md` (ในโฟลเดอร์ pack) | ไฟล์เดิม | Topology ผูกผิด schema |
| S5 | ODI Studio + work repo | `S5a_odi_dev_run.md` → `S5b_odi_session_log.sql` ด้วย **user ของ work repository** (ไม่ใช่ DSSDEV; หา schema ด้วย `S5b0_find_work_repo_schema.sql`) | CSV หรือ**ภาพ Operator** | preflight [2] [5] [7] ไม่ผ่าน |
| S6 | Oracle Dev (DSSDEV) | `S6_post_run_capture.sql` | CSV | — |
| S6b | Oracle Dev (DSSDEV) | `S6b_reset_running_flag_DEV.sql` — **เฉพาะเมื่อรอบทดสอบล้มแล้ว running = 'TRUE' ค้าง** (Dev เท่านั้น) | — | — |

## รอบทดสอบ Dev ครั้งแรกด้วยข้อมูลทดสอบ (D1 / S7a / S7b / S7c — เพิ่ม 2026-10-29, lesson E30)

ทำไม: package ที่รันบน landing ว่างได้ 0 แถว = พิสูจน์อะไรไม่ได้ — ชุดนี้ใส่ข้อมูลทดสอบที่มี marker ลบได้ (`/sa_test/rp01/%`) 1 แถวต่อ 1 เงื่อนไข แล้วตรวจผลด้วย SELECT เดียว · **ยังไม่ได้ทดสอบกับ DBeaver ของผู้ใช้**

**ข้ามขั้นของ pack ทั่วไป:** S1 (Smart Import ทำแล้ว) · **S2a ห้ามรันบน DEV** (ตารางมีอยู่แล้ว — DDL draft จะชน/ทับ) · S3 / S3-ALT ไม่ต้องใช้ในรอบนี้ · S2b / S4 ทำได้ตามปกติถ้ายังไม่เคยทำ

| ลำดับ | ที่ไหน | ไฟล์ | วิธีรัน | ผล | หยุดถ้า |
|---|---|---|---|---|---|
| T1 | Oracle Dev (DSSDEV) | `D1_diagnose.sql` | Ctrl+Enter (SELECT เดียว) | CSV `SEQ,ITEM,VALUE` | ITEM ที่เขียน `(must be ...)` ไม่ตรง |
| T2 | Oracle Dev (DSSDEV) | `S7a_seed_DEV.sql` | **Execute Script (Alt+X) ครั้งเดียว** | แถวเดียว `SEED_VERDICT` (จด `RUN_DEADLINE`) | `SEED_VERDICT` = STOP |
| T3 | ODI Studio | รัน scenario `PKG_SS_ESIM_L2D` context DEV (ตาม `S5a_odi_dev_run.md`) **ก่อน `RUN_DEADLINE` (seed + 60 นาที)** | — | Operator สถานะ Done | step ใด error → S5b + `/diagnose` |
| T4 | Oracle Dev (DSSDEV) | `S7b_assertions.sql` | Ctrl+Enter (SELECT เดียว) | CSV `TEST_CASE…RESULT` | — (ส่งผลทั้งหมดให้ agent) |
| T5 | Oracle Dev (DSSDEV) | `S7c_cleanup_DEV.sql` | **Execute Script (Alt+X)** หลัง export T4 แล้ว | แถวเดียว `*_LEFT` = 0 | ช่องใดไม่เป็น 0 |
| (T6) | Oracle Dev (DSSDEV) | `S6b_reset_running_flag_DEV.sql` | เฉพาะเมื่อ T3 ล้มแล้ว running = 'TRUE' ค้าง | — | — |

ข้อควรรู้:
- seed ได้เฉพาะเวลา 05:15–23:59 (เวลา DB) และต้องรัน T3 ภายใน 60 นาทีหลัง seed (แถว partition อนาคต +65 นาทีจะถูกหยิบถ้าช้า) · `landing_max_lag_minutes` = 120 ยังไม่บังคับเพราะ package ยังไม่มี Evaluate/precheck step
- seed ถูกกันเอง (INSERT 0 แถว) ถ้า: checkpoint เดิม >= P1 · มี marker ค้าง · status table มี > 1 แถวหรือ success ไม่ใช่ TRUE/NULL · มีแถว landing จริงหลัง checkpoint (ถ้ามี package จะประมวลผลข้อมูลจริงด้วย) · ICCID `SATRP01%` มีอยู่แล้ว
- ระหว่าง T2–T3 ห้ามมี scheduler อื่นของ workflow นี้ใน DEV มาหยิบข้อมูลไปก่อน
- expected ทั้งหมดมาจากการตีความ SQL ที่รันจริง (`output/dml/*.sql`) ซึ่งแปลจาก Spark — parity กับ Blendata ต้องยืนยันแยก (D1 ฝั่ง Blendata / Q3) · case TYP (C12–C14) และ D05 ขึ้นกับ Q3 ที่ยัง OPEN
- แถว `PRE_*` ใน S7b ตรวจ mapping จริงใน DEV (`EXT_DSS_VW_SERVICE_MAPPING_BNO_KEY`, `EXT_DSS_TB_MASTER_CDR_TYPE` — ไม่ insert ลงสองตารางนี้) · ถ้า `PRE_*` FAIL ให้ถือว่า case MAP/UNMAP ที่ FAIL เป็นเรื่องข้อมูล master ไม่ใช่ package
- cleanup คืนค่าไม่ได้: แถว checkpoint ของวันที่รันที่ค่า < MAX เดิม (070000 ลบตาม partition_date) · status table ค้างเป็น success 'TRUE' · status_temp · raw_temp ทั้งตาราง (080000) — รายละเอียดในหัวไฟล์ `S7c_cleanup_DEV.sql`
