# 04 — Task Mapping: Blendata → ODI

ส่วน AUTO สร้างจาก manifest ด้วย `python scripts/pipeline/gen_design_docs.py` — หมายเหตุเพิ่มเติมเขียนใต้ block

<!-- AUTO:BEGIN -->
_สร้างโดย gen_design_docs.py 2026-10-30 13:05_

- Workflow: `SS_ESIM_L2D` · schedule (Blendata): `30 * * * *`
- task ทั้งหมด 12 · procedure 11 · variable 1 · excluded 0 · pending 0

| # | Code | Blendata task | Kind / sink | Upstream | ODI | Target | Strategy | Spec |
|---|---|---|---|---|---|---|---|---|
| 1 | 000000 | 000000_recover_landing_ss_esim | non_sql/ | - | ODI variable | tb_landing_ss_esim | - | - |
| 2 | 010000 | 010000_check_success_ss_esim_landing_to_discovery_workflow_status | aggregate/Overwrite | 000000 | `010000_check_success_ss_esim_landing_to_discovery_workflow_status` | DSSDEV.TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS_TEMP | overwrite (smart->sinkOption.mode=overwrite) | [spec](specs/010000_check_success_ss_esim_landing_to_discovery_workflow_status.md) |
| 3 | 020000 | 020000_overwrite_ss_esim_checkpoint_temp | aggregate/Overwrite | 010000 | `020000_overwrite_ss_esim_checkpoint_temp` | DSSDEV.TB_STAGING_SS_ESIM_CHECKPOINT_TEMP | overwrite-by-partition (I14 delete_by_partition: PARTITION_DATE) | [spec](specs/020000_overwrite_ss_esim_checkpoint_temp.md) |
| 4 | 030000 | 030000_running_ss_esim_landing_to_discovery_workflow_status | aggregate/Overwrite | 020000 | `030000_running_ss_esim_landing_to_discovery_workflow_status` | DSSDEV.TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS | overwrite (smart->sinkOption.mode=overwrite) | [spec](specs/030000_running_ss_esim_landing_to_discovery_workflow_status.md) |
| 5 | 040000 | 040000_overwrite_ss_esim_raw_temp | aggregate/Overwrite | 030000 | `040000_overwrite_ss_esim_raw_temp` | DSSDEV.TB_STAGING_SS_ESIM_RAW_TEMP | overwrite-by-partition (I14 delete_by_partition: PARTITION_DATE) | [spec](specs/040000_overwrite_ss_esim_raw_temp.md) |
| 6 | 050100 | 050100_append_ss_esim_valid | aggregate/Append | 040000 | `050100_append_ss_esim_valid` | DSSDEV.TB_TRANSACTION_SS_ESIM_VALID | append (smart->sinkOption.mode=Append) | [spec](specs/050100_append_ss_esim_valid.md) |
| 7 | 050200 | 050200_append_ss_esim_reject | aggregate/Append | 040000 | `050200_append_ss_esim_reject` | DSSDEV.TB_TRANSACTION_SS_ESIM_REJECT | append (smart->sinkOption.mode=Append) | [spec](specs/050200_append_ss_esim_reject.md) |
| 8 | 050300 | 050300_append_ss_esim_temp | aggregate/Append | 040000 | `050300_append_ss_esim_temp` | DSSDEV.TB_TRANSACTION_SS_ESIM_TEMP | append (smart->sinkOption.mode=Append, keyColumns=cdr_id ignored) | [spec](specs/050300_append_ss_esim_temp.md) |
| 9 | 070000 | 070000_overwrite_ss_esim_checkpoint | aggregate/Overwrite | 050200, 050300, 050100 | `070000_overwrite_ss_esim_checkpoint` | DSSDEV.TB_STAGING_SS_ESIM_CHECKPOINT | overwrite-by-partition (I14 delete_by_partition: PARTITION_DATE) | [spec](specs/070000_overwrite_ss_esim_checkpoint.md) |
| 10 | 080000 | 080000_cleanup_ss_esim_raw_temp | non_sql/ | 070000 | `080000_cleanup_ss_esim_raw_temp` | DSSDEV.TB_STAGING_SS_ESIM_RAW_TEMP | cleanup DELETE ทั้งตาราง (Q10 = A) | [spec](specs/080000_cleanup_ss_esim_raw_temp.md) |
| 11 | 999999 | 999999_export_data_to_mssql | export_jdbc/append | 070000 | `999999_export_data_to_mssql` | - | placeholder no-op (Q9 = A, GAP-02) | [spec](specs/999999_export_data_to_mssql.md) |
| 12 | 090000 | 090000_success_ss_esim_landing_to_discovery_workflow_status | aggregate/Overwrite | 080000, 999999 | `090000_success_ss_esim_landing_to_discovery_workflow_status` | DSSDEV.TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS | overwrite (smart->sinkOption.mode=overwrite) | [spec](specs/090000_success_ss_esim_landing_to_discovery_workflow_status.md) |
<!-- AUTO:END -->

## หมายเหตุ
