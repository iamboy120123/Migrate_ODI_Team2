# Task spec: 050300_append_ss_esim_temp

> โครงสร้างโดย gen_design_docs.py — Claude เติม Business logic / Rules / Column mapping จาก SQL ด้วย `/design`

| รายการ | ค่า |
|---|---|
| Blendata task id | `task_17e9202f814842e3b6d91fabe785f479` |
| ODI procedure | `050300_append_ss_esim_temp` |
| Target | `DSSDEV.TB_TRANSACTION_SS_ESIM_TEMP` |
| Load strategy | append (smart->sinkOption.mode=Append, keyColumns=cdr_id ignored) |
| Upstream | 040000 |
| Raw / converted / DML | `output/sql/raw/task_17e9202f814842e3b6d91fabe785f479_050300_append_ss_esim_temp.sql` / `output/sql/converted/task_17e9202f814842e3b6d91fabe785f479_050300_append_ss_esim_temp.sql` / `output/dml/task_17e9202f814842e3b6d91fabe785f479_050300_append_ss_esim_temp.sql` |
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
| B_NO | | |
| MAPPING_ERROR | | |
| ERR_MSG | | |
| WORKFLOW_PROCESS_DATE | | |
| FILE_DATE | | |

## Dialect changes (Spark → Oracle)
| เดิม | ใหม่ | เหตุผล |
|---|---|---|

## Test cases
| # | Input | Expected |
|---|---|---|

## Open questions
