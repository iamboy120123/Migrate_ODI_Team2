"""check — ตรวจ workspace ก่อน commit / import (CI workspace-check รันตัวนี้ด้วย --ci)

ERROR (exit 1): ทะเบียน · ODI code / id_base ไม่ตรงใบงานหรือชนกัน · ไฟล์ต้องห้ามใน Git · ของกลางถูกแก้นอก update-target
                · import ไปแล้วทั้งที่เลขยังไม่ยืนยัน · รหัสผ่านในไฟล์
WARN: ของกลางในงานไม่ตรงรุ่นปัจจุบัน · ค่า ODI ของงานต่างจากของกลาง · การแก้ kit ค้างในงาน · ล็อกค้างเกินเวลา
"""
from __future__ import annotations

import re

from . import common as C
from . import jobs as J
from . import target as T

FORBIDDEN_PATHS = [
    (re.compile(r"(^|/)input/run_results/"), "ผลรันจริง (input/run_results) — ส่งทางช่องทางที่ทีมอนุญาต ไม่ขึ้น Git"),
    (re.compile(r"(^|/)shared/db\.local\.json$"), "ค่าการเชื่อมต่อฐาน (db.local.json)"),
    (re.compile(r"(^|/)_shared_[^/]+$"), "สำเนาของกลางในงาน (_shared_*) — มีที่ shared/target ที่เดียว"),
    (re.compile(r"\.bak-\d+"), "ไฟล์ backup"),
    (re.compile(r"(^|/)\.claude/settings\.local\.json$"), "settings ส่วนตัวของ Claude Code"),
    (re.compile(r"\.(pem|key|p12|pfx|jks)$", re.I), "ไฟล์กุญแจ / certificate"),
]
SECRET = re.compile(r"(password|passwd|pwd)\s*[:=]\s*['\"]?[^\s'\"<>{}$,)]{3,}|jdbc:oracle:thin:[^@\s]+/[^@\s]+@|-----BEGIN [A-Z ]*PRIVATE KEY-----", re.I)
IP = re.compile(r"(?<![\d.])(?:\d{1,3}\.){3}\d{1,3}(?!\.\d|\d)")
IP_OK = {"0.0.0.0", "127.0.0.1", "255.255.255.255"}
HOST = re.compile(r"jdbc:oracle:thin:@\S+|\(\s*HOST\s*=\s*[^)\s]+|@//[\w.-]+(?::\d+)?/|\b(?:host|hostname|server)\s*[:=]\s*['\"]?[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+", re.I)
HOST_OK = re.compile(r"<[^>]*>|\{[^}]*\}|example|company|localhost|x\.x|\.\.\.|…", re.I)
SECRET_OK = re.compile(r"ORA_R[OW]_PASSWORD|<password>|\*\*\*|password\s*[:=]\s*(null|none|\"\"|''|<)", re.I)


def is_kit_code(f: str) -> bool:
    return f.endswith((".py", ".ps1", ".yml", ".cmd")) and (f.startswith(("tools/", "kit/", ".github/")) or "/scripts/" in f or f.startswith("scripts/"))


def tracked() -> list[str]:
    if not (C.ROOT / ".git").exists():
        return [p.relative_to(C.ROOT).as_posix() for p in C.ROOT.rglob("*") if p.is_file() and ".git" not in p.parts]
    return [l for l in C.git("ls-files", check=False).splitlines() if l]


