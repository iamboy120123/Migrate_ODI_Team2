# Task spec: 020000_overwrite_ss_esim_checkpoint_temp

> โครงสร้างโดย gen_design_docs.py — Claude เติม Business logic / Rules / Column mapping จาก SQL ด้วย `/design`

| รายการ | ค่า |
|---|---|
| Blendata task id | `task_6451c19231b14139ab3d99b35ac9c734` |
| ODI procedure | `020000_overwrite_ss_esim_checkpoint_temp` |
| Target | `DSSDEV.TB_STAGING_SS_ESIM_CHECKPOINT_TEMP` |
| Load strategy | overwrite-by-partition (I14 delete_by_partition: PARTITION_DATE) |
| Upstream | 010000 |
| Raw / converted / DML | `output/sql/raw/task_6451c19231b14139ab3d99b35ac9c734_020000_overwrite_ss_esim_checkpoint_temp.sql` / `output/sql/converted/task_6451c19231b14139ab3d99b35ac9c734_020000_overwrite_ss_esim_checkpoint_temp.sql` / `output/dml/task_6451c19231b14139ab3d99b35ac9c734_020000_overwrite_ss_esim_checkpoint_temp.sql` |
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
