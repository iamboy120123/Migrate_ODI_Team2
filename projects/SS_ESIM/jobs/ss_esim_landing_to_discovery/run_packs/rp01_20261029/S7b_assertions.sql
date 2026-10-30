-- ============================================================
-- S7b_assertions.sql  (rp01_20261029 / SS_ESIM_L2D)  -- Oracle DEV, user DSSDEV
-- SELECT เดียว -> Ctrl+Enter -> export CSV (มี header) ไป input/run_results/rp01_20261029/
-- รัน "หลัง" scenario PKG_SS_ESIM_L2D จบ (และก่อน S7c_cleanup_DEV.sql)
-- คอลัมน์: TEST_CASE, EXP_TBL, EXP_STATUS, ROWS_FOUND, ACT_TBL, ACT_STATUS, RESULT, NOTE
--   C..  = 1 case ต่อ 1 เงื่อนไข (ค้นด้วย EID ที่ seed ใส่ หรือ ICCID ถ้า EID ว่าง)
--   D..  = ค่าคอลัมน์ของแถวที่สำคัญ (EXP_STATUS = ค่าที่คาด, ACT_STATUS = ค่าจริง)
--   K/S/R/T = checkpoint / status table / raw_temp / ยอดรวม
--   PRE.. = เงื่อนไขของ mapping ใน DEV ที่ expected ของ MAP/UNMAP พึ่งอยู่ (ถ้า PRE FAIL -> case MAP/UNMAP ที่ FAIL ไม่ใช่ความผิด package)
-- expected มาจากการตีความ SQL ที่รันจริง (output/dml/*.sql) ซึ่งแปลมาจาก Spark — ยืนยัน parity กับ Blendata ด้วย D1 ฝั่ง Blendata
-- ยังไม่ได้ทดสอบกับ DBeaver ของผู้ใช้
-- ============================================================
WITH
mk AS (
  SELECT eid, partition_minute AS pm
  FROM DSSDEV.TB_LANDING_SS_ESIM
  WHERE input_source_name LIKE '/sa\_test/rp01/%' ESCAPE '\'
),
pp AS (
  SELECT MAX(CASE WHEN eid = 'SAT01' THEN pm END) AS p1,
         MAX(CASE WHEN eid = 'SAT24' THEN pm END) AS p2,
         MAX(CASE WHEN eid = 'SAT25' THEN pm END) AS p3,
         MAX(CASE WHEN eid = 'SAT26' THEN pm END) AS pf,
         MAX(CASE WHEN eid = 'SAT27' THEN pm END) AS pe
  FROM mk
),
a AS (
  SELECT 'VALID' AS tbl, status, eid, iccid FROM DSSDEV.TB_TRANSACTION_SS_ESIM_VALID
   WHERE cdr_filename LIKE '/sa\_test/rp01/%' ESCAPE '\'
  UNION ALL
  SELECT 'TEMP', status, eid, iccid FROM DSSDEV.TB_TRANSACTION_SS_ESIM_TEMP
   WHERE cdr_filename LIKE '/sa\_test/rp01/%' ESCAPE '\' AND cdr_filename NOT LIKE '%/PRESEED\_%' ESCAPE '\'
  UNION ALL
  SELECT 'REJECT', status, eid, iccid FROM DSSDEV.TB_TRANSACTION_SS_ESIM_REJECT
   WHERE cdr_filename LIKE '/sa\_test/rp01/%' ESCAPE '\'
),
c AS (
  SELECT 101 AS ord, CAST('C01_MAP_normal' AS VARCHAR2(60)) AS tc, 'EID' AS kt, 'SAT01' AS kv, CAST('VALID' AS VARCHAR2(60)) AS et, CAST('MAP' AS VARCHAR2(200)) AS es, 1 AS en, CAST('040000 status CASE: status NULL, rn=1, mapping_error NULL -> MAP; 050100 status=MAP (needs PRE_MAP_SALEST)' AS VARCHAR2(300)) AS nt FROM DUAL UNION ALL
  SELECT 102, 'C02_UNMAP_bno_not_in_mapping',   'EID', 'SAT02', 'TEMP',   'UNMAP', 1, '040000 LEFT JOIN mapping miss -> mapping_error NOT NULL -> UNMAP; 050300 status=UNMAP' FROM DUAL UNION ALL
  SELECT 103, 'C03_UNMAP_owner_mismatch',       'EID', 'SAT03', 'TEMP',   'UNMAP', 1, '040000 join raw_.owner = mapping.invoicing_company_id' FROM DUAL UNION ALL
  SELECT 104, 'C04_UNMAP_before_effective',     'EID', 'SAT04', 'TEMP',   'UNMAP', 1, '040000 mapping.effective_date <= TRUNC(first_installed)' FROM DUAL UNION ALL
  SELECT 105, 'C05_UNMAP_after_expired',        'EID', 'SAT05', 'TEMP',   'UNMAP', 1, '040000 expired_date >= TRUNC(first_installed)' FROM DUAL UNION ALL
  SELECT 106, 'C06_MAN_partner_NULL',           'EID', 'SAT06', 'REJECT', 'MAN',   1, '040000 filter_error partner -> MAN (b_no Spark NULL vs Oracle _ESIM_SalesT not observable)' FROM DUAL UNION ALL
  SELECT 107, 'C07_MAN_sim_type_NULL',          'EID', 'SAT07', 'REJECT', 'MAN',   1, '040000 filter_error sim_type -> MAN (b_no ECP_ESIM_ in Oracle; MAN wins)' FROM DUAL UNION ALL
  SELECT 108, 'C08_MAN_iccid_NULL',             'EID', 'SAT08', 'REJECT', 'MAN',   1, '040000 filter_error iccid; chk_duplicate NULL' FROM DUAL UNION ALL
  SELECT 109, 'C09_MAN_first_installed_NULL',   'EID', 'SAT09', 'REJECT', 'MAN',   1, 'MAN before TYP (status CASE order)' FROM DUAL UNION ALL
  SELECT 110, 'C10_MAN_profile_type_empty_str', 'EID', 'SAT10', 'REJECT', 'MAN',   1, 'empty string = NULL in Oracle = Spark nullif(x,'''')' FROM DUAL UNION ALL
  SELECT 111, 'C11_UNMAP_partner_space',        'EID', 'SAT11', 'TEMP',   'UNMAP', 1, 'space is not NULL -> not MAN; b_no '' _ESIM_SalesT'' no mapping (README G03)' FROM DUAL UNION ALL
  SELECT 112, 'C12_TYP_feb29_nonleap',          'EID', 'SAT12', 'REJECT', 'TYP',   1, '20230229000000 TO_TIMESTAMP DEFAULT NULL -> TYP (Spark LEGACY parser may differ, Q3)' FROM DUAL UNION ALL
  SELECT 113, 'C13_TYP_month13',                'EID', 'SAT13', 'REJECT', 'TYP',   1, '20241301000000 (Q3)' FROM DUAL UNION ALL
  SELECT 114, 'C14_TYP_hour24',                 'EID', 'SAT14', 'REJECT', 'TYP',   1, '20240101240000 (Q3)' FROM DUAL UNION ALL
  SELECT 115, 'C15_TYP_non_digit',              'EID', 'SAT15', 'REJECT', 'TYP',   1, 'REGEXP_LIKE ^[0-9]{14}$ fails' FROM DUAL UNION ALL
  SELECT 116, 'C16_MAP_first_installed_17dig',  'EID', 'SAT16', 'VALID',  'MAP',   1, 'SUBSTR(...,1,14) truncates silently (README G04)' FROM DUAL UNION ALL
  SELECT 117, 'C17_UNMAP_partner_lowercase',    'EID', 'SAT17', 'TEMP',   'UNMAP', 1, 'case-sensitive join (README G06)' FROM DUAL UNION ALL
  SELECT 118, 'C18A_inbatch_first_file_wins',   'EID', 'SAT18A','VALID',  'MAP',   1, 'ROW_NUMBER ORDER BY file_date: 20261029100000 < 101000' FROM DUAL UNION ALL
  SELECT 119, 'C18B_inbatch_later_file_DUP',    'EID', 'SAT18B','REJECT', 'DUP',   1, 'rn=2 -> DUP; 050200 status NOT IN (MAP,UNMAP)' FROM DUAL UNION ALL
  SELECT 120, 'C19A_null_file_date_wins',       'EID', 'SAT19A','VALID',  'MAP',   1, 'file w/o _<running> -> file_date NULL -> NULLS FIRST rn=1 (README FN01)' FROM DUAL UNION ALL
  SELECT 121, 'C19B_dup_after_null_file_date',  'EID', 'SAT19B','REJECT', 'DUP',   1, 'file_date 20261029102000 ranks after NULL' FROM DUAL UNION ALL
  SELECT 122, 'C20_same_file_tie_counts_only',  'ICCID','SATRP0120','REJECT,VALID','DUP,MAP', 2, 'same iccid same file: which row wins is arbitrary -> counts only (semantic-verifier)' FROM DUAL UNION ALL
  SELECT 123, 'C21_DUP_cross_run_vs_temp',      'EID', 'SAT21', 'REJECT', 'DUP',   1, 'LEFT JOIN dup (valid UNION temp) hits PRESEED row' FROM DUAL UNION ALL
  SELECT 124, 'C22_MAP_eid_NULL',               'ICCID','SATRP0122','VALID','MAP', 1, 'eid not in mandatory list (README G01)' FROM DUAL UNION ALL
  SELECT 125, 'C23_body_tag_01_ignored',        'EID', 'SAT23', '-',      '-',     0, '040000 WHERE body_tag=''02''' FROM DUAL UNION ALL
  SELECT 126, 'C24_P2_second_partition_MAP',    'EID', 'SAT24', 'VALID',  'MAP',   1, 'P2 within +300 of rank-2 partition -> processed' FROM DUAL UNION ALL
  SELECT 127, 'C25_P3_deferred_beyond_300',     'EID', 'SAT25', '-',      '-',     0, '020000 P3 > nth_value(2)+300 -> replaced by MIN -> outside 040000 BETWEEN' FROM DUAL UNION ALL
  SELECT 128, 'C26_future_partition_ignored',   'EID', 'SAT26', '-',      '-',     0, '020000 partition_minute < SYSDATE-5min (fails if run > 60 min after seed)' FROM DUAL UNION ALL
  SELECT 129, 'C27_partition_eq_ckpt_ignored',  'EID', 'SAT27', '-',      '-',     0, '020000 >= M but 040000 > M (seeded only when old MAX checkpoint > 0; see PE)' FROM DUAL
),
r1 AS (
  SELECT c.ord, c.tc, c.et, c.es, c.en,
         COUNT(a.tbl) AS n,
         NVL(LISTAGG(a.tbl, ',')    WITHIN GROUP (ORDER BY a.tbl, a.status), '-') AS act_tbl,
         NVL(LISTAGG(a.status, ',') WITHIN GROUP (ORDER BY a.tbl, a.status), '-') AS act_st,
         c.nt
  FROM c
  LEFT JOIN a
    ON ((c.kt = 'EID' AND a.eid = c.kv) OR (c.kt = 'ICCID' AND a.iccid = c.kv))
  GROUP BY c.ord, c.tc, c.et, c.es, c.en, c.nt
),
d AS (
  -- ---------- รายละเอียดคอลัมน์ ----------
  SELECT 201 AS ord, CAST('D01_C01_valid_cols' AS VARCHAR2(60)) AS tc, CAST('VALID' AS VARCHAR2(60)) AS et,
         CAST('Y|20260101|1|1|2026-10-29 10:00:00' AS VARCHAR2(200)) AS es, 1 AS en, x.n, CAST('VALID' AS VARCHAR2(4000)) AS act_tbl, NVL(x.v, '-') AS act_st,
         CAST('mapping 5 cols NOT NULL|partition_date=first_installed day|transaction_units|cdr_type|file_date from file name (040000/050100)' AS VARCHAR2(300)) AS nt
  FROM (SELECT COUNT(*) AS n,
               MAX(CASE WHEN cp_id IS NOT NULL AND service_id IS NOT NULL AND network_type IS NOT NULL
                         AND invoicing_co_id IS NOT NULL AND share_basis IS NOT NULL THEN 'Y' ELSE 'N' END
                   || '|' || TO_CHAR(partition_date) || '|' || transaction_units || '|' || cdr_type
                   || '|' || NVL(TO_CHAR(file_date, 'YYYY-MM-DD HH24:MI:SS'), 'NULL')) AS v
        FROM DSSDEV.TB_TRANSACTION_SS_ESIM_VALID
        WHERE cdr_filename LIKE '/sa\_test/rp01/%' ESCAPE '\' AND eid = 'SAT01') x
  UNION ALL
  SELECT 202, 'D02_C02_temp_mapping_error', 'TEMP',
         'cp_id|service_id|network_type|invoicing_company_id|share_basis|#ECP_ESIM_Step#20260101', 1, x.n, 'TEMP', NVL(x.v, '-'),
         'mapping_error (replace is NULL) # b_no # partition_date=first_installed day (040000/050300)'
  FROM (SELECT COUNT(*) AS n, MAX(NVL(mapping_error, 'NULL') || '#' || NVL(b_no, 'NULL') || '#' || TO_CHAR(partition_date)) AS v
        FROM DSSDEV.TB_TRANSACTION_SS_ESIM_TEMP
        WHERE cdr_filename LIKE '/sa\_test/rp01/%' ESCAPE '\' AND eid = 'SAT02') x
  UNION ALL
  SELECT 203, 'D03_C06_reject_filter_error', 'REJECT', 'partner|#partner is NULL|', 1, x.n, 'REJECT', NVL(x.v, '-'),
         '050200 MAN -> filter_error / err_msg = filter_error_msg'
  FROM (SELECT COUNT(*) AS n, MAX(NVL(filter_error, 'NULL') || '#' || NVL(err_msg, 'NULL')) AS v
        FROM DSSDEV.TB_TRANSACTION_SS_ESIM_REJECT
        WHERE cdr_filename LIKE '/sa\_test/rp01/%' ESCAPE '\' AND eid = 'SAT06') x
  UNION ALL
  SELECT 204, 'D04_C09_reject_MAN_not_TYP_msg', 'REJECT', 'first_installed|#first_installed is NULL|', 1, x.n, 'REJECT', NVL(x.v, '-'),
         'MAN row carries filter_error, not type_error'
  FROM (SELECT COUNT(*) AS n, MAX(NVL(filter_error, 'NULL') || '#' || NVL(err_msg, 'NULL')) AS v
        FROM DSSDEV.TB_TRANSACTION_SS_ESIM_REJECT
        WHERE cdr_filename LIKE '/sa\_test/rp01/%' ESCAPE '\' AND eid = 'SAT09') x
  UNION ALL
  SELECT 205, 'D05_C12_reject_type_error', 'REJECT', 'first_installed|#first_installed: Invalid TIMESTAMP type (Raw=20230229000000)|', 1, x.n, 'REJECT', NVL(x.v, '-'),
         '040000 regexp_replace type_error (Q3 escapedStringLiterals OPEN) / 050200 TYP -> type_error'
  FROM (SELECT COUNT(*) AS n, MAX(NVL(filter_error, 'NULL') || '#' || NVL(err_msg, 'NULL')) AS v
        FROM DSSDEV.TB_TRANSACTION_SS_ESIM_REJECT
        WHERE cdr_filename LIKE '/sa\_test/rp01/%' ESCAPE '\' AND eid = 'SAT12') x
  UNION ALL
  SELECT 206, 'D06_C16_valid_first_installed', 'VALID', '2026-01-01 10:00:00', 1, x.n, 'VALID', NVL(x.v, '-'),
         'SUBSTR(first_installed,1,14) -> TO_TIMESTAMP'
  FROM (SELECT COUNT(*) AS n, MAX(NVL(TO_CHAR(first_installed, 'YYYY-MM-DD HH24:MI:SS'), 'NULL')) AS v
        FROM DSSDEV.TB_TRANSACTION_SS_ESIM_VALID
        WHERE cdr_filename LIKE '/sa\_test/rp01/%' ESCAPE '\' AND eid = 'SAT16') x
  UNION ALL
  SELECT 207, 'D07_C19A_valid_file_date_NULL', 'VALID', 'NULL', 1, x.n, 'VALID', NVL(x.v, '-'),
         'REGEXP_SUBSTR no match -> NULL (Spark gives empty string -> NULL after cast)'
  FROM (SELECT COUNT(*) AS n, MAX(NVL(TO_CHAR(file_date, 'YYYY-MM-DD HH24:MI:SS'), 'NULL')) AS v
        FROM DSSDEV.TB_TRANSACTION_SS_ESIM_VALID
        WHERE cdr_filename LIKE '/sa\_test/rp01/%' ESCAPE '\' AND eid = 'SAT19A') x
  UNION ALL
  SELECT 208, 'D08_C11_temp_b_no_with_space', 'TEMP', '[ _ESIM_SalesT]', 1, x.n, 'TEMP', NVL(x.v, '-'),
         'partner || ''_ESIM_'' || sim_type keeps leading space'
  FROM (SELECT COUNT(*) AS n, MAX('[' || b_no || ']') AS v
        FROM DSSDEV.TB_TRANSACTION_SS_ESIM_TEMP
        WHERE cdr_filename LIKE '/sa\_test/rp01/%' ESCAPE '\' AND eid = 'SAT11') x
  UNION ALL
  SELECT 209, 'D09_C21_reject_DUP_no_error_text', 'REJECT', 'NULL#NULL', 1, x.n, 'REJECT', NVL(x.v, '-'),
         '050200 DUP -> filter_error / err_msg from filter_error (NULL)'
  FROM (SELECT COUNT(*) AS n, MAX(NVL(filter_error, 'NULL') || '#' || NVL(err_msg, 'NULL')) AS v
        FROM DSSDEV.TB_TRANSACTION_SS_ESIM_REJECT
        WHERE cdr_filename LIKE '/sa\_test/rp01/%' ESCAPE '\' AND eid = 'SAT21') x
  UNION ALL
  SELECT 210, 'D10_reject_partition_date_eq_process_day', 'REJECT', '0', 0, x.n, 'REJECT', TO_CHAR(x.n),
         '050200 partition_date = YYYYMMDD(process_date) -> count of mismatching rows'
  FROM (SELECT COUNT(*) AS n FROM DSSDEV.TB_TRANSACTION_SS_ESIM_REJECT
        WHERE cdr_filename LIKE '/sa\_test/rp01/%' ESCAPE '\'
          AND (partition_date IS NULL OR partition_date <> TO_NUMBER(TO_CHAR(process_date, 'YYYYMMDD')))) x
  UNION ALL
  -- ---------- ยอดรวม (จับแถวเกิน / แถวซ้ำจาก join mapping) ----------
  SELECT 301, 'T01_total_valid_marker', 'VALID', '7', 7, x.n, 'VALID', TO_CHAR(x.n),
         'C01 C16 C18A C19A C20(1) C22 C24'
  FROM (SELECT COUNT(*) AS n FROM DSSDEV.TB_TRANSACTION_SS_ESIM_VALID WHERE cdr_filename LIKE '/sa\_test/rp01/%' ESCAPE '\') x
  UNION ALL
  SELECT 302, 'T02_total_temp_marker', 'TEMP', '6', 6, x.n, 'TEMP', TO_CHAR(x.n),
         'C02 C03 C04 C05 C11 C17 (PRESEED excluded)'
  FROM (SELECT COUNT(*) AS n FROM DSSDEV.TB_TRANSACTION_SS_ESIM_TEMP
        WHERE cdr_filename LIKE '/sa\_test/rp01/%' ESCAPE '\' AND cdr_filename NOT LIKE '%/PRESEED\_%' ESCAPE '\') x
  UNION ALL
  SELECT 303, 'T03_total_reject_marker', 'REJECT', '13', 13, x.n, 'REJECT', TO_CHAR(x.n),
         'MAN 5 + TYP 4 + DUP 4 (C18B C19B C20 C21)'
  FROM (SELECT COUNT(*) AS n FROM DSSDEV.TB_TRANSACTION_SS_ESIM_REJECT WHERE cdr_filename LIKE '/sa\_test/rp01/%' ESCAPE '\') x
  UNION ALL
  -- ---------- raw_temp / status ----------
  SELECT 401, 'R01_raw_temp_empty_after_080000', 'RAW_TEMP', '0', 0, x.n, 'RAW_TEMP', TO_CHAR(x.n),
         '080000 DELETE whole table (Q10=A)'
  FROM (SELECT COUNT(*) AS n FROM DSSDEV.TB_STAGING_SS_ESIM_RAW_TEMP) x
  UNION ALL
  SELECT 402, 'S01_status_after_090000', 'WORKFLOW_STATUS', 'NULL|TRUE|NULL', 1, x.n, 'WORKFLOW_STATUS', NVL(x.v, '-'),
         'running|success|workflow_process_date: 090000 TRUNCATE + INSERT success only'
  FROM (SELECT COUNT(*) AS n,
               MAX(NVL(running, 'NULL') || '|' || NVL(success, 'NULL') || '|' || NVL(workflow_process_date, 'NULL')) AS v
        FROM DSSDEV.TB_STAGING_SS_ESIM_LANDING_TO_DISCOVERY_WORKFLOW_STATUS) x
  UNION ALL
  -- ---------- checkpoint ----------
  SELECT 501, 'K01_ckpt_max_eq_P2', 'CHECKPOINT', NVL(TO_CHAR(pp.p2), 'P2 NOT SEEDED'), 1, 1, 'CHECKPOINT', NVL(x.v, '-'),
         '020000 keeps rank1/2 and <= nth_value(2)+300; 070000 copies temp'
  FROM (SELECT TO_CHAR(MAX(checkpoint_partition)) AS v FROM DSSDEV.TB_STAGING_SS_ESIM_CHECKPOINT) x CROSS JOIN pp
  UNION ALL
  SELECT 502, 'K02_ckpt_has_P1', 'CHECKPOINT', 'Y', 1, 1, 'CHECKPOINT', x.v, 'P1 row copied from checkpoint_temp'
  FROM (SELECT CASE WHEN COUNT(*) > 0 THEN 'Y' ELSE 'N' END AS v
        FROM DSSDEV.TB_STAGING_SS_ESIM_CHECKPOINT k CROSS JOIN pp WHERE k.checkpoint_partition = pp.p1) x
  UNION ALL
  SELECT 503, 'K03_ckpt_no_P3_no_PF', 'CHECKPOINT', '0', 1, 1, 'CHECKPOINT', x.v, 'P3 replaced by MIN per partition_date; PF filtered by < SYSDATE-5min'
  FROM (SELECT TO_CHAR(COUNT(*)) AS v
        FROM DSSDEV.TB_STAGING_SS_ESIM_CHECKPOINT k CROSS JOIN pp WHERE k.checkpoint_partition IN (pp.p3, pp.pf)) x
  UNION ALL
  SELECT 504, 'K04_ckpt_temp_max_eq_P2', 'CHECKPOINT_TEMP', NVL(TO_CHAR(pp.p2), 'P2 NOT SEEDED'), 1, 1, 'CHECKPOINT_TEMP', NVL(x.v, '-'),
         'assumes old checkpoint_temp rows (other days) are < P1'
  FROM (SELECT TO_CHAR(MAX(checkpoint_partition)) AS v FROM DSSDEV.TB_STAGING_SS_ESIM_CHECKPOINT_TEMP) x CROSS JOIN pp
  UNION ALL
  SELECT 505, 'K05_ckpt_temp_no_P3_no_PF', 'CHECKPOINT_TEMP', '0', 1, 1, 'CHECKPOINT_TEMP', x.v, '020000 CASE ... ELSE MIN(checkpoint_partition)'
  FROM (SELECT TO_CHAR(COUNT(*)) AS v
        FROM DSSDEV.TB_STAGING_SS_ESIM_CHECKPOINT_TEMP k CROSS JOIN pp WHERE k.checkpoint_partition IN (pp.p3, pp.pf)) x
  UNION ALL
  SELECT 506, 'K06_info_PE_seeded', 'LANDING', 'Y_or_N', 1, 1, 'LANDING', 'Y_or_N',
         'info only: PE (edge = old MAX checkpoint) = ' || NVL(TO_CHAR(pp.pe), 'not seeded (old checkpoint empty)')
  FROM pp
  UNION ALL
  -- ---------- precondition ของ mapping ใน DEV ----------
  SELECT 601, 'PRE_MAP_SALEST_AWN_20260101', 'EXT_MAPPING', '1', 1, 1, 'EXT_MAPPING', x.v,
         'C01 C16 C18A C19A C20 C22 C24 depend on this (exactly 1 row, else row multiplication / UNMAP)'
  FROM (SELECT TO_CHAR(COUNT(*)) AS v FROM DSSDEV.EXT_DSS_VW_SERVICE_MAPPING_BNO_KEY m
        WHERE m.record_status = 'A' AND m.b_no = 'ECP_ESIM_SalesT' AND m.invoicing_company_id = 'AWN'
          AND TRUNC(m.effective_date) <= DATE '2026-01-01'
          AND (m.expired_date IS NULL OR TRUNC(m.expired_date) >= DATE '2026-01-01')
          AND m.content_partner_id IS NOT NULL AND m.service_id IS NOT NULL AND m.network_type IS NOT NULL
          AND m.share_basis IS NOT NULL) x
  UNION ALL
  SELECT 602, 'PRE_SALEST_AWN_not_active_20240101', 'EXT_MAPPING', '0', 1, 1, 'EXT_MAPPING', x.v, 'C04 depends on this'
  FROM (SELECT TO_CHAR(COUNT(*)) AS v FROM DSSDEV.EXT_DSS_VW_SERVICE_MAPPING_BNO_KEY m
        WHERE m.record_status = 'A' AND m.b_no = 'ECP_ESIM_SalesT' AND m.invoicing_company_id = 'AWN'
          AND TRUNC(m.effective_date) <= DATE '2024-01-01'
          AND (m.expired_date IS NULL OR TRUNC(m.expired_date) >= DATE '2024-01-01')) x
  UNION ALL
  SELECT 603, 'PRE_GABLE_AWN_not_active_20260101', 'EXT_MAPPING', '0', 1, 1, 'EXT_MAPPING', x.v, 'C05 depends on this'
  FROM (SELECT TO_CHAR(COUNT(*)) AS v FROM DSSDEV.EXT_DSS_VW_SERVICE_MAPPING_BNO_KEY m
        WHERE m.record_status = 'A' AND m.b_no = 'ECP_ESIM_Sales_Gable' AND m.invoicing_company_id = 'AWN'
          AND TRUNC(m.effective_date) <= DATE '2026-01-01'
          AND (m.expired_date IS NULL OR TRUNC(m.expired_date) >= DATE '2026-01-01')) x
  UNION ALL
  SELECT 604, 'PRE_no_mapping_Step_3BB_odd_bno', 'EXT_MAPPING', '0', 1, 1, 'EXT_MAPPING', x.v, 'C02 C03 C11 C17 depend on this'
  FROM (SELECT TO_CHAR(COUNT(*)) AS v FROM DSSDEV.EXT_DSS_VW_SERVICE_MAPPING_BNO_KEY m
        WHERE m.record_status = 'A'
          AND (m.b_no IN ('ECP_ESIM_Step', ' _ESIM_SalesT', 'ecp_ESIM_SalesT')
               OR (m.b_no = 'ECP_ESIM_SalesT' AND m.invoicing_company_id = '3BB'))) x
  UNION ALL
  SELECT 605, 'PRE_cdr_type_1_active', 'EXT_CDR_TYPE', '1', 1, 1, 'EXT_CDR_TYPE', x.v, '040000 INNER JOIN cdr_mas: 0 = nothing processed, >1 = rows multiplied'
  FROM (SELECT TO_CHAR(COUNT(*)) AS v FROM DSSDEV.EXT_DSS_TB_MASTER_CDR_TYPE WHERE cdr_type = '1' AND record_status = 'A') x
)
SELECT u.tc AS TEST_CASE,
       u.et AS EXP_TBL,
       u.es AS EXP_STATUS,
       u.n AS ROWS_FOUND,
       u.act_tbl AS ACT_TBL,
       u.act_st AS ACT_STATUS,
       CASE WHEN u.n = u.en AND RTRIM(u.act_tbl) = RTRIM(u.et) AND RTRIM(u.act_st) = RTRIM(u.es)
            THEN 'PASS' ELSE 'FAIL' END AS RESULT,
       u.nt AS NOTE
FROM (
  SELECT ord, tc, et, es, en, n, act_tbl, act_st, nt FROM r1
  UNION ALL
  SELECT ord, tc, et, es, en, n, act_tbl, act_st, nt FROM d
) u
ORDER BY u.ord
