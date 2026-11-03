-- ก่อน import: มี project code SS_ESIM_L2D ใน ODI repository อยู่แล้วไหม (ถ้ามี ต้องเป็นงานนี้เท่านั้น = Overwrite)
-- ⚠️ ชื่อตาราง/คอลัมน์ SNP_PROJECT ยังไม่ยืนยันกับ ODI 14c ของทีม — ถ้า error ให้บอก AI พร้อมข้อความ error ไม่ต้องเดา
SELECT project_code, project_name FROM DSSDEV.SNP_PROJECT WHERE project_code = 'SS_ESIM_L2D'
