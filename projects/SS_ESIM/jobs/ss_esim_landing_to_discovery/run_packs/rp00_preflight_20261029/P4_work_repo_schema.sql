-- P4 work repository schema (2026-10-29T17:27:17) - run on Oracle Dev (user that can see SNP_* tables)
-- single SELECT: run with Ctrl+Enter, export result as CSV (with header) into input/run_results/<this pack name>/
SELECT owner, table_name, 'expected: not SYSTEM (G6.M4)' AS note FROM all_tables
WHERE table_name IN ('SNP_SESSION', 'SNP_SESS_TASK_LOG', 'SNP_PROJECT', 'SNP_VAR')
ORDER BY 1, 2
