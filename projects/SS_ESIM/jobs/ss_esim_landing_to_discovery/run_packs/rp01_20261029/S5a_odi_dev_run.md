# S5 — รัน package ใน Dev แล้วดึง log

1. ODI Studio → scenario ของ `PKG_SS_ESIM_L2D` → Run → context **DEV**
2. รอจนจบ (success หรือ error ก็ได้)
3. ถ้า fail: **ห้าม** execute ใหม่ทั้ง package — ส่งผลมาก่อน
4. รัน `S5b_odi_session_log.sql` ด้วย user ของ **ODI work repository** → export CSV ลง `input/run_results/rp01_20261029/`
   - query error (ชื่อคอลัมน์ต่างตามเวอร์ชัน) → Operator → session ล่าสุด → **ภาพหน้าจอ** ที่เห็นสถานะทุก step
     + ข้อความ error ของ step ที่ fail (วางเป็น .png ใน `input/run_results/rp01_20261029/` ได้เลย agent อ่านภาพได้)
