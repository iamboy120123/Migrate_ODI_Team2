# VERIFY REPORT — ss_esim_landing_to_discovery

Generated: 2026-10-30 16:13:07 · `python scripts/checks/verify_all.py`

## ⚠️ V4 State consistency

- ✅ MIGRATION_STATUS rev.17 (2026-10-30)
- ℹ️ OPEN_DECISIONS: 15 ข้อ · ยังเปิด 7 (Q1, Q3, Q4, Q5, Q6, Q14, Q15)
- ⚠️ Q15 ยังเปิดแต่ไม่ถูกอ้างใน MIGRATION_STATUS
- ⚠️ Q1 (Landing retention): ตัวเลือกที่ติ๊กคือยังไม่ทราบ/ยังขอไม่ได้ → ยังนับว่าเปิด
- ⚠️ Q3 (Spark config ของ Blendata (มีผ): ตัวเลือกที่ติ๊กคือยังไม่ทราบ/ยังขอไม่ได้ → ยังนับว่าเปิด
- ⚠️ Q4 (Data contract ของ landing `tb_): ติ๊กแล้วแต่ยังไม่กรอกค่า 1 บรรทัด (เช่น `- ผู้เติม landing ใน Prod: ____`) → ยังนับว่าเปิด
- ⚠️ Q5 (Schedule และ timezone): ติ๊กแล้วแต่ยังไม่กรอกค่า 1 บรรทัด (เช่น `- cron เดิมของ DAG: ____ · timezone ของ DAG: ____ · `SELECT `) → ยังนับว่าเปิด
- ⚠️ Q6 (แจ้งเตือนและ recovery): ติ๊กแล้วแต่ยังไม่กรอกค่า 1 บรรทัด (เช่น `- ช่องทาง / SMTP: ____ · ผู้รับ WARNING: ____ · ผู้รับ CRITI`) → ยังนับว่าเปิด
- ✅ PREFLIGHT 5/5
- ℹ️ ADR 3 ฉบับ · Proposed 0
- ⚠️ REVIEW_FLAGS PENDING 19 (waiver W3)
- ⚠️ PHASE4_REVIEW_LOG ยังมีรายการ OPEN: task_6451c19231b14139ab3d99b35ac9c734_020000_overwrite_ss_esim_checkpoint_temp, task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp (waiver W2)
