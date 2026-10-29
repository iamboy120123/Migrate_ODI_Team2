-- P5b D1 checks from /review-sql round 1 (2026-10-29) - run on Blendata SQL editor / spark-sql (NOT Oracle)
-- SELECT only. Run each statement separately; screenshot or export each result into input/run_results/rp00_preflight_20261029/
-- Source: status/PHASE4_REVIEW_LOG.md (OPEN rows of 020000 / 040000)

-- [1] I14 overwrite strategy of 020000 / 040000 / 070000 (Q3)
SET spark.sql.sources.partitionOverwriteMode;

-- [2] escapedStringLiterals in practice: expected 'x' when the regex matches (task 040000 type_error)
SELECT regexp_replace('x: Invalid TIMESTAMP type (Raw=abc)', ': Invalid [A-Z]+ type \\(Raw=[\\S]*\\)', '') AS t_regex;

-- [3] timeParserPolicy in practice: invalid dates (task 040000 first_installed / file_date)
SELECT to_timestamp('20240230120000', 'yyyyMMddHHmmss') AS t_feb30,
       to_timestamp('20241301000000', 'yyyyMMddHHmmss') AS t_month13,
       to_timestamp('', 'yyyyMMddHHmmss') AS t_empty;

-- [4] now() timezone vs Oracle SYSDATE (Q3 / Q5)
SELECT current_timestamp() AS spark_now, current_timezone() AS spark_tz;

-- [5] b_no when partner / sim_type is NULL vs '' (task 040000)
SELECT SUM(CASE WHEN partner IS NULL THEN 1 ELSE 0 END)  AS partner_null,
       SUM(CASE WHEN partner = '' THEN 1 ELSE 0 END)     AS partner_empty,
       SUM(CASE WHEN sim_type IS NULL THEN 1 ELSE 0 END) AS sim_type_null,
       SUM(CASE WHEN sim_type = '' THEN 1 ELSE 0 END)    AS sim_type_empty,
       COUNT(*) AS total
FROM tb_landing_ss_esim;

-- [6] status table: column types + current values (task 020000 guard)
DESCRIBE tb_staging_ss_esim_landing_to_discovery_workflow_status;
SELECT * FROM tb_staging_ss_esim_landing_to_discovery_workflow_status;
