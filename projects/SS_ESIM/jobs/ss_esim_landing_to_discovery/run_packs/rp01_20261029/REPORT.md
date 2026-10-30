# REPORT — rp01_20261029

| Step | ผล |
|---|---|
| S1 ODI Smart Import | ⏳ |
| S2 Oracle preflight | ⏳ |
| S3 Profile | ⏳ |
| S4 ODI checklist | ⏳ |
| S5 ODI Dev run | ⏳ |
| S6 Post-run state | ⏳ |
| Assertions (S8b / S11c) | ✅ |
| Diagnose (S7) | 👁 |

## ⏳ S1 ODI Smart Import

- ยังไม่ได้รัน

## ⏳ S2 Oracle preflight

- ยังไม่ได้รัน

## ⏳ S3 Profile

- ยังไม่ได้รัน

## ⏳ S4 ODI checklist

- ยังไม่ได้ทำ (ยังไม่มีข้อไหนติ๊ก)

## ⏳ S5 ODI Dev run

- ยังไม่ได้รัน

## ⏳ S6 Post-run state

- ยังไม่ได้รัน

## ✅ Assertions (S8b / S11c)

- ไฟล์: `S7b.csv` — PASS 55/55
- ✅ C01_MAP_normal: คาด VALID/MAP · ได้ VALID/MAP (1 แถว)
- ✅ C02_UNMAP_bno_not_in_mapping: คาด TEMP/UNMAP · ได้ TEMP/UNMAP (1 แถว)
- ✅ C03_UNMAP_owner_mismatch: คาด TEMP/UNMAP · ได้ TEMP/UNMAP (1 แถว)
- ✅ C04_UNMAP_before_effective: คาด TEMP/UNMAP · ได้ TEMP/UNMAP (1 แถว)
- ✅ C05_UNMAP_after_expired: คาด TEMP/UNMAP · ได้ TEMP/UNMAP (1 แถว)
- ✅ C06_MAN_partner_NULL: คาด REJECT/MAN · ได้ REJECT/MAN (1 แถว)
- ✅ C07_MAN_sim_type_NULL: คาด REJECT/MAN · ได้ REJECT/MAN (1 แถว)
- ✅ C08_MAN_iccid_NULL: คาด REJECT/MAN · ได้ REJECT/MAN (1 แถว)
- ✅ C09_MAN_first_installed_NULL: คาด REJECT/MAN · ได้ REJECT/MAN (1 แถว)
- ✅ C10_MAN_profile_type_empty_str: คาด REJECT/MAN · ได้ REJECT/MAN (1 แถว)
- ✅ C11_UNMAP_partner_space: คาด TEMP/UNMAP · ได้ TEMP/UNMAP (1 แถว)
- ✅ C12_TYP_feb29_nonleap: คาด REJECT/TYP · ได้ REJECT/TYP (1 แถว)
- ✅ C13_TYP_month13: คาด REJECT/TYP · ได้ REJECT/TYP (1 แถว)
- ✅ C14_TYP_hour24: คาด REJECT/TYP · ได้ REJECT/TYP (1 แถว)
- ✅ C15_TYP_non_digit: คาด REJECT/TYP · ได้ REJECT/TYP (1 แถว)
- ✅ C16_MAP_first_installed_17dig: คาด VALID/MAP · ได้ VALID/MAP (1 แถว)
- ✅ C17_UNMAP_partner_lowercase: คาด TEMP/UNMAP · ได้ TEMP/UNMAP (1 แถว)
- ✅ C18A_inbatch_first_file_wins: คาด VALID/MAP · ได้ VALID/MAP (1 แถว)
- ✅ C18B_inbatch_later_file_DUP: คาด REJECT/DUP · ได้ REJECT/DUP (1 แถว)
- ✅ C19A_null_file_date_wins: คาด VALID/MAP · ได้ VALID/MAP (1 แถว)
- ✅ C19B_dup_after_null_file_date: คาด REJECT/DUP · ได้ REJECT/DUP (1 แถว)
- ✅ C20_same_file_tie_counts_only: คาด REJECT,VALID/DUP,MAP · ได้ REJECT,VALID/DUP,MAP (2 แถว)
- ✅ C21_DUP_cross_run_vs_temp: คาด REJECT/DUP · ได้ REJECT/DUP (1 แถว)
- ✅ C22_MAP_eid_NULL: คาด VALID/MAP · ได้ VALID/MAP (1 แถว)
- ✅ C23_body_tag_01_ignored: คาด '-/'- · ได้ '-/'- (0 แถว)
- ✅ C24_P2_second_partition_MAP: คาด VALID/MAP · ได้ VALID/MAP (1 แถว)
- ✅ C25_P3_deferred_beyond_300: คาด '-/'- · ได้ '-/'- (0 แถว)
- ✅ C26_future_partition_ignored: คาด '-/'- · ได้ '-/'- (0 แถว)
- ✅ C27_partition_eq_ckpt_ignored: คาด '-/'- · ได้ '-/'- (0 แถว)
- ✅ D01_C01_valid_cols: คาด VALID/Y|20260101|1|1|2026-10-29 10:00:00 · ได้ VALID/Y|20260101|1|1|2026-10-29 10:00:00 (1 แถว)
- ✅ D02_C02_temp_mapping_error: คาด TEMP/cp_id|service_id|network_type|invoicing_company_id|share_basis|#ECP_ESIM_Step#20260101 · ได้ TEMP/cp_id|service_id|network_type|invoicing_company_id|share_basis|#ECP_ESIM_Step#20260101 (1 แถว)
- ✅ D03_C06_reject_filter_error: คาด REJECT/partner|#partner is NULL| · ได้ REJECT/partner|#partner is NULL| (1 แถว)
- ✅ D04_C09_reject_MAN_not_TYP_msg: คาด REJECT/first_installed|#first_installed is NULL| · ได้ REJECT/first_installed|#first_installed is NULL| (1 แถว)
- ✅ D05_C12_reject_type_error: คาด REJECT/first_installed|#first_installed: Invalid TIMESTAMP type (Raw=20230229000000)| · ได้ REJECT/first_installed|#first_installed: Invalid TIMESTAMP type (Raw=20230229000000)| (1 แถว)
- ✅ D06_C16_valid_first_installed: คาด VALID/2026-01-01 10:00:00 · ได้ VALID/2026-01-01 10:00:00 (1 แถว)
- ✅ D07_C19A_valid_file_date_NULL: คาด VALID/NULL · ได้ VALID/NULL (1 แถว)
- ✅ D08_C11_temp_b_no_with_space: คาด TEMP/[ _ESIM_SalesT] · ได้ TEMP/[ _ESIM_SalesT] (1 แถว)
- ✅ D09_C21_reject_DUP_no_error_text: คาด REJECT/NULL#NULL · ได้ REJECT/NULL#NULL (1 แถว)
- ✅ D10_reject_partition_date_eq_process_day: คาด REJECT/0 · ได้ REJECT/0 (0 แถว)
- ✅ T01_total_valid_marker: คาด VALID/7 · ได้ VALID/7 (7 แถว)
- ✅ T02_total_temp_marker: คาด TEMP/6 · ได้ TEMP/6 (6 แถว)
- ✅ T03_total_reject_marker: คาด REJECT/13 · ได้ REJECT/13 (13 แถว)
- ✅ R01_raw_temp_empty_after_080000: คาด RAW_TEMP/0 · ได้ RAW_TEMP/0 (0 แถว)
- ✅ S01_status_after_090000: คาด WORKFLOW_STATUS/NULL|TRUE|NULL · ได้ WORKFLOW_STATUS/NULL|TRUE|NULL (1 แถว)
- ✅ K01_ckpt_max_eq_P2: คาด CHECKPOINT/202610291619 · ได้ CHECKPOINT/202610291619 (1 แถว)
- ✅ K02_ckpt_has_P1: คาด CHECKPOINT/Y · ได้ CHECKPOINT/Y (1 แถว)
- ✅ K03_ckpt_no_P3_no_PF: คาด CHECKPOINT/0 · ได้ CHECKPOINT/0 (1 แถว)
- ✅ K04_ckpt_temp_max_eq_P2: คาด CHECKPOINT_TEMP/202610291619 · ได้ CHECKPOINT_TEMP/202610291619 (1 แถว)
- ✅ K05_ckpt_temp_no_P3_no_PF: คาด CHECKPOINT_TEMP/0 · ได้ CHECKPOINT_TEMP/0 (1 แถว)
- ✅ K06_info_PE_seeded: คาด LANDING/Y_or_N · ได้ LANDING/Y_or_N (1 แถว)
- ✅ PRE_MAP_SALEST_AWN_20260101: คาด EXT_MAPPING/1 · ได้ EXT_MAPPING/1 (1 แถว)
- ✅ PRE_SALEST_AWN_not_active_20240101: คาด EXT_MAPPING/0 · ได้ EXT_MAPPING/0 (1 แถว)
- ✅ PRE_GABLE_AWN_not_active_20260101: คาด EXT_MAPPING/0 · ได้ EXT_MAPPING/0 (1 แถว)
- ✅ PRE_no_mapping_Step_3BB_odd_bno: คาด EXT_MAPPING/0 · ได้ EXT_MAPPING/0 (1 แถว)
- ✅ PRE_cdr_type_1_active: คาด EXT_CDR_TYPE/1 · ได้ EXT_CDR_TYPE/1 (1 แถว)

