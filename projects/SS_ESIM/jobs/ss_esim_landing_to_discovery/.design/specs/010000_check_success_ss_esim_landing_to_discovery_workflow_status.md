# Task spec: 010000_check_success_ss_esim_landing_to_discovery_workflow_status

> โครงสร้างโดย gen_design_docs.py — Claude เติม Business logic / Rules / Column mapping จาก SQL ด้วย `/design`

| รายการ | ค่า |
|---|---|
| Blendata task id | `task_cc72e06e0d2b4dc29d37f72e1c729d1d` |
| ODI procedure | `010000_check_success_ss_esim_landing_to_discovery_workflow_status` |
| Target | `DSSDEV.TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS_TEMP` |
| Load strategy | overwrite (smart->sinkOption.mode=overwrite) |
| Upstream | 000000 |
| Raw / converted / DML | `output/sql/raw/task_cc72e06e0d2b4dc29d37f72e1c729d1d_010000_check_success_ss_esim_landing_to_discovery_workflow_status.sql` / `output/sql/converted/task_cc72e06e0d2b4dc29d37f72e1c729d1d_010000_check_success_ss_esim_landing_to_discovery_workflow_status.sql` / `output/dml/task_cc72e06e0d2b4dc29d37f72e1c729d1d_010000_check_success_ss_esim_landing_to_discovery_workflow_status.sql` |
| Steps | STEP_1_TRUNCATE, STEP_2_INSERT |

## Business logic
_(เติมจาก SQL)_

## Rules
| # | Rule | ที่มา (บรรทัด SQL) |
|---|---|---|

## Column mapping
| Target column | ที่มา / expression | หมายเหตุ |
|---|---|---|
| SUCCESS | | |

## Dialect changes (Spark → Oracle)
| เดิม | ใหม่ | เหตุผล |
|---|---|---|

## Test cases
| # | Input | Expected |
|---|---|---|

## Open questions