def run_check(args):
    C.require_workspace()
    errs, warns = [], []
    t = C.team()
    # ---- ทะเบียน + เลข
    seen_code, seen_base = {}, {}
    for j in C.job_dirs():
        m = C.job_meta(j)
        cfg = C.read_json(j / "config/config.json")
        o = cfg.get("odi") or {}
        name = C.rel(j)
        for k in ("project", "issue", "branch"):
            if not m.get(k):
                errs.append(f"{name}: job.json ไม่มี {k}")
        if m.get("state") == "released":
            continue
        code, base = o.get("project_code"), o.get("id_base")
        if not code or base is None:
            errs.append(f"{name}: config ไม่มี odi.project_code / id_base")
            continue
        if not C.latin1_ok(str(code)) or len(str(code)) > 30:
            errs.append(f"{name}: ODI code {code} ต้องเป็น ISO-8859-1 และยาวไม่เกิน 30")
        if m.get("issue") and m.get("id_source") != "import" and not m.get("issue_unconfirmed"):
            want = J.id_base(int(m["issue"]))
            if int(base) != want:
                errs.append(f"{name}: id_base {base} ≠ เลขจากใบงาน #{m['issue']} ({want})")
        if m.get("issue_unconfirmed"):
            (errs if "| IMPORT" in C.read_text(j / "status/IMPORT_LOG.md") else warns).append(
                f"{name}: เลข #{m.get('issue')} ยังไม่ยืนยัน" + (" แต่ import ไปแล้ว" if "| IMPORT" in C.read_text(j / "status/IMPORT_LOG.md") else " (import ไม่ได้จนกว่าจะยืนยัน)"))
        if code in seen_code:
            errs.append(f"ODI code {code} ซ้ำ: {name} กับ {seen_code[code]}")
        if int(base) in seen_base:
            errs.append(f"id_base {base} ซ้ำ: {name} กับ {seen_base[int(base)]}")
        seen_code[code], seen_base[int(base)] = name, name
        # ของกลาง
        lock = m.get("target_lock") or {}
        se = T.current_smart_export()
        if se and lock.get("smart_export") and lock["smart_export"] != C.sha256(se) and not lock.get("locked_at_g3"):
            warns.append(f"{name}: ใช้ Smart Export รุ่นเก่า — `workspace.py sync-kit --job {j.name}`")
        tv = t.get("target") or {}
        for k in ("logical_schema", "context_code", "work_user"):
            if tv.get(k) and o.get(k) and str(tv[k]).upper() != str(o[k]).upper():
                warns.append(f"{name}: odi.{k} = {o[k]} ต่างจากของกลาง {tv[k]}")
        try:
            le = J.local_edits(j)
        except Exception:
            le = []
        if le:
            warns.append(f"{name}: แก้ไฟล์ kit ค้างในงาน {len(le)} ไฟล์ (เช่น {le[0]}) — kit-promote")
    # ---- เลขชนกับงานบน branch อื่นที่ fetch มาแล้ว (ในเครื่องเท่านั้น · CI เห็นแค่ PR ของตัวเอง)
    if not args.ci:
        from .status import remote_jobs
        for r in remote_jobs(fetch=False):
            if (C.ROOT / r["path"]).exists() and r["ref"].startswith("origin/job/") and C.job_meta(C.ROOT / r["path"]).get("issue") == r["meta"].get("issue"):
                continue
            ro = r.get("odi") or {}
            mine = seen_code.get(ro.get("project_code"))
            if mine and mine != r["path"]:
                errs.append(f"ODI code {ro.get('project_code')} ซ้ำ: {mine} กับ {r['path']} บน {r['ref']}")
            mb = seen_base.get(int(ro.get("id_base") or -1))
            if mb and mb != r["path"]:
                errs.append(f"id_base {ro.get('id_base')} ซ้ำ: {mb} กับ {r['path']} บน {r['ref']}")
    # ---- ไฟล์ต้องห้ามใน Git + รหัสผ่าน
    files = tracked()
    for f in files:
        for rx, why in FORBIDDEN_PATHS:
            if rx.search(f) and not f.endswith(".gitkeep"):
                errs.append(f"ไฟล์ต้องห้ามใน Git: {f} — {why}")
                break
    for f in files:
        p = C.ROOT / f
        if not p.exists() or p.stat().st_size > 2_000_000 or p.suffix.lower() in (".zip", ".png", ".jpg", ".pptx", ".xlsx", ".pdf"):
            continue
        if is_kit_code(f):
            continue  # โค้ดของ kit / เครื่องมือ (มีคำว่า password ในคำอธิบายและชื่อตัวแปร) — ตรวจผ่าน PR review ของ Code Owner
        txt = C.read_text(p)
        for i, l in enumerate(txt.splitlines(), 1):
            if SECRET.search(l) and not SECRET_OK.search(l) and "containsCipherText" not in l:
                if f.endswith(".xml") and "<Field name=" in l:
                    continue  # Smart Export: field รหัสที่เข้ารหัสของ ODI ไม่ใช่รหัสที่คนพิมพ์ (และ read_smart_export ไม่อ่าน)
                errs.append(f"อาจมีรหัสผ่าน / connection string: {f}:{i}")
                break
            if f.lower().endswith(".xml"):
                continue  # Smart Export มี JDBC URL ของ Topology อยู่แล้ว (ของกลาง · ODI export เอง)
            hm = HOST.search(l)
            if hm and not HOST_OK.search(hm.group(0)):
                errs.append(f"มีชื่อเครื่อง / connection string ของฐาน: {f}:{i} — ย้ายไป shared/db.local.json (ไม่ขึ้น Git)")
                break
            if not (f.lower().endswith((".csv", ".tsv", ".json")) and "/input/" in f"/{f}") and "knowledge/reference/" not in f \
                    and not re.search(r"FQName|Lengths", l):
                bad_ip = [x for x in IP.findall(l) if x not in IP_OK and all(int(p_) <= 255 for p_ in x.split("."))
                          and not re.search(r"version|v\d|\d+\.\d+\.\d+\.\d+-", l, re.I)]
                if bad_ip:
                    errs.append(f"มี IP {bad_ip[0]}: {f}:{i} — ห้ามใส่ host / IP ในไฟล์ที่ขึ้น Git (ใช้ shared/db.local.json)")
                    break
    # ---- ของกลางถูกแก้นอก update-target
    src = C.read_text(C.TARGET / "SOURCE.md")
    for p in [T.current_smart_export(), T.COL_FILE]:
        if p and p.exists():
            short = C.sha256(p)[:16]
            if f"`{C.rel(p)}`" in src and short not in src:
                errs.append(f"{C.rel(p)} ถูกแก้นอก update-target (sha256 ไม่ตรง SOURCE.md)")
    # ---- Wiki: หลักฐาน · ข้อมูลลับ · ไม่ลบประวัติ (ERROR) · ติดหมวด · อ้าง L# (WARN)
    try:
        we, ww = C.wiki().check(C.ROOT, getattr(args, "base", None) or "HEAD")
        errs += [f"Wiki: {x}" for x in we]
        warns += [f"Wiki: {x}" for x in ww]
    except Exception as e:  # Wiki ตรวจไม่ได้ ไม่ใช่เหตุให้ check ล้ม
        warns.append(f"Wiki ตรวจไม่ได้: {e}")
    # ---- ล็อกค้าง (อ่าน GitHub เฉพาะเมื่อได้รับอนุญาต / ใน CI)
    if not args.ci and (C.ROOT / ".git").exists() and not C.git("remote", check=False):
        warns.append("ยังไม่มี repo บน GitHub (git remote ว่าง) — เลขงาน · ล็อก import · การอนุมัติผ่าน PR ใช้ไม่ได้ · "
                     "ทดลองคนเดียวก็ควรเปิด repo private ตั้งแต่วันแรก: git remote add origin <url> แล้ว workspace.py init-github")
    if not args.ci:
        loc = C.read_json(C.REGISTRY / "lock_local.json")
        if loc:
            warns.append(f"เครื่องนี้ยังถือล็อก ODI_DEV สำหรับ {loc.get('job')} ตั้งแต่ {loc.get('since')} — import-unlock เมื่อเสร็จ")
        # 2.12.0: ล็อกบน GitHub ค้างเกินเวลา (อ่านตามโหมด GitHub — แบบคนทำเองข้าม)
        try:
            from . import gh as G, lock as L
            if G.mode() != "c" and G.ready()[0]:
                n = G.lock_issue_number()
                st = L.lock_state(n) if n else None
                if st and st["holders"] and st["expired"]:
                    warns.append(f"ล็อก ODI_DEV บน GitHub ค้างเกิน {C.team()['lock']['expire_hours']} ชม.: {', '.join(st['holders'])} "
                                 f"ตั้งแต่ {L._ago(st['since'])} ที่แล้ว (งาน {st['job'] or '?'}) — ทักเจ้าของก่อน · ถ้าแน่ใจว่าลืมปลด: "
                                 f"workspace.py import-unlock --force --reason \"…\" · {st['url']}")
        except C.Stop as e:
            warns.append(f"ตรวจล็อกบน GitHub ไม่ได้: {str(e).splitlines()[0]}")
        except Exception:
            pass
    C.section(f"🔎 workspace check · {len(C.job_dirs())} งาน")
    for e in errs:
        C.fail(e)
    for w in warns:
        C.warn(w)
    if not errs and not warns:
        C.ok("ผ่านทุกข้อ")
    elif not errs:
        C.ok(f"ไม่มี ERROR · คำเตือน {len(warns)} ข้อ")
    if errs:
        raise C.Stop(f"check ไม่ผ่าน: ERROR {len(errs)} ข้อ — แก้ก่อน commit / import")