## 👁 Diagnose (S7)

- ไฟล์: `D1.csv`
- 1 NOW (DB SYSDATE): 2026-10-29 21:26:48
- 2 SEED_TIME_WINDOW_OK (must be Y: HH24MI >= 0515): Y
- 3 P1_IF_SEEDED_NOW (SYSDATE-310min): 202610291616
- 4 CKPT_MAX = M (COALESCE 0): 202610120900
- 5 CKPT_MAX_LT_P1 (must be Y): Y
- 6 CKPT_ROWS_TOTAL: 4
- 7 CKPT_ROWS_PARTITION_DATE_TODAY (070000 deletes these; cleanup cannot restore): 1
- 8 CKPT_TEMP_MAX: 202610120900
- 9 CKPT_TEMP_ROWS: 2
- 10 STATUS_ROWS (must be 0 or 1): 1
- 11 STATUS running|success|workflow_process_date: NULL|TRUE|NULL
- 12 STATUS_GUARD_020000_PASSES (must be Y): Y
- 13 LANDING_NONMARKER_ROWS_AFTER_M (must be 0; otherwise real rows get processed too): 0
- 14 LANDING_ROWS_AT_PARTITION_EQ_M (info): 2
- 15 LANDING_MARKER_ROWS /sa_test/rp01/ (must be 0 before seed): 0
- 16 TARGET_MARKER_ROWS valid+temp+reject+raw_temp (must be 0 before seed): 0
- 17 CHK_DUPLICATE SATRP01% in valid+temp (must be 0): 0
- 18 RAW_TEMP_ROWS_TOTAL (info; 080000 deletes the whole table): 0
- 19 LANDING sample max partition_date|hour|minute (format check): 20261012|2026101209|202610120900
- 20 CDR_TYPE 1 active in EXT_DSS_TB_MASTER_CDR_TYPE (must be 1): 1
- 30 MAPPING ECP_ESIM_SalesT / AWN: rs=A eff=2025-01-16 exp=NULL cp=10128 svc=10000049 net=3PP sb=CSH prt=NULL
- 30 MAPPING ECP_ESIM_Sales_Gable / AWN: rs=A eff=2024-01-01 exp=2025-12-31 cp=10100 svc=10000001 net=3PP sb=CSH prt=NULL
- 31 MAP_OK ECP_ESIM_SalesT/AWN active 2026-01-01 with 5 cols NOT NULL (must be 1): 1
- 32 MAP ECP_ESIM_SalesT/AWN active 2024-01-01 (must be 0): 0
- 33 MAP ECP_ESIM_Sales_Gable/AWN active 2026-01-01 (must be 0): 0
- 34 MAP rows for Step/3BB-owner/odd b_no (must be 0): 0

## ต้องทำต่อ

- [ ] Diagnose: agent อ่านค่าแล้วสรุป (diagnose ไม่มี PASS/FAIL ในตัว)

ยังไม่มีผล: S1 ODI Smart Import, S2 Oracle preflight, S3 Profile, S4 ODI checklist, S5 ODI Dev run, S6 Post-run state
