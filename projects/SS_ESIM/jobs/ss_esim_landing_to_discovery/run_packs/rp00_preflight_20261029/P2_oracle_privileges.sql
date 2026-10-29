-- P2 privileges (2026-10-29T17:27:17) - run on Oracle Dev as DSSDEV
-- single SELECT: run with Ctrl+Enter, export result as CSV (with header) into input/run_results/<this pack name>/
SELECT 'SYS_PRIV' AS kind, privilege AS name FROM session_privs
UNION ALL SELECT 'ROLE', role FROM session_roles
UNION ALL SELECT 'QUOTA', tablespace_name || ':' || CASE WHEN max_bytes = -1 THEN 'UNLIMITED' ELSE TO_CHAR(max_bytes) END FROM user_ts_quotas
ORDER BY 1, 2
