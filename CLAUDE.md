# ⚠️ นี่คือ root ของ Migration Workspace — ห้ามทำงาน migrate ที่นี่

ถ้าคุณ (Claude Code) ถูกเปิดที่โฟลเดอร์นี้: **บอกผู้ใช้ทันที** ว่าต้องปิดแล้วเปิด Claude Code ใหม่ที่โฟลเดอร์งาน
`projects/<PROJECT>/jobs/<งาน>/` (1 งาน = 1 โฟลเดอร์ = 1 แชท = 1 branch) — ที่นั่นมี CLAUDE.md + คำสั่ง / กฎ / สถานะของงาน

ที่ root ทำได้แค่ (อธิบาย / ช่วยดูผล — ห้ามแก้ไฟล์ของงานใด ๆ จากที่นี่):
- คำสั่งของทีมผ่าน Terminal: `python tools/workspace.py <คำสั่ง>` (ดูรายการ: `python tools/workspace.py -h`)
  ตั้งทีม `init` · เปิดงาน `new-job` · ดูสถานะ `status` · ส่งต่องาน `handoff` · ล็อก import `import-lock` / `import-unlock` · ตรวจ `check` · ของกลาง `update-target`
- ขั้นของทีมทั้งหมด: `kit/knowledge/WORKFLOW.md` · หน้าแรก Wiki: `kit/knowledge/README.md` · กฎทีม: `kit/CLAUDE.kit.md`

ห้ามเสมอ: แก้ `kit/` · `shared/` · `tools/` นอก PR ของทีม · push เข้า main · ใส่รหัสผ่านในไฟล์ / แชท
