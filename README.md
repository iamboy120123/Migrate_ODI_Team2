# Migration Workspace — Blendata → ODI 14c (ทีม)

สร้างโดย `setup_migrate.ps1 -Mode Workspace` (2.15.0) · 1 repo ทั้งทีม · ของกลางชุดเดียว · แต่ละงานแยกโฟลเดอร์ แยกแชท แยก branch

## เริ่มต้น (ทำทีละข้อ)

| ใคร | ทำอะไร | คำสั่ง |
|---|---|---|
| Tech Lead (ครั้งเดียว) | ตั้งทีม 12 ข้อ | `python tools/workspace.py init` |
| Tech Lead (ครั้งเดียว) | ตั้ง GitHub (CI · ใบงานปักหมุด · labels) | `python tools/workspace.py init-github` |
| ทุกคน | ดึงของล่าสุด | `git switch main && git pull` · `python tools/workspace.py fix-mtime` · `python tools/workspace.py sync-kit --all` |
| เจ้าของงาน | เปิดงานใหม่ | `python tools/workspace.py new-job [--wave W1]` · Windows: `tools\new-job.ps1` |
| เจ้าของงาน | ทำงานในแชท | เปิด Claude Code ที่ `projects/<P>/jobs/<job>/` แล้ว `/next-step` |
| เจ้าของงาน | ก่อน / หลัง Smart Import (ไม่ต้อง push ก่อน) | `import-lock --job <job>` · `import-unlock --job <job>` · ต่อเวลา `import-lock --job <job> --extend --reason "…"` |
| Tech Lead | เพิ่ม / แก้การเชื่อมต่อฐาน (SIT / PROD · user ที่เขียนได้) | `python tools/workspace.py db-connect --env SIT` |
| ทุกคน | ค้น Wiki (บทเรียน · ศัพท์ · การตัดสินใจ ทุกชั้น) — หน้าแรก `kit/knowledge/README.md` | `python tools/workspace.py wiki-search <คำ>` · ในแชทงาน `/wiki <คำ>` |
| เจ้าของงาน | ส่งต่องานให้คนอื่น (เปลี่ยนเจ้าของ + เก็บประวัติ) | ในแชท `/handoff` · `python tools/workspace.py handoff --job <งาน> --to <ชื่อ>` |
| ทุกคน | ดูสถานะ | `python tools/workspace.py status` (เลือกเลขเพื่อดูงานนั้นทุกขั้น) · ในแชท `/status` |

ขั้นของทีมทั้งหมด: `kit/knowledge/WORKFLOW.md` · เปิด Claude Code ที่โฟลเดอร์งานเท่านั้น (ที่ root มี CLAUDE.md เตือนไว้)

Windows: ใช้ `tools\ws.cmd <คำสั่ง>` แทน `python tools\workspace.py <คำสั่ง>` ได้

## โครง

```
tools/          workspace.py + wscore/ (คำสั่งทั้งหมด) · ws.cmd · new-job.ps1
kit/            setup_migrate.ps1 · CLAUDE.kit.md (กฎทีมของ AI) · knowledge/ (Wiki ของทีม: WORKFLOW · lessons-learned · glossary-kit · reference/) · job/ (ไฟล์ที่วางลงทุกงาน) · patches/
shared/         team.json (ค่าของทีม) · approvers.txt · db.local.json (ค่าต่อฐาน · ในเครื่อง ไม่ขึ้น Git) · target/ (Smart Export · คอลัมน์ · constraint · environment-facts · target.json · SOURCE · CHANGELOG)
projects/<P>/   _project/ (glossary · DECISIONS) · jobs/<job>/ (1 Blendata workflow = 1 ODI package)
registry/       สร้างใหม่ได้เสมอ ไม่ commit (jobs.csv · import_log.csv · lessons.csv)
STATUS.md       สร้างโดย report ไม่ commit
```

## ทำงานเป็นทีม / ทดลองคนเดียว

