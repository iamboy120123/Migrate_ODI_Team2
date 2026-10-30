-- S5b0 หา schema ของ ODI work repository (ที่มีตาราง SNP_SESSION) — รันด้วย user ไหนก็ได้
-- ถ้าไม่มีแถว = user นี้มองไม่เห็นตาราง repository → ถาม ODI admin ชื่อ schema (มักเป็น <PREFIX>_ODI_REPO)
-- ได้ชื่อแล้วบอก agent (จะใส่ config.odi.work_repo_schema แล้ว generate S5b ใหม่) หรือ login ด้วย user นั้นรัน S5b
SELECT owner, table_name FROM all_tables WHERE table_name IN ('SNP_SESSION','SNP_STEP_LOG','SNP_SESS_STEP') ORDER BY owner, table_name
