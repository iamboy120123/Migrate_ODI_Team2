---
description: Wiki / Knowledge — ค้นความรู้ทุกชั้น (kit · ระบบปลายทาง · project · งาน) หรือดึงบทเรียนของขั้นที่กำลังทำ
argument-hint: "<คำค้น> | step <01-06> | check"
---
หน้าแรกของ Wiki: `../../../../kit/knowledge/README.md`

- `$ARGUMENTS` เป็น `step 03` → `python scripts/ws/wiki.py --step 03` แล้วสรุปบทเรียนที่ใช้กับงานนี้ (บอกเลข L# / LT# · ใช้ได้เพราะอะไร)
- `$ARGUMENTS` เป็น `check` → `python scripts/ws/wiki.py --check` แล้วบอกข้อที่ต้องแก้ทีละข้อ
- อื่น ๆ = คำค้น → `python scripts/ws/wiki.py --search "$ARGUMENTS"` (ถ้าไม่เจอในเครื่อง ลอง `--remote` = branch งานของคนอื่นที่ fetch แล้ว · การ fetch เป็นการอ่าน GitHub ทำตามโหมด GitHub ของงาน)
- สรุปผลเป็นตาราง: ชั้น · ไฟล์ · เลขอ้างอิง · ใจความ · ใช้กับงานนี้ได้ไหม — แยก "ข้อเท็จจริงจาก Wiki" กับ "ความเห็นของ AI" ให้ชัด
