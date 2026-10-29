# Task spec: 040000_overwrite_ss_esim_raw_temp

> โครงสร้างโดย gen_design_docs.py — Claude เติม Business logic / Rules / Column mapping จาก SQL ด้วย `/design`

| รายการ | ค่า |
|---|---|
| Blendata task id | `task_b045fc16dd1e4272a3a28795693c2291` |
| ODI procedure | `040000_overwrite_ss_esim_raw_temp` |
| Target | `DSSDEV.TB_STAGING_SS_ESIM_RAW_TEMP` |
| Load strategy | overwrite-by-partition (I14 delete_by_partition: PARTITION_DATE) |
| Upstream | 030000 |
| Raw / converted / DML | `output/sql/raw/task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp.sql` / `output/sql/converted/task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp.sql` / `output/dml/task_b045fc16dd1e4272a3a28795693c2291_040000_overwrite_ss_esim_raw_temp.sql` |
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
| PRICE_RATE_TYPE | | |
| NETWORK_TYPE | | |
| INVOICING_CO_ID | | |
| SHARE_BASIS | | |
| CDR_FILENAME | | |
| CHK_DUPLICATE | | |
| SOURCE_PATH | | |
| FILTER_ERROR | | |
| FILTER_ERROR_MSG | | |
| TYPE_ERROR | | |
| TYPE_ERROR_MSG | | |
| MAPPING_ERROR | | |
| MAPPING_ERROR_MSG | | |
| STATUS | | |
| FILTER_DTM | | |
| B_NO | | |
| CREATE_BY | | |
| PROCESS_DATE | | |
| WORKFLOW_PROCESS_DATE | | |
| FILE_DATE | | |

## Dialect changes (Spark → Oracle)
| เดิม | ใหม่ | เหตุผล |
|---|---|---|

## Test cases
| # | Input | Expected |
|---|---|---|

## Open questions
