-- P1 Oracle environment (2026-10-29T17:27:17) - run on Oracle Dev as DSSDEV
-- single SELECT: run with Ctrl+Enter, export result as CSV (with header) into input/run_results/<this pack name>/
SELECT 'DB_VERSION' AS check_name, product AS item, version AS result FROM product_component_version WHERE UPPER(product) LIKE '%DATABASE%'
UNION ALL SELECT 'CURRENT_USER', 'user', USER FROM dual
UNION ALL SELECT 'IS_WORK_USER', 'DSSDEV', CASE WHEN USER = 'DSSDEV' THEN 'YES' ELSE 'NO' END FROM dual
UNION ALL SELECT 'DB_TIMEZONE', 'dbtimezone', DBTIMEZONE FROM dual
UNION ALL SELECT 'SESSION_TIMEZONE', 'sessiontimezone', SESSIONTIMEZONE FROM dual
UNION ALL SELECT 'SYSDATE', 'sysdate', TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') FROM dual
UNION ALL SELECT 'NLS_DB', parameter, value FROM nls_database_parameters WHERE parameter IN ('NLS_CHARACTERSET', 'NLS_NCHAR_CHARACTERSET', 'NLS_DATE_FORMAT', 'NLS_TIMESTAMP_FORMAT', 'NLS_LENGTH_SEMANTICS', 'NLS_SORT', 'NLS_COMP')
UNION ALL SELECT 'NLS_SESSION', parameter, value FROM nls_session_parameters WHERE parameter IN ('NLS_DATE_FORMAT', 'NLS_TIMESTAMP_FORMAT', 'NLS_TERRITORY', 'NLS_LANGUAGE', 'NLS_LENGTH_SEMANTICS')
ORDER BY 1, 2
