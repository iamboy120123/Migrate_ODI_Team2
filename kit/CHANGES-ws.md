# CHANGES-ws — การแก้ kit ที่ยังไม่ได้ backport เข้า setup_migrate.ps1

> `workspace.py kit-promote` เพิ่มแถว · `extract-kit` (setup รุ่นใหม่) ต้องให้ทุกแถวเป็น ✅ ก่อน

| K# | วันที่ | จากงาน | ไฟล์ | เหตุผล | backport แล้ว |
|---|---|---|---|---|---|
| K18 | 2026-11-03 | (ws tools) | tools/wscore/jobs.py · check.py · init.py · tools/workspace.py · .gitignore · kit/job_base/ (84) · kit/job/.claude/commands/status.md | ไฟล์ kit ในงานไม่ commit ซ้ำ — ต้นฉบับชุดเดียว kit/job_base + sync-kit + ล็อกรุ่นหลัง G3 · แก้ .gitignore STATUS.md กลืน /status (ADR: kit/knowledge/ADR-K18.md) | ⬜ |
| K19 | 2026-11-03 | (ws tools) | tools/wscore/status.py · gh.py · kit/job/scripts/ws/job_status.py | สถานะรายงาน/รวม: (1) report อ่านบทเรียนแบบตาราง `| L# |` ของ /lesson ไม่ได้ → STATUS.md/lessons.csv ว่าง (2) github_actions.log --body หลายบรรทัดทำให้ status แสดงบรรทัดขยะ (3) /status รายงานคำถามเปิดเฉพาะที่ยังไม่ติ๊ก ไม่ตรงกับ G6 → เพิ่ม 'ค้างค่า' (เกณฑ์ decision_state เดียวกับ G6) ทั้งรายงาน/รวม (4) เตือนเมื่อ verify.json เก่ากว่าไฟล์งาน (SS_ESIM: G3 ขึ้น ⛔ ปลอมจาก verify.json เก่า) | ⬜ |
| K21 | 2026-11-04 | projects/SS_ESIM/jobs/ss_esim_landing_to_discovery | 1 ไฟล์ (kit/patches/20261104_K21-sync-guid-keys) | sync_guid_from_export เขียน _guid_keys.json (builder อ่านไฟล์นี้) — แก้ ODI-17591 ตอน import ทับ | ⬜ |
