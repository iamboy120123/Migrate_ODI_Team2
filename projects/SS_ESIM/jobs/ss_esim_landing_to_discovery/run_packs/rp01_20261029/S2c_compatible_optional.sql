-- S2c (option) COMPATIBLE — ต้องมีสิทธิ์อ่าน v$parameter; ถ้า ORA-00942 ข้ามได้ (DB_VERSION ใน S2b พอ)
-- รันได้ทุก client (DBeaver / SQL Developer / sqlplus) — เป็น SELECT เดียว
-- export ผลเป็น CSV (มี header) แล้ววางใน input/run_results/<ชื่อ pack นี้>/ ชื่อไฟล์อะไรก็ได้ (แนะนำ: compatible.csv)
SELECT 'C' AS check_id, 'COMPATIBLE' AS check_name, name AS item, value AS result, '>= 12.2' AS expected
FROM v$parameter WHERE name = 'compatible'
