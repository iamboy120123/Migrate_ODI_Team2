# Task spec: 090000_success_ss_esim_landing_to_discovery_workflow_status

> โครงสร้างโดย gen_design_docs.py — Claude เติม Business logic / Rules / Column mapping จาก SQL ด้วย `/design`

| รายการ | ค่า |
|---|---|
| Blendata task id | `task_6660be16ef9e43bfbcc8974256bb27f6` |
| ODI procedure | `090000_success_ss_esim_landing_to_discovery_workflow_status` |
| Target | `DSSDEV.TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS` |
| Load strategy | overwrite (smart->sinkOption.mode=overwrite) |
| Upstream | 080000, 999999 |
| Raw / converted / DML | `output/sql/raw/task_6660be16ef9e43bfbcc8974256bb27f6_090000_success_ss_esim_landing_to_discovery_workflow_status.sql` / `output/sql/converted/task_6660be16ef9e43bfbcc8974256bb27f6_090000_success_ss_esim_landing_to_discovery_workflow_status.sql` / `output/dml/task_6660be16ef9e43bfbcc8974256bb27f6_090000_success_ss_esim_landing_to_discovery_workflow_status.sql` |
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
