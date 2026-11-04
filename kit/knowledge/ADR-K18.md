# ADR K18 — ไฟล์ kit ในงานไม่ commit ซ้ำ · ต้นฉบับชุดเดียวที่ `kit/job_base/`

| | |
|---|---|
| สถานะ | Proposed (รอ review ใน PR ของ kit) |
| วันที่ | 2026-11-03 |
| ผู้เสนอ | Mana (SA) |
| กระทบ | `tools/wscore/jobs.py` · `check.py` · `init.py` · `tools/workspace.py` · `.gitignore` · `kit/job_base/` (ใหม่) |

## 1. ปัญหา
- ทุกงานมีสำเนาไฟล์ kit 111 ไฟล์ (`scripts/` · `.claude/commands|agents|rules|skills|workflows` · `knowledge/reference/`) ~1.9 MB และ commit ขึ้น Git ทุกงาน → PR มี diff ของ kit ปน · งาน N งาน = N สำเนา
- ต้นฉบับของ scripts / agents อยู่ฝังใน `setup_migrate.ps1` เท่านั้น (ไม่มีเป็นไฟล์ใน kit) → ต้องมี PowerShell ถึงจะได้ต้นฉบับ
- พบบั๊กร่วม: `.gitignore` บรรทัด `STATUS.md` + `core.ignorecase=true` (Windows) กลืน `.claude/commands/status.md` → **คำสั่ง `/status` ไม่เคยขึ้น Git** (ทั้ง `kit/job/` และในงาน) · คน clone ไปไม่มี `/status`

## 2. ตัวเลือก
| # | ตัวเลือก | ผล |
|---|---|---|
| A | คงเดิม (copy + commit) | ไม่แก้ปัญหา |
| B | ย้าย scripts/.claude ไปกลาง แล้วแก้ path ในงาน | พัง: Claude Code หา `.claude/` จากโฟลเดอร์งาน · permission `Bash(python scripts/*)` · ~30 ไฟล์อ้าง `knowledge/reference/` · เสียการล็อกรุ่นหลัง G3 |
| C | symlink / junction | Git บน Windows (`core.symlinks=false`) เป็นไฟล์ข้อความ · clone แล้วพัง |
| **D** | **path เดิมในงาน แต่ไม่ commit · ต้นฉบับชุดเดียวที่ `kit/job_base/` · `sync-kit` วางให้ · ล็อกรุ่นด้วย commit** | **เลือก** |

## 3. การตัดสินใจ (D)
1. `kit/job_base/` = ไฟล์ kit ต้นฉบับ (ไม่เติมค่าต่องาน) ตรง sha ของ `kit/base_manifest.json` — สร้างโดย `workspace.py kit-base` (probe จาก setup ด้วย PowerShell) หรือ `kit-base --from-job J` (ดึงจากงาน ตรวจ sha ทุกไฟล์ · ใช้ `*.bak-*` ถ้าไฟล์ถูกแก้)
2. ลำดับชั้นของ `sync-kit`: `kit/job_base` → `kit/knowledge/reference` → `kit/job` (overlay) → `kit/patches` (ชั้นหลังทับชั้นก่อน)
3. `.gitignore` ช่วง `ws:kit-managed` (ระบบสร้างจาก `TRACK_DIRS` + `templated`) — ไฟล์ templated (`.claude/rules/odi-step-sql.md`, `knowledge/reference/claude-system.md`) **ยัง commit ตามเดิม**
4. ล็อกรุ่น: `.ws_kit.json` บันทึก `kit_commit` + sha ทุกไฟล์ (commit) · งานที่ผ่าน G3 → `sync-kit` แตก kit รุ่นที่ล็อกจาก `git archive` (`registry/_kit/<commit>/` ไม่ commit) · เปลี่ยนรุ่น = `new-round` หรือ `sync-kit --latest`
5. `check` (ในเครื่อง): แก้ไฟล์ kit ในงานแล้วไม่ promote = **❌ error** (เพราะการแก้จะไม่ขึ้น Git) · ยังไม่ sync หลัง clone = ⚠️
6. `.gitignore` `STATUS.md` → `/STATUS.md` (root เท่านั้น) ทั้งใน repo และแม่แบบใน `init.py`

path ในงานไม่เปลี่ยน → ไม่ต้องแก้ CLAUDE.md / commands / scripts / hooks / settings.json

## 4. ผลที่ตามมา
- ✅ ต่องานเหลือเฉพาะไฟล์ของงาน (SS_ESIM: 299 → ~190 ไฟล์ใน Git) · PR ของงานไม่มี diff ของ kit
- ✅ แก้ kit ที่เดียว (`kit-promote` → `kit/patches` → `sync-kit --all`)
- ⚠️ หลัง clone / pull ต้อง `sync-kit --all` ก่อนเปิดแชท (README ทำอยู่แล้ว) — ไม่ทำ = hook / slash command ไม่มี (`check` เตือน)
- ⚠️ CI (`workspace-check`) มองไม่เห็นการแก้ kit ในงาน → กันที่ `check` ในเครื่อง · (ข้อเสนอต่อ: hook `guard_owned_files` block การแก้ `scripts/**` ในงาน)
- ⚠️ งานที่ผ่าน G3 ก่อน K18 ไม่มี `kit_commit` → ใช้ kit ปัจจุบันเหมือนเดิม (ไม่ถอยหลัง)
- ⚠️ ไฟล์ scripts เฉพาะงาน (ไม่ใช่ของ kit) ห้ามวางใน `scripts/` (ถูก ignore) → วางใน `scripts_job/` (ข้อตกลงใหม่)

## 5. ผลทดสอบ (สำเนา repo บน VM · ไม่แตะ repo จริง)
| # | ทดสอบ | ผล |
|---|---|---|
| T1 | `kit-base --from-job ss_esim_landing_to_discovery` | 84 ไฟล์ตรง sha · 13 ไฟล์ที่ overlay ทับ ข้ามได้ (probe บน Windows จะได้ครบ 97) |
| T2 | `--untrack` ขณะมีการแก้ค้าง | หยุด ✅ (กันการแก้หาย) |
| T3 | `--untrack` หลัง promote | ไฟล์ kit ออกจาก Git · templated 2 ไฟล์ยังอยู่ ✅ |
| T4 | clone ใหม่ → `check` → `sync-kit --all` | check เตือน 111 ไฟล์ · sync แล้ว **113/113 ไฟล์ตรงกับงานจริงในเครื่อง (diff 0)** ✅ |
| T5 | ผ่าน G3 → แก้ kit → `sync-kit` | ได้รุ่นที่ล็อก ✅ · `--latest` ได้รุ่นใหม่ ✅ |
| T6 | แก้ `scripts/checks/grade.py` ในงาน → `check` | ❌ error ✅ · `check --ci` ไม่ติด ✅ |
| T7 | `git apply --check K18.patch` กับ repo จริง | ผ่าน ✅ |