**ทดลองคนเดียวก็ใช้ GitHub ตั้งแต่วันแรก** — เลขงาน (`id_base`) มาจากเลขใบงาน · ล็อก ODI_DEV อยู่ในใบงานปักหมุด · การอนุมัติผ่าน PR — ไม่มี repo = 3 อย่างนี้ใช้ไม่ได้ (`workspace.py check` เตือน) · เปิด repo **private** แล้ว `git remote add origin <url>` → `init-github` · ย้ายไปใช้กับทีมจริงได้โดยไม่ต้องเปลี่ยนวิธีทำงาน

| ขั้น | ใคร | ทำอะไร |
|---|---|---|
| 1 | Tech Lead | repo private · `init` → `init-github` · GitHub: branch protection ของ main (PR + Code Owners + CI 3 ตัว) · Actions Read and write |
| 2 | ทุกคน | `gh auth login` ด้วยบัญชีตัวเอง (token fine-grained เฉพาะ repo นี้ · ไม่มีสิทธิ์ Administration) · `git clone` → `fix-mtime` → `sync-kit --all` |
| 3 | เจ้าของงาน | `new-job` → branch ของงาน → push เร็ว (ไม่บังคับ แต่ทีมเห็นสถานะใน `STATUS.md`) |
| 4 | ผู้อนุมัติ | ตอบคำถาม / gate ใน PR: `/approve Q14 B` · `/approve G2.M1` · `/waive G2 Q3 "เหตุผล"` |

**ODI_DEV ใช้ร่วมกัน — กติกาทีม** (ระบบบังคับ `import-lock` เสมอ ไม่มีโหมดข้าม)

- ถือล็อกเฉพาะตอน Smart Import จริง ไม่จองล่วงหน้า · `import-lock` ไม่ต้อง push branch ก่อน
- import เสร็จ → `import-unlock` ทันที **ก่อน**ไปทดสอบ (ทดสอบ / รัน scenario ไม่ต้องถือล็อก) · กล่องสถานะในแชทเตือนถ้ายังถืออยู่
- ต้องใช้นานเกินเวลาที่ทีมตั้ง (ค่าเริ่ม 2 ชม. · `shared/team.json` `lock.expire_hours`) → `import-lock --job <งาน> --extend --reason "…"` (ทีมเห็นเหตุผลในใบงาน)
- ล็อกค้างของคนอื่น → ทักเจ้าของก่อน · แน่ใจว่าลืมปลด → `import-unlock --force --reason "…"` (บันทึกว่าใครปลดแทนเพราะอะไร)
- ดูว่าใครใช้อยู่: หน้า Issues (ใบงานปักหมุด) หรือ `workspace.py lock-status` · บริษัทห้าม AI ใช้ GitHub → โหมด GitHub ข้อ 3: ระบบบอกขั้นตอนให้คนใส่ชื่อบนเว็บเอง (ล็อกยังบังคับ)

## กติกาสำคัญ 5 ข้อ

1. 1 งาน = 1 โฟลเดอร์ = 1 แชท = 1 branch
2. จบขั้นต้อง `/update-status` แล้ว push
3. ห้าม import โดยไม่ผ่าน `import-lock`
4. ✅ มาจากผู้อนุมัติเท่านั้น (PR `/approve …` หรือ commit จากบัญชีผู้อนุมัติ)
5. AI จะเขียนขึ้น GitHub หรือต่อฐาน ต้องได้รับอนุญาตก่อน

## สิ่งที่ยังต้องยืนยันบนระบบจริง

- GitHub Actions 4 ตัว (approve-command · verify-approvals · secret-scan · workspace-check) — ต้องเปิด Actions ใน org และ Workflow permissions = Read and write
- ชื่อตาราง `SNP_*` ของ ODI 14c ที่ใช้ตรวจรหัสซ้ำ (import-lock) และเวลาต่อ step (perf_summary) — ยังไม่ยืนยันกับ repository ของทีม
- `run_sql.py` ต่อ Oracle จริง (ต้อง `pip install oracledb` + ตัวแปร `ORA_RO_PASSWORD` / `ORA_RW_PASSWORD`) · ทั้งอ่านและเขียน (DML / DDL) · การยืนยันชื่อตารางก่อนลบ
- Smart Import ของแพ็กเกจที่ generate ตั้งแต่ต้นจนจบ
