-- rp_g4_diag / D1 — หาสาเหตุ ODI-17591: Name "v_max_partition" is already used (Smart Import 2026-11-04)
-- รันใน DBeaver ที่ต่อ work repository DEV (schema DSSDEV) · SELECT อย่างเดียว · Export ผลทั้ง 3 ชุดเป็น CSV (UTF-8 มีหัวคอลัมน์)
-- วางผลที่ input/run_results/rp_g4_diag/ (D1a.csv · D1b.csv · D1c.csv)
-- ⚠️ ชื่อตาราง/คอลัมน์ SNP_* ยังไม่ยืนยันกับ ODI 14c ของทีม — ถ้า error ให้ส่งข้อความ error มา ไม่ต้องแก้ SQL เอง
-- ค่าที่แพ็กเกจของเราใช้: project SS_ESIM_L2D GlobalId f915444d-cfaf-4aeb-97cc-f35782379ea5
--                         v_max_partition 0869ef80-e9ee-4fd5-8e05-26fc0a2794ef · v_lag_minutes d3279dcc-47c3-425a-8b83-2e8276337276

-- D1a: ตัวแปรชื่อนี้มีอยู่ที่ไหนบ้าง (project ไหน · GlobalId อะไร) — ถ้า GlobalId ไม่ตรงกับด้านบน = สาเหตุ
SELECT v.i_var, v.var_name, v.global_id AS var_global_id, v.i_project, p.project_code, p.project_name, p.global_id AS project_global_id
FROM DSSDEV.SNP_VAR v
LEFT JOIN DSSDEV.SNP_PROJECT p ON p.i_project = v.i_project
WHERE LOWER(v.var_name) IN ('v_max_partition', 'v_lag_minutes')
ORDER BY v.var_name, p.project_code;

-- D1b: project ที่ชื่อขึ้นต้น SS_ESIM ทั้งหมด (มี SS_ESIM_L2D ซ้ำ / GlobalId ต่างไหม · SS_ESIM14 งานทดสอบเก่า)
SELECT i_project, project_code, project_name, global_id
FROM DSSDEV.SNP_PROJECT
WHERE project_code LIKE 'SS_ESIM%'
ORDER BY project_code;

-- D1c: package ของงานนี้ใน repository (GlobalId ควรเป็น ee511ae3-9647-4d01-8b0a-014728b74341)
SELECT k.i_package, k.pack_name, k.global_id, f.folder_name, f.i_project
FROM DSSDEV.SNP_PACKAGE k
LEFT JOIN DSSDEV.SNP_FOLDER f ON f.i_folder = k.i_folder
WHERE k.pack_name = 'PKG_SS_ESIM_L2D';
