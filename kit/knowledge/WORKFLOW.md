# WORKFLOW — ลำดับขั้นของงาน migrate (Blendata → ODI 14c)

> ไฟล์กลางของทีม (ชั้น kit · แก้ผ่าน PR ของ kit) — ขั้นของทีมทั้งหมด ตั้งแต่ตั้งทีมจน go-live · เลขขั้นตรงกับ `/status` และ `wiki.py --step`
> ภายในแต่ละงานมี `knowledge/WORKFLOW.md` ของ kit (ขั้น 0–7 ตามคู่มือ + เลขอ้างอิง I / Q / BR / GAP / L / G) — ใช้คู่กัน ดูตารางเทียบเลขขั้นท้ายไฟล์
> ใช้เมื่อไม่แน่ใจว่าอยู่ขั้นไหน: `/status` (ตารางขั้นจริงของงาน) · `/next-step` (เลือกขั้นถัดไป = ขั้นแรกที่ยังไม่ผ่าน gate)

## ช่วง A — ตั้งทีม (ครั้งเดียว · Terminal ที่ root)

| ขั้น | ทำอะไร | คำสั่ง | ใคร |
|---|---|---|---|
| A0 | เปิด repo **private** บน GitHub (ทดลองคนเดียวก็ต้องมี — เลขงาน · ล็อก import · การอนุมัติใช้ GitHub) | GitHub → New repository | หัวหน้าทีม |
| A1 | ติดตั้งเครื่องมือ: Python 3.10+ · Git · GitHub CLI (`gh auth login`) · Claude Code | `setup_migrate.ps1` ตรวจให้ก่อนเริ่ม | ทุกคน |
| A2 | ตั้งทีม 12 ข้อ (ของกลาง DEV · ผู้อนุมัติ · โหมด GitHub / ฐานข้อมูล · คอลัมน์ · ค่าตั้งต้น) | `python tools/workspace.py init` | หัวหน้าทีม |
| A3 | CODEOWNERS · PR template · CI 4 ตัว · labels · ใบงานปักหมุด | `python tools/workspace.py init-github` | หัวหน้าทีม |
| A4 | GitHub: branch protection ของ main (PR + Code Owners + CI 3 ตัว) · Actions = Read and write · token ของทุกคนแบบ fine-grained เฉพาะ repo นี้ | ทำบนเว็บตามที่ init-github บอก (AI แก้ settings ของ repo ไม่ได้) | หัวหน้าทีม |

## ช่วง B — เปิดงาน (Terminal ที่ root)

| ขั้น | ทำอะไร | คำสั่ง | หลักฐานว่าเสร็จ |
|---|---|---|---|
| new | สร้างงาน + จองเลข (ใบงาน GitHub) | `python tools/workspace.py new-job [--wave W1]` (Windows: `tools\new-job.ps1`) | `job.json` + `config/config.json` (`odi.id_base`) |
| files | วางไฟล์ + ตอบ 5 ข้อ | ระบบถามต่อจาก new-job | `input/blendata/<workflow>/export_workflow.json` |
| branch | เปิด branch แล้ว push (ยังไม่ push = ไม่บล็อกขั้นไหน แค่ทีมไม่เห็นสถานะ) | `git switch -c job/<PROJECT>/<job>/R01` → `git push -u origin HEAD` (ถามก่อน) | branch บน origin |

เปิด Claude Code ที่โฟลเดอร์งานเท่านั้น (`projects/<PROJECT>/jobs/<job>/`) — **ห้ามเปิดที่ root**

## ช่วง C — 6 ขั้นในแชท (1 งาน = 1 แชท)

