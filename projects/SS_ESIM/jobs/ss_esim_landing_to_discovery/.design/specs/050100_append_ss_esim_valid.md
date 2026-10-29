# Task spec: 050100_append_ss_esim_valid

> โครงสร้างโดย gen_design_docs.py — Claude เติม Business logic / Rules / Column mapping จาก SQL ด้วย `/design`

| รายการ | ค่า |
|---|---|
| Blendata task id | `task_d60b3f0310094ab3bdbbad1eca43e81e` |
| ODI procedure | `050100_append_ss_esim_valid` |
| Target | `DSSDEV.TB_TRANSACTION_SS_ESIM_VALID` |
| Load strategy | append (smart->sinkOption.mode=Append) |
| Upstream | 040000 |
| Raw / converted / DML | `output/sql/raw/task_d60b3f0310094ab3bdbbad1eca43e81e_050100_append_ss_esim_valid.sql` / `output/sql/converted/task_d60b3f0310094ab3bdbbad1eca43e81e_050100_append_ss_esim_valid.sql` / `output/dml/task_d60b3f0310094ab3bdbbad1eca43e81e_050100_append_ss_esim_valid.sql` |
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
| CP_ID | | |
| SERVICE_ID | | |
| BEFORE_SHARING | | |
| PRICE_RATE_TYPE | | |
| NETWORK_TYPE | | |
| INVOICING_CO_ID | | |
| SHARE_BASIS | | |
| CDR_FILENAME | | |
| CHK_DUPLICATE | | |
| FILTER_DTM | | |
| CREATE_BY | | |
| REMAP_DTM | | |
| REMAP_BY | | |
| PROCESS_DATE | | |
| TRANSACTION_UNITS | | |
| STATUS | | |
| WORKFLOW_PROCESS_DATE | | |
| FILE_DATE | | |

## Dialect changes (Spark → Oracle)
| เดิม | ใหม่ | เหตุผล |
|---|---|---|

## Test cases
| # | Input | Expected |
|---|---|---|

## Open questions
