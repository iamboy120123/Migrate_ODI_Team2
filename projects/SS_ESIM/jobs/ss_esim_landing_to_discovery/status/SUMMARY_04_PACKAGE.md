# สรุปขั้น 04 · แพ็กเกจ — SS_ESIM_L2D

อัปเดต 2026-10-29 20:25 · สร้างโดย `scripts/checks/grade.py` · ห้ามแก้มือ

## เกรด: **B · ส่งได้ มีเงื่อนไข**

แพ็กเกจ `PROJ_EXPORT.xml` · ODI code `SS_ESIM_L2D` · id_base `92000` · ความเร็วก่อนรันจริง: ต้องดู

| ด่าน | ผล |
|---|---|
| G1 | ✅ PASS |
| G2 | 🟡 WAIVED |
| G3 | ✅ PASS |
| ก่อนส่ง P1–P6 | ✅ FAIL 0 · WARN 0 |
| SQL ต่อ task | ✅ 5 · 🟡 5 · ⛔ 0 |

## เงื่อนไข (B)

- G2 ผ่านด้วย waiver (ดู Waiver log ใน status/GATES.md)
- SQL 🟡 5 task — ต้องมีเหตุผลบันทึก (NO_CHANGE) ทุกข้อ

## สรุปการส่งมอบ

- **ทาสก์ที่ตัดออก:** ไม่มี
- **placeholder ที่เหลือ:** ไม่มีในค่า ODI หลัก (ตรวจ <...> ใน output/ อีกครั้งก่อนส่ง)
- **Topology ที่คนต้องตั้งเอง:** JDBC URL + user/password ของ data server ใน ODI Studio (ไม่มีรหัสผ่านในไฟล์) · logical schema / context ถ้ายังไม่มี
- **Scenario ที่ต้อง generate เอง:** ทุก Procedure / Package หลัง import (kit ไม่สร้าง Scenario ที่ compile แล้ว)
- **ยังไม่ยืนยัน:** แพ็กเกจนี้ import และรันได้จริงตั้งแต่ต้นจนจบ — ยืนยันที่ G4 / G5

## ต้องทำต่อ

- รัน output/ddl/ (`run_sql.py output/ddl/<ไฟล์> --plan` → ขออนุญาต → AI รัน หรือคนรันเอง · ตารางที่มีอยู่แล้วห้ามรันทับ) → บันทึก status/DEPLOY_LOG.md
- import-lock (ใบงานล็อก) → Smart Import (Overwrite) → Topology → Generate Scenario → export Smart Export หลัง import (หลักฐาน G4) → import-unlock
