# Task spec: 050200_append_ss_esim_reject

> โครงสร้างโดย gen_design_docs.py — Claude เติม Business logic / Rules / Column mapping จาก SQL ด้วย `/design`

| รายการ | ค่า |
|---|---|
| Blendata task id | `task_081c89ad18764c6ebe7fb2f7ed84d433` |
| ODI procedure | `050200_append_ss_esim_reject` |
| Target | `DSSDEV.TB_TRANSACTION_SS_ESIM_REJECT` |
| Load strategy | append (smart->sinkOption.mode=Append) |
| Upstream | 040000 |
| Raw / converted / DML | `output/sql/raw/task_081c89ad18764c6ebe7fb2f7ed84d433_050200_append_ss_esim_reject.sql` / `output/sql/converted/task_081c89ad18764c6ebe7fb2f7ed84d433_050200_append_ss_esim_reject.sql` / `output/dml/task_081c89ad18764c6ebe7fb2f7ed84d433_050200_append_ss_esim_reject.sql` |
| Steps | STEP_1_INSERT |

## Business logic
_(เติมจาก SQL)_

## Rules
| # | Rule | ที่มา (บรรทัด SQL) |
|---|---|---|

## Column mapping
| Target column | ที่มา / expression | หมายเหตุ |
|---|---|---|
| PARTITION_DATE | | |
| CDR_ID | | |
| CDR_TYPE | | |
| PARTNER | | |
| OWNER | | |
| ICCID | | |
| FIRST_INSTALLED | | |
| PROFILE_TYPE | | |
| EID | | |
| SIM_TYPE | | |
| CDR_FILENAME | | |
| CHK_DUPLICATE | | |
| CDR_SOURCE_PATH | | |
| FILTER_DTM | | |
| CREATE_BY | | |
| PROCESS_DATE | | |
| STATUS | | |
| FILTER_ERROR | | |
| ERR_MSG | | |
| WORKFLOW_PROCESS_DATE | | |

## Dialect changes (Spark → Oracle)
| เดิม | ใหม่ | เหตุผล |
|---|---|---|

## Test cases
| # | Input | Expected |
|---|---|---|

## Open questions
