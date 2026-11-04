# CHANGES-ws — การแก้ kit ที่ยังไม่ได้ backport เข้า setup_migrate.ps1

> `workspace.py kit-promote` เพิ่มแถว · `extract-kit` (setup รุ่นใหม่) ต้องให้ทุกแถวเป็น ✅ ก่อน

| K# | วันที่ | จากงาน | ไฟล์ | เหตุผล | backport แล้ว |
|---|---|---|---|---|---|
| K18 | 2026-11-03 | (ws tools) | tools/wscore/jobs.py · check.py · init.py · tools/workspace.py · .gitignore · kit/job_base/ (84) · kit/job/.claude/commands/status.md | ไฟล์ kit ในงานไม่ commit ซ้ำ — ต้นฉบับชุดเดียว kit/job_base + sync-kit + ล็อกรุ่นหลัง G3 · แก้ .gitignore STATUS.md กลืน /status (ADR: kit/knowledge/ADR-K18.md) | ⬜ |
