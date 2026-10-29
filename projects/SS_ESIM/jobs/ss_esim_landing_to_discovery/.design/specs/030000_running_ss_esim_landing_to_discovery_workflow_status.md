# Task spec: 030000_running_ss_esim_landing_to_discovery_workflow_status

> โครงสร้างโดย gen_design_docs.py — Claude เติม Business logic / Rules / Column mapping จาก SQL ด้วย `/design`

| รายการ | ค่า |
|---|---|
| Blendata task id | `task_1b899dbbbe54449d8218e58bed2a044f` |
| ODI procedure | `030000_running_ss_esim_landing_to_discovery_workflow_status` |
| Target | `DSSDEV.TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS` |
| Load strategy | overwrite (smart->sinkOption.mode=overwrite) |
| Upstream | 020000 |
| Raw / converted / DML | `output/sql/raw/task_1b899dbbbe54449d8218e58bed2a044f_030000_running_ss_esim_landing_to_discovery_workflow_status.sql` / `output/sql/converted/task_1b899dbbbe54449d8218e58bed2a044f_030000_running_ss_esim_landing_to_discovery_workflow_status.sql` / `output/dml/task_1b899dbbbe54449d8218e58bed2a044f_030000_running_ss_esim_landing_to_discovery_workflow_status.sql` |
| Steps | STEP_1_TRUNCATE, STEP_2_INSERT |

## Business logic
_(เติมจาก SQL)_

## Rules
| # | Rule | ที่มา (บรรทัด SQL) |
|---|---|---|

## Column mapping
| Target column | ที่มา / expression | หมายเหตุ |
|---|---|---|
| RUNNING | | |
| WORKFLOW_PROCESS_DATE | | |

## Dialect changes (Spark → Oracle)
| เดิม | ใหม่ | เหตุผล |
|---|---|---|

## Test cases
| # | Input | Expected |
|---|---|---|

## Open questions
