# Wiki / Knowledge — หน้าแรก

ความรู้ของงาน migrate Blendata → ODI 14c ทั้งทีม · **อ่าน / บันทึกได้ทุกขั้น** · ใช้เป็นแหล่งอ้างอิงร่วมกันของทุกคน
แก้ไฟล์ในโฟลเดอร์ `kit/knowledge/` ผ่าน PR ของ kit เท่านั้น (ผู้อนุมัติ review → merge → `sync-kit`)

## ความรู้ 4 ชั้น (กว้าง → แคบ)

AI อ่านจากชั้นกว้างก่อน · เมื่อขัดกัน **ชั้นที่แคบกว่าชนะ** (การตัดสินที่อนุมัติแล้ว > กฎ kit > reference)

| ชั้น | อยู่ที่ | มีอะไร |
|---|---|---|
| 1 · kit (ทุกงาน) | `kit/knowledge/` | `WORKFLOW.md` ขั้นของทีมตั้งแต่ตั้งทีมจน go-live · `lessons-learned.md` บทเรียนที่ทีมอนุมัติ (LT#) · `glossary-kit.md` ศัพท์กลาง · `reference/` คู่มืออ้างอิง (อ่านอย่างเดียว · sync ลงทุกงาน) · `kit/CLAUDE.kit.md` กฎทีม |
| 2 · ระบบปลายทาง | `shared/target/` | Smart Export · คอลัมน์ทั้ง schema · `environment-facts.md` (version · NLS · timezone) · `CHANGELOG.md` เปลี่ยนอะไร เมื่อไร เพราะอะไร |
| 3 · project | `projects/<P>/_project/` | `glossary.md` ศัพท์ธุรกิจ · `DECISIONS.md` การตัดสินครั้งเดียวใช้ทุกงานใน project |
| 4 · งาน | `projects/<P>/jobs/<งาน>/` | `knowledge/` (WORKFLOW ขั้น 0–7 ในงาน · lessons-learned §2 · environment-facts · glossary) · `status/` (INTAKE · BUSINESS_RULES · GAP_ANALYSIS · OPEN_DECISIONS) · `.design/` (ADR · specs) |

## ใช้ Wiki ทุกขั้น (เส้นม่วงในแผนภาพ)

| เมื่อไร | ทำอะไร | คำสั่ง |
|---|---|---|
| **เริ่มขั้น** (01–06) | ดึงบทเรียนที่เกี่ยวกับขั้นนั้นมาอ่านก่อน (ทีม · project · งานนี้ · งานอื่น) | `python scripts/ws/wiki.py --step 03` |
| ระหว่างทำ | เสนอแนวทาง / คำแนะนำทุกครั้ง ต้องเขียน **"อ้างอิง: L# …"** หรือ "อ้างอิง: ไม่มีบทเรียนที่เกี่ยวข้อง" | — |
| สงสัยเรื่องไหน | ค้นทุกชั้น (เพิ่ม `--remote` = branch งานของคนอื่นที่ยังไม่ merge) | `/wiki <คำ>` · `python tools/workspace.py wiki-search <คำ>` |
| **จบขั้น** | `/update-status` ถาม 1 ข้อ: ขั้นนี้มีบทเรียนจะบันทึกไหม → `/lesson` | `/update-status` |
| ใช้ได้ทุกงาน | เสนอเข้า kit | `/kit-backport` (บทเรียน) · `python tools/workspace.py kit-promote` (สคริปต์) |
| ทีมเห็น | push → `report` รวมบทเรียนใหม่ของทุกงานใน `STATUS.md` และ `registry/lessons.csv` | `python tools/workspace.py report` |
| ผู้อนุมัติ | review PR → merge → kit version ใหม่ → `sync-kit` ทุกงาน | PR ของ kit |

## บันทึกความรู้แบบไหน ที่ไหน

| ความรู้แบบไหน | บันทึกที่ | คำสั่ง | เลขอ้างอิง |
|---|---|---|---|
| ปัญหาที่เจอ + ผลถ้าพลาด + วิธีทำ (ติดหมวด / ขั้น เช่น `03 · performance`) | `knowledge/lessons-learned.md` ของงาน §2 | `/lesson` | L# |
| บทเรียนที่ใช้ได้ทุกงาน (ผ่านการอนุมัติ) | `kit/knowledge/lessons-learned.md` | `/kit-backport` → PR | LT# |
| ข้อเท็จจริงของงาน (ชนิดคอลัมน์ landing · schedule · Spark config) | `knowledge/environment-facts.md` ของงาน | `/lesson` · `/preflight` | — |
| ข้อเท็จจริงระดับ env (Oracle version · NLS · timezone) | `shared/target/environment-facts.md` | PR แยก | — |
| ศัพท์ | `knowledge/glossary.md` · `_project/glossary.md` · `kit/knowledge/glossary-kit.md` | `/lesson` | — |
| การตัดสินใจ | `status/OPEN_DECISIONS.md` · `.design/adr/` · `_project/DECISIONS.md` | `/decide` · `/adr` | Q# · ADR-NNN |
| business rule · ความต่าง As-Is / To-Be | `status/BUSINESS_RULES.md` · `status/GAP_ANALYSIS.md` | `/br-catalog` · `/gap-analysis` | BR-nn · GAP-nn |
| บั๊ก / การแก้ของ kit | `kit/CHANGES-ws.md` | `kit-promote` · `/kit-backport` | K# |

## กติกาของ Wiki (ตรวจอัตโนมัติด้วย `workspace.py check` และ CI)

- **มีหลักฐานทุกข้อ** — ช่อง "หลักฐาน" ห้ามว่าง (ไฟล์ผลใน `input/run_results/…` · log · บรรทัด SQL · ข้อความ SA พร้อมวันที่)
- **ไม่มีข้อมูลลับ** — ห้ามรหัสผ่าน / connection string / ข้อมูลลูกค้า
- **ไม่ลบประวัติ** — เลข L# / LT# ที่เคยมีต้องยังอยู่ · ขัดกับข้อเดิม = แก้ข้อเดิมพร้อมหมายเหตุวันที่
- **ติดหมวด / ขั้น** — ใช้ดึงบทเรียนตามขั้น (ไม่ใส่ = เตือน)
- **AI อ้าง L#** — คำแนะนำใน OPEN_DECISIONS ที่ไม่อ้างบทเรียน = เตือน
