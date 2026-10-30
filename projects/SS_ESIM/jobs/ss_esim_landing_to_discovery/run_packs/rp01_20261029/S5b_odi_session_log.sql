-- S5b session log (ODI 12c/14c work repository)
-- ใช้ schema DSSDEV (config.odi.work_repo_schema) — user ที่รันต้องมี SELECT บนตาราง SNP_* ของ DSSDEV
-- รันได้ทุก client (DBeaver / SQL Developer / sqlplus) — เป็น SELECT เดียว
-- export ผลเป็น CSV (มี header) แล้ววางใน input/run_results/<ชื่อ pack นี้>/ ชื่อไฟล์อะไรก็ได้ (แนะนำ: session_log.csv)
SELECT s.sess_no, s.sess_name, s.scen_name, s.scen_version, s.context_code,
       TO_CHAR(s.sess_beg,'YYYY-MM-DD HH24:MI:SS') AS sess_beg,
       TO_CHAR(s.sess_end,'YYYY-MM-DD HH24:MI:SS') AS sess_end, s.sess_status,
       sl.nno, ss.step_name, sl.nb_run, sl.step_status,
       TO_CHAR(sl.step_beg,'YYYY-MM-DD HH24:MI:SS') AS step_beg,
       TO_CHAR(sl.step_end,'YYYY-MM-DD HH24:MI:SS') AS step_end,
       sl.nb_row, sl.nb_ins, sl.nb_upd, sl.nb_del,
       REPLACE(REPLACE(DBMS_LOB.SUBSTR(sl.error_message, 2000, 1), CHR(10), ' '), CHR(13), ' ') AS error_message
FROM   DSSDEV.snp_session s
LEFT JOIN DSSDEV.snp_step_log sl ON sl.sess_no = s.sess_no
LEFT JOIN DSSDEV.snp_sess_step ss ON ss.sess_no = sl.sess_no AND ss.nno = sl.nno
WHERE  s.sess_no = (SELECT MAX(sess_no) FROM DSSDEV.snp_session WHERE UPPER(sess_name) LIKE '%SS_ESIM_L2D%')
ORDER  BY sl.nno, sl.nb_run
