# 03 — ODI Package Flow: PKG_SS_ESIM_L2D

ส่วน AUTO สร้างจาก `output/dml/_manifest.json` + `config/config.json` ด้วย `python scripts/pipeline/gen_design_docs.py`

<!-- AUTO:BEGIN -->
_สร้างโดย gen_design_docs.py 2026-10-29 18:13_

Package: `PKG_SS_ESIM_L2D` · Project: `SS_ESIM_L2D` · Logical schema: `DSS_ODI_LOG` / context `DEV`

| Seq | Type | Step | รายละเอียด | Target / query |
|---|---|---|---|---|
| 1 | Variable | `v_max_partition` | Refresh Variable | SELECT NVL(MAX(partition_minute), 0) FROM <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.tb_landing_ss_esim |
| 2 | Variable | `v_lag_minutes` | Refresh Variable | SELECT NVL(ROUND((SYSDATE - TO_DATE(TO_CHAR(MAX(partition_minute)), 'YYYYMMDDHH24MI')) * 1440), 999999) FROM <%=odiRef.getSchemaName("DSS_ODI_LOG","D")%>.tb_landing_ss_esim |
| 3 | Procedure | `010000_check_success_ss_esim_landing_to_discovery_workflow_status` | STEP_1_TRUNCATE, STEP_2_INSERT | DSSDEV.TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS_TEMP |
| 4 | Procedure | `020000_overwrite_ss_esim_checkpoint_temp` | STEP_1_DELETE, STEP_2_INSERT | DSSDEV.TB_STAGING_SS_ESIM_CHECKPOINT_TEMP |
| 5 | Procedure | `030000_running_ss_esim_landing_to_discovery_workflow_status` | STEP_1_TRUNCATE, STEP_2_INSERT | DSSDEV.TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS |
| 6 | Procedure | `040000_overwrite_ss_esim_raw_temp` | STEP_1_DELETE, STEP_2_INSERT | DSSDEV.TB_STAGING_SS_ESIM_RAW_TEMP |
| 7 | Procedure | `050100_append_ss_esim_valid` | STEP_1_INSERT | DSSDEV.TB_TRANSACTION_SS_ESIM_VALID |
| 8 | Procedure | `050200_append_ss_esim_reject` | STEP_1_INSERT | DSSDEV.TB_TRANSACTION_SS_ESIM_REJECT |
| 9 | Procedure | `050300_append_ss_esim_temp` | STEP_1_INSERT | DSSDEV.TB_TRANSACTION_SS_ESIM_TEMP |
| 10 | Procedure | `070000_overwrite_ss_esim_checkpoint` | STEP_1_DELETE, STEP_2_INSERT | DSSDEV.TB_STAGING_SS_ESIM_CHECKPOINT |
| 11 | Procedure | `080000_cleanup_ss_esim_raw_temp` | STEP_1_DELETE | DSSDEV.TB_STAGING_SS_ESIM_RAW_TEMP |
| 12 | Procedure | `090000_success_ss_esim_landing_to_discovery_workflow_status` | STEP_1_TRUNCATE, STEP_2_INSERT | DSSDEV.TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS |
| 13 | Procedure | `999999_export_data_to_mssql` | STEP_1_PLACEHOLDER | - |

```mermaid
flowchart TD
  START([start])
  S1[/"1. v_max_partition"/]
  START --> S1
  S2[/"2. v_lag_minutes"/]
  S1 --> S2
  S3["3. 010000_check_success_ss_esim_landing_to_discovery_workflow_status"]
  S2 --> S3
  S4["4. 020000_overwrite_ss_esim_checkpoint_temp"]
  S3 --> S4
  S5["5. 030000_running_ss_esim_landing_to_discovery_workflow_status"]
  S4 --> S5
  S6["6. 040000_overwrite_ss_esim_raw_temp"]
  S5 --> S6
  S7["7. 050100_append_ss_esim_valid"]
  S6 --> S7
  S8["8. 050200_append_ss_esim_reject"]
  S7 --> S8
  S9["9. 050300_append_ss_esim_temp"]
  S8 --> S9
  S10["10. 070000_overwrite_ss_esim_checkpoint"]
  S9 --> S10
  S11["11. 080000_cleanup_ss_esim_raw_temp"]
  S10 --> S11
  S12["12. 090000_success_ss_esim_landing_to_discovery_workflow_status"]
  S11 --> S12
  S13["13. 999999_export_data_to_mssql"]
  S12 --> S13
  OK([success])
  S13 --> OK
  FAIL([fail: package หยุด])
  S1 -. error .-> FAIL
  S2 -. error .-> FAIL
  S3 -. error .-> FAIL
  S4 -. error .-> FAIL
  S5 -. error .-> FAIL
  S6 -. error .-> FAIL
  S7 -. error .-> FAIL
  S8 -. error .-> FAIL
  S9 -. error .-> FAIL
  S10 -. error .-> FAIL
  S11 -. error .-> FAIL
  S12 -. error .-> FAIL
  S13 -. error .-> FAIL
```
<!-- AUTO:END -->

## Error / restart behaviour

| สถานการณ์ | ผล | วิธี restart |
|---|---|---|
| step ใด fail | package หยุด (fail-fast) | แก้สาเหตุ → รัน package ใหม่ทั้งหมด (idempotent?) _(ยืนยัน)_ |
| landing ค้าง | _(ขึ้นกับ Evaluate step — ดู OPEN_DECISIONS)_ | |
