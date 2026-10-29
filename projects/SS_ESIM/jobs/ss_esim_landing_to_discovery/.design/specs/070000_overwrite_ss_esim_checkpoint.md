# Task spec: 070000_overwrite_ss_esim_checkpoint

> โครงสร้างโดย gen_design_docs.py — Claude เติม Business logic / Rules / Column mapping จาก SQL ด้วย `/design`

| รายการ | ค่า |
|---|---|
| Blendata task id | `task_8e949825ccb24a1eadf8c8d0f19bdf2b` |
| ODI procedure | `070000_overwrite_ss_esim_checkpoint` |
| Target | `DSSDEV.TB_STAGING_SS_ESIM_CHECKPOINT` |
| Load strategy | overwrite-by-partition (I14 delete_by_partition: PARTITION_DATE) |
| Upstream | 050200, 050300, 050100 |
| Raw / converted / DML | `output/sql/raw/task_8e949825ccb24a1eadf8c8d0f19bdf2b_070000_overwrite_ss_esim_checkpoint.sql` / `output/sql/converted/task_8e949825ccb24a1eadf8c8d0f19bdf2b_070000_overwrite_ss_esim_checkpoint.sql` / `output/dml/task_8e949825ccb24a1eadf8c8d0f19bdf2b_070000_overwrite_ss_esim_checkpoint.sql` |
| Steps | STEP_1_DELETE, STEP_2_INSERT |

## Business logic
_(เติมจาก SQL)_

## Rules
| # | Rule | ที่มา (บรรทัด SQL) |
|---|---|---|

## Column mapping
| Target column | ที่มา / expression | หมายเหตุ |
|---|---|---|
| PARTITION_DATE | | |
| CHECKPOINT_PARTITION | | |
| PROCESS_DATE | | |

## Dialect changes (Spark → Oracle)
| เดิม | ใหม่ | เหตุผล |
|---|---|---|

## Test cases
| # | Input | Expected |
|---|---|---|

## Open questions
