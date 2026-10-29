# Task spec: 080000_cleanup_ss_esim_raw_temp

> โครงสร้างโดย gen_design_docs.py — Claude เติม Business logic / Rules / Column mapping จาก SQL ด้วย `/design`

| รายการ | ค่า |
|---|---|
| Blendata task id | `task_0a7791409dbc4c789e892d888f5e1a51` |
| ODI procedure | `080000_cleanup_ss_esim_raw_temp` |
| Target | `DSSDEV.TB_STAGING_SS_ESIM_RAW_TEMP` |
| Load strategy | cleanup DELETE ทั้งตาราง (Q10 = A) |
| Upstream | 070000 |
| Raw / converted / DML | `None` / `-` / `output/dml/task_0a7791409dbc4c789e892d888f5e1a51_080000_cleanup_ss_esim_raw_temp.sql` |
| Steps | STEP_1_DELETE |

## Business logic
_(เติมจาก SQL)_

## Rules
| # | Rule | ที่มา (บรรทัด SQL) |
|---|---|---|

## Column mapping
| Target column | ที่มา / expression | หมายเหตุ |
|---|---|---|

## Dialect changes (Spark → Oracle)
| เดิม | ใหม่ | เหตุผล |
|---|---|---|

## Test cases
| # | Input | Expected |
|---|---|---|

## Open questions