| ขั้น | ชื่อ | คำสั่ง | gate | ผ่านเมื่อ |
|---|---|---|---|---|
| 01 | ตรวจไฟล์ | `/next-step` → `/inputs` (เช็กของครบ) | – | ไฟล์ที่บังคับครบ หรือมีเหตุผลว่าไม่มี |
| 02 | ถาม–ตอบ (I1–I17) | `/intake` · `/decide` · `/br-catalog` | – | คำถามที่บล็อกปิด / มี waiver · ผู้อนุมัติ OK ตารางสรุป |
| 03.1 | ตรวจ environment | `/preflight` → `/run-pack` → `/read-results` | G0 | PREFLIGHT P1–P5 ✅ |
| 03.2 | แปลง SQL | `/convert` → `/sql-check` | G1 | ทุก task มี converted SQL หรือมีการตัดสินใจ |
| 03.3 | รีวิว ถูก + เร็ว | `/review-sql` (sql-reviewer + semantic-verifier) → `/gap-analysis` → `/review-report` (+ EXPLAIN PLAN ถ้าต้องการ) | G2 | flag ปิด · review log ไม่มี OPEN · Q3 ปิด / waiver · G2.M1 |
| 04 | สร้างแพ็กเกจ | `/inputs` → `/gen-export` → `/gen-ddl` → `/verify` → `/gate G3` | G3 | validate V1–V6 · pre_delivery_gate FAIL 0 · เกรด |
| 05.1 | รัน DDL | `run_sql.py output/ddl/<ไฟล์> --plan` (ขออนุญาต) หรือคนรันเอง | – | แถว `DDL` ใน `status/DEPLOY_LOG.md` + SELECT ยืนยัน |
| 05.2 | Smart Import | Terminal: `workspace.py import-lock` (ไม่ต้อง push ก่อน) → ODI Studio → `import-unlock` ทันที → `/gate G4` · นานเกินเวลา: `import-lock --extend` | G4 | `status/IMPORT_LOG.md` · G4.M1–M2 |
| 05.3 | ทดสอบ + ความเร็ว | `/run-pack` → (คนรัน scenario) → `/read-results` → `read_odi_log.py --session <เลข>` | G5 | assertion ผ่าน · `SUMMARY_05_PERFORMANCE.md` |
| 06 | เทียบผลกับ Blendata | `/validation` → `/compare-d2` | G5 | L1 → L2 → L3 (L3 รายแถวถามก่อนเสมอ) ตรง · G5.M2–M3 |

จบทุกขั้น: `/update-status` (+ ถามเรื่องบทเรียน → `/lesson`) แล้ว push (ถามก่อน) · เริ่มทุกขั้น: `python scripts/ws/wiki.py --step <ขั้น>`

## ช่วง D — ส่งมอบและ go-live

| ขั้น | ทำอะไร | คำสั่ง | gate |
|---|---|---|---|
| handoff | HANDOVER + รายการตาราง · ส่งต่องาน (เปลี่ยนเจ้าของ) | `/handoff` · `workspace.py handoff --job <งาน> --to <ชื่อ>` | – |
| PR | draft → ready · CI 3 ตัว · review (CODEOWNERS) · merge · tag | GitHub | – |
| cutover | runbook · rollback · parallel run · backfill | `/cutover` → `/gate G6` | G6 |
| go-live | ขึ้นจริง + sign-off | `/gate G7` | G7 |

## งานที่เป็นของคนเสมอ

Smart Import · รัน scenario / package · Generate Scenario · export Smart Export ใน ODI Studio · รันบน Blendata · ตั้งรหัสผ่าน (ตัวแปรบนเครื่อง / Topology) · อนุมัติ ✅ (`/approve` · `/waive` ใน PR หรือผู้อนุมัติตอบในแชทแล้ว commit เอง)

## เมื่อไม่ผ่าน

- gate BLOCKED → `/gate <G>` บอกข้อที่ขาด · อยากไปต่อ = ผู้อนุมัติ `/waive <G> <ข้อ> "เหตุผล"` ใน PR
- ทดสอบพัง → `/diagnose` → แก้ที่ต้นทาง → กลับขั้น 03–04 → build ใหม่ → import ทับ
- เปลี่ยนคำตอบเดิม → `/decide Q<n>` (บอกผลกระทบ → อนุมัติใหม่)
- workflow ของ Blendata เปลี่ยน / ของกลางเปลี่ยนหลัง G3 → `workspace.py new-round --job <งาน> --kind remigrate|target`

## ลำดับความสำคัญของกฎ (เมื่อขัดกัน)

1. การตัดสินที่อนุมัติแล้วของงาน (`status/OPEN_DECISIONS.md` · `status/GATES.md` · waiver)
2. `../../_project/DECISIONS.md` ของ project
3. `kit/CLAUDE.kit.md` (กฎทีม — ชนะเรื่องทีม / GitHub / สถานะ / ใครเป็นคนรัน query)
4. `CLAUDE.md` ของงาน + `.claude/rules/` (กฎ kit)
5. `knowledge/reference/` (คู่มืออ้างอิง อ่านอย่างเดียว)

## เทียบเลขขั้น: ทีม (`/status`) ↔ ในงาน (`knowledge/WORKFLOW.md` ของ kit)

| ทีม | ในงาน |
|---|---|
| 01 ตรวจไฟล์ | 0 Start / Resume |
| 02 ถาม–ตอบ | 1 Intake · 1.5 Business Rules · 2D Confirm Decision |
| 03.1 preflight | 1 Intake (ส่วน Preflight P1–P5 · G0) |
| 03.2 – 03.3 | 2 SQL (G1 · G2) |
| 04 | 3–5 Build (G3) |
| 05.1 – 05.2 | 6 Handover / Import (G4) |
| 05.3 – 06 | 7 Validate (G5) |
| ช่วง D | 6 Handover · 7 Cutover (G6 · G7) |
