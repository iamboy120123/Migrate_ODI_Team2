# K21 — sync_guid_from_export เขียน _guid_keys.json

- จากงาน: projects/SS_ESIM/jobs/ss_esim_landing_to_discovery
- วันที่: 2026-11-04 · โดย: iamboy120123
- ปัญหา: Smart Import ทับล้ม ODI-17591 (Name "v_max_partition" is already used) — repository มี GlobalId ต่างจาก build · `/sync-guid` เขียนแค่ `_guid_map.json` แต่ builder (`build_odi_export.reuse_guids`) อ่าน `_guid_keys.json` → ไม่มีผล
- แก้: เขียน `_guid_keys.json` ด้วย key ของ builder (`guid_identities`) เมื่อชื่อ project/folder/package ตรง · `--dry-run` แสดงจำนวนที่จะเปลี่ยน ไม่เขียนไฟล์
- ทดสอบ: SS_ESIM rebuild → GlobalId ตรง repository 46/46 object หลัก · XML ไม่เปลี่ยนนอกจาก GlobalId/วันที่ · validator 0 error
- ข้อสังเกต (ยังไม่แก้): builder เลือก reference ใหม่สุดใน input/odi_reference/ → Smart Export หลัง import ทำ build หยุด (ไม่มี SnpOrigTxt trt_edit_cmd) — เก็บไว้ที่ input/run_results/ แทน
