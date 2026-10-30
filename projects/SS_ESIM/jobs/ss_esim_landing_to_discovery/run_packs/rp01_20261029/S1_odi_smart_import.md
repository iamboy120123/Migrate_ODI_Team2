# S1 — ODI: Smart Import (ครั้งเดียว)

ไฟล์ที่ import: `output/odi_export/PKG_SS_ESIM_L2D.zip`
Project ปลายทาง: **SS_ESIM_L2D** (`SS_ESIM_L2D`)

1. ODI Studio → Designer → Import → **Smart Import** → เลือกไฟล์ข้างบน
2. หน้า Import Actions: object ที่มีอยู่แล้ว (GlobalId ตรงกัน) ให้เลือก **Overwrite** สำหรับ procedure / package ที่ code เปลี่ยน — **Merge ไม่อัปเดต SQL ของ step ที่มีอยู่แล้ว** (K7, rp01 2026-09-29); Merge ใช้ได้กับ project / folder
   - ถ้าขึ้นเป็น **Create** ทั้งหมด = GlobalId ไม่ตรง → **หยุด** ส่งภาพหน้าจอมาแทน
   - ห้ามเลือก **Create Copy** — จะได้ project ใหม่ "Copy of ..." GlobalId ใหม่ทั้งหมด (เกิดใน rp01)
3. (หลักฐานสำหรับการทดสอบ G4 เท่านั้น — ไม่ใช่ input ของ build และไม่ต้องทำก่อนเทส) คลิกขวา project `SS_ESIM_L2D` → **Smart Export** → บันทึกลง `input/run_results/rp01_20261029/`
4. ถ้า import error → คัดลอกข้อความลง `input/run_results/rp01_20261029/S1_error.txt`
