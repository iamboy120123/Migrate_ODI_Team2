"""
wiki.py — Wiki / Knowledge ของ workspace (2.11.0): อ่าน · ค้นหา · ตรวจ ความรู้ 4 ชั้น

ชั้นความรู้ (กว้าง → แคบ · ชั้นแคบชนะเมื่อขัดกัน: การตัดสินที่อนุมัติแล้ว > กฎ kit > reference):
  kit      kit/knowledge/ (lessons-learned ของทีม · glossary-kit · reference/ · README = หน้าแรกของ Wiki)
  target   shared/target/ (environment-facts · CHANGELOG ของระบบปลายทาง)
  project  projects/<P>/_project/ (glossary · DECISIONS)
  job      projects/<P>/jobs/<งาน>/knowledge/ (lessons-learned · environment-facts · glossary) + status/OPEN_DECISIONS.md

Usage (จากโฟลเดอร์งาน หรือ root ของ workspace):
    python scripts/ws/wiki.py --step 03            # บทเรียนที่เกี่ยวกับขั้นนี้ (ทีม + project + งานนี้ + งานอื่น) — อ่านก่อนเริ่มขั้น
    python scripts/ws/wiki.py --search overwrite   # ค้นทุกชั้น (เพิ่ม --remote = ค้นใน branch งานของคนอื่นที่ fetch แล้ว)
    python scripts/ws/wiki.py --check              # ตรวจ: บทเรียนมีหลักฐาน · ไม่มีข้อมูลลับ · ไม่ลบประวัติ · คำแนะนำอ้าง L#
"""
from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path

for _s in (sys.stdout, sys.stderr):
    try:
        _s.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

HERE = Path(__file__).resolve().parents[2]          # root ของงาน (เมื่ออยู่ในงาน)
ID_RX = re.compile(r"^(L-?T\d+|L\d+|E\d+)$", re.I)
SECRET = re.compile(r"(password|passwd|pwd|รหัสผ่าน)\s*[:=]\s*['\"]?[^\s'\"<>{}$,)]{3,}|jdbc:oracle:thin:[^@\s]+/[^@\s]+@|-----BEGIN [A-Z ]*PRIVATE KEY-----", re.I)
SECRET_OK = re.compile(r"ORA_R[OW]_PASSWORD|<password>|\*\*\*|(password|รหัสผ่าน)\s*[:=]\s*(null|none|\"\"|''|<)", re.I)
NEW_HEADER = "| # | หมวด / ขั้น | ปัญหาที่เจอ | ผลถ้าพลาด | วิธีทำ | หลักฐาน | วันที่ / โดย |"
NEW_SECTION = "## 2. บทเรียนของงานนี้ (/lesson)"
STEPS = {
    "01": ("ตรวจไฟล์ (intake files)", ["export", "json", "input", "intake", "ไฟล์", "workflow", "task"]),
    "02": ("ถามและเสนอแนวทาง", ["intake", "decision", "overwrite", "scope", "landing", "partition", "truncate", "delete", "q", "waiver", "procedure", "mapping"]),
    "03": ("pre-flight · convert · review SQL", ["spark", "sql", "nls", "timezone", "regex", "cast", "convert", "review", "ansi", "timestamp", "preflight", "pre-flight", "qualify", "schema", "performance", "explain", "compile"]),
    "04": ("build + grade", ["xml", "smart export", "globalid", "package", "procedure", "build", "gen-export", "validate", "verify", "grade", "zip", "guid"]),
    "05": ("import และรันจริงใน ODI DEV", ["import", "scenario", "topology", "ddl", "seed", "run pack", "snp", "log", "lag", "mock", "deploy", "session", "commit"]),
    "06": ("เทียบผลและอนุมัติ", ["d1", "d2", "d3", "compare", "validation", "cutover", "baseline", "assertion", "expected", "เทียบ", "parallel"]),
}


# ---------------------------------------------------------------- ที่อยู่
def ws_root(start: Path | None = None) -> Path | None:
    s = (start or HERE).resolve()
    for p in [s, *s.parents]:
        if (p / "workspace.json").exists() or (p / "tools" / "workspace.py").exists():
            return p
    return None


def kit_knowledge(w: Path) -> Path:
    return w / "kit" / "knowledge"


def sources(w: Path) -> list[tuple[str, str, Path]]:
    """(ชั้น, ชื่อ, ไฟล์) ทุกไฟล์ความรู้ในเครื่อง"""
    out = []
    kk = kit_knowledge(w)
    for f in sorted(kk.glob("*.md")) if kk.exists() else []:
        out.append(("kit", f.name, f))
    for f in sorted((kk / "reference").rglob("*.md")) if (kk / "reference").exists() else []:
        out.append(("kit", "reference/" + f.relative_to(kk / "reference").as_posix(), f))
    for n in ("environment-facts.md", "CHANGELOG.md", "SOURCE.md"):
        f = w / "shared" / "target" / n
        if f.exists():
            out.append(("target", n, f))
    for f in sorted((w / "projects").glob("*/_project/*.md")):
        out.append(("project", f"{f.parts[-3]}/{f.name}", f))
    for j in sorted((w / "projects").glob("*/jobs/*")):
        if not j.is_dir():
            continue
        for rel in ("knowledge/lessons-learned.md", "knowledge/environment-facts.md", "knowledge/glossary.md", "status/OPEN_DECISIONS.md",
                    "status/BUSINESS_RULES.md", "status/GAP_ANALYSIS.md"):
            f = j / rel
            if f.exists():
                out.append(("job", f"{j.name}/{rel}", f))
    return out


def rd(p: Path) -> str:
    try:
        return p.read_text(encoding="utf-8", errors="replace")
    except Exception:
        return ""


# ---------------------------------------------------------------- บทเรียน
def lesson_rows(text: str, src: str) -> list[dict]:
    """แถวตารางที่ช่องแรกเป็น L# / LT# / E# · section = หัวข้อ ## ที่อยู่ · ใหม่ = อยู่ใต้ NEW_SECTION หรือไฟล์ของทีม"""
    out, sec, head = [], "", []
    for i, line in enumerate(text.splitlines(), 1):
        if line.startswith("#"):
            sec = line.strip("# ").strip()
            continue
        if not line.strip().startswith("|"):
            continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if cells and cells[0] == "#":
            head = cells
            continue
        if cells and ID_RX.match(cells[0].replace("**", "")):
            row = {"id": cells[0].replace("**", ""), "cells": cells, "head": head, "section": sec, "line": i, "src": src, "text": " ".join(cells[1:])}
            for k, name in (("evidence", "หลักฐาน"), ("tag", "หมวด")):
                idx = next((n for n, h in enumerate(head) if name in h), None)
                row[k] = cells[idx] if idx is not None and idx < len(cells) else ""
            out.append(row)
    return out


def all_lessons(w: Path, job: Path | None = None) -> list[dict]:
    rows = []
    team = kit_knowledge(w) / "lessons-learned.md"
    for r in lesson_rows(rd(team), "ทีม (kit/knowledge)"):
        r["layer"] = "kit"
        rows.append(r)
    for f in sorted((w / "projects").glob("*/jobs/*/knowledge/lessons-learned.md")):
        jn = f.parts[-3]
        mine = job is not None and f.resolve() == (job / "knowledge/lessons-learned.md").resolve()
        for r in lesson_rows(rd(f), jn):
            if not mine and NEW_SECTION.strip("# ").split(" (")[0] not in r["section"]:
                continue                                            # งานอื่น: เฉพาะบทเรียนใหม่ของงานนั้น (ของ kit ซ้ำกันทุกงาน)
            r["layer"] = "job" if mine else "other-job"
            rows.append(r)
    return rows


def relevant(rows: list[dict], step: str) -> list[dict]:
    name, kws = STEPS.get(step, ("", []))
    out = []
    for r in rows:
        t = (r["tag"] + " " + r["text"]).lower()
        score = (5 if re.search(rf"\b{step}\b", r["tag"]) else 0) + sum(1 for k in kws if k in t)
        if score:
            out.append((score, r))
    order = {"job": 0, "kit": 1, "other-job": 2}
    out.sort(key=lambda x: (-x[0], order.get(x[1]["layer"], 9)))
    return [r for _, r in out]


def cmd_step(step: str, limit: int):
    w = ws_root()
    job = HERE if (HERE / "knowledge").exists() and w and HERE != w else None
    rows = relevant(all_lessons(w, job), step) if w else []
    name = STEPS.get(step, ("?", []))[0]
    print(f"📚 Wiki · ก่อนเริ่มขั้น {step} {name} — บทเรียนที่เกี่ยวข้อง {len(rows)} ข้อ (แสดง {min(len(rows), limit)})")
    for r in rows[:limit]:
        where = {"kit": "ทีม", "job": "งานนี้", "other-job": f"งาน {r['src']}"}.get(r["layer"], r["layer"])
        print(f"  {r['id']:<6} [{where}] {r['text'][:150]}")
    if w and job:
        dec = []
        for f in sorted((w / "projects").glob("*/_project/DECISIONS.md")):
            if job.resolve().is_relative_to(f.parents[1].resolve()):
                dec = [l for l in rd(f).splitlines() if l.startswith("| ") and not l.startswith("| #") and not l.startswith("|---")]
        if dec:
            print(f"  + การตัดสินระดับ project {len(dec)} ข้อ (projects/<P>/_project/DECISIONS.md)")
    print("  → เสนอแนวทางในขั้นนี้ต้องเขียน \"อ้างอิง: L# …\" (หรือ \"อ้างอิง: ไม่มีบทเรียนที่เกี่ยวข้อง\") · ค้นเพิ่ม: --search <คำ>")


def cmd_search(term: str, layer: str | None, remote: bool):
    w = ws_root()
    if not w:
        raise SystemExit("[ERROR] ไม่พบ workspace")
    rx = re.compile(re.escape(term), re.I)
    hits = {}
    for lay, name, f in sources(w):
        if layer and lay != layer:
            continue
        for i, line in enumerate(rd(f).splitlines(), 1):
            if rx.search(line):
                cells = [c.strip() for c in line.strip().strip("|").split("|")] if line.strip().startswith("|") else []
                tag = cells[0] if cells and ID_RX.match(cells[0].replace("**", "")) else ""
                hits.setdefault(lay, []).append(f"{name}:{i}  {(tag + ' ') if tag else ''}{' '.join(line.split())[:160]}")
    if remote and (w / ".git").exists():
        try:
            refs = subprocess.run(["git", "for-each-ref", "--format=%(refname:short)", "refs/remotes/origin/job/"], cwd=str(w), capture_output=True, text=True).stdout.split()
            for ref in refs:
                r = subprocess.run(["git", "grep", "-n", "-i", "-F", term, ref, "--", "projects/*/jobs/*/knowledge/*.md", "projects/*/_project/*.md"],
                                   cwd=str(w), capture_output=True, text=True)
                for l in r.stdout.splitlines()[:40]:
                    hits.setdefault("remote", []).append(" ".join(l.split())[:200])
        except Exception:
            pass
    total = sum(len(v) for v in hits.values())
    print(f"🔎 Wiki · ค้น \"{term}\" — พบ {total} บรรทัด" + ("" if remote else " (เพิ่ม --remote = ค้นใน branch งานของคนอื่นที่ fetch แล้ว)"))
    names = {"kit": "1 · kit (ทุกงาน)", "target": "2 · ระบบปลายทาง", "project": "3 · project", "job": "4 · งาน", "remote": "branch งานที่ยังไม่ merge"}
    for lay in ("kit", "target", "project", "job", "remote"):
        if hits.get(lay):
            print(f"\n  ── {names[lay]} ({len(hits[lay])})")
            for h in hits[lay][:30]:
                print(f"    {h}")
            if len(hits[lay]) > 30:
                print(f"    … อีก {len(hits[lay]) - 30} บรรทัด")


# ---------------------------------------------------------------- ตรวจ
def _git_show(w: Path, ref: str, rel: str) -> str:
    try:
        r = subprocess.run(["git", "show", f"{ref}:{rel}"], cwd=str(w), capture_output=True, text=True, encoding="utf-8", errors="replace")
        return r.stdout if r.returncode == 0 else ""
    except Exception:
        return ""


def check(w: Path, base: str = "HEAD") -> tuple[list[str], list[str]]:
    """คืน (errors, warns) — ใช้โดย workspace.py check และ CI"""
    errs, warns = [], []
    files = [kit_knowledge(w) / "lessons-learned.md"] + sorted((w / "projects").glob("*/jobs/*/knowledge/lessons-learned.md"))
    for f in files:
        if not f.exists():
            continue
        rel = f.relative_to(w).as_posix()
        team = f.parent == kit_knowledge(w)
        rows = lesson_rows(rd(f), rel)
        for r in rows:
            new = team or NEW_SECTION.strip("# ").split(" (")[0] in r["section"]
            if not new:
                continue
            ev = r["evidence"].strip(" -—")
            if not ev:
                errs.append(f"{rel}:{r['line']} {r['id']} ไม่มีหลักฐาน (ช่อง หลักฐาน ว่าง) — ใส่ไฟล์ผล / log / ข้อความ SA ที่ยืนยัน")
            if not r["tag"].strip(" -—"):
                warns.append(f"{rel}:{r['line']} {r['id']} ไม่มีหมวด / ขั้น — ใส่เช่น \"03 · performance\" (ใช้ดึงบทเรียนตามขั้น)")
        for i, line in enumerate(rd(f).splitlines(), 1):
            if SECRET.search(line) and not SECRET_OK.search(line):
                errs.append(f"{rel}:{i} อาจมีรหัสผ่าน / connection string ในบทเรียน — ห้ามใส่ข้อมูลลับใน Wiki")
        if (w / ".git").exists():                                   # ไม่ลบประวัติ: เลข L# ที่เคยมีต้องยังอยู่
            old = {r["id"] for r in lesson_rows(_git_show(w, base, rel), rel)}
            now = {r["id"] for r in rows}
            gone = sorted(old - now, key=lambda x: (len(x), x))
            if gone:
                errs.append(f"{rel}: บทเรียนหายไปเทียบกับ {base}: {', '.join(gone[:10])} — ห้ามลบประวัติ (แก้ข้อเดิมพร้อมหมายเหตุวันที่แทน)")
    if (w / ".git").exists():                                       # คำแนะนำที่เพิ่มใหม่ (เทียบ base) ต้องอ้าง L#
        for f in sorted((w / "projects").glob("*/jobs/*/status/OPEN_DECISIONS.md")):
            rel = f.relative_to(w).as_posix()
            try:
                d = subprocess.run(["git", "diff", "-U0", base, "--", rel], cwd=str(w), capture_output=True, text=True, encoding="utf-8", errors="replace").stdout
            except Exception:
                d = ""
            if not _git_show(w, base, rel):                         # ไฟล์ใหม่ทั้งไฟล์ (คำถามตั้งต้นจาก kit) — ไม่นับ
                continue
            added = [l[1:] for l in d.splitlines() if l.startswith("+") and not l.startswith("+++")]
            bad = [l for l in added if "[แนะนำ]" in l and not re.search(r"อ้างอิง|L-?T?\d+|E\d+", l)]
            if bad:
                warns.append(f"{rel}: คำแนะนำที่เพิ่มใหม่ {len(bad)} ข้อไม่อ้างบทเรียน (เช่น \"{bad[0].strip()[:60]}\") — เขียน \"อ้างอิง: L# …\" หรือ \"อ้างอิง: ไม่มีบทเรียนที่เกี่ยวข้อง\"")
    gk = kit_knowledge(w) / "glossary-kit.md"
    if not gk.exists():
        warns.append("ไม่มี kit/knowledge/glossary-kit.md — รัน workspace.py sync-kit --all หรือ setup -Mode Workspace เพื่อเติม")
    return errs, warns


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--step", choices=sorted(STEPS))
    ap.add_argument("--limit", type=int, default=12)
    ap.add_argument("--search")
    ap.add_argument("--layer", choices=["kit", "target", "project", "job"])
    ap.add_argument("--remote", action="store_true")
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--base", default="HEAD")
    a = ap.parse_args()
    if a.step:
        cmd_step(a.step, a.limit)
    elif a.search:
        cmd_search(a.search, a.layer, a.remote)
    elif a.check:
        w = ws_root()
        if not w:
            raise SystemExit("[ERROR] ไม่พบ workspace")
        errs, warns = check(w, a.base)
        for e in errs:
            print(f"  ❌ {e}")
        for x in warns:
            print(f"  ⚠️  {x}")
        print(f"Wiki check: ERROR {len(errs)} · WARN {len(warns)}")
        sys.exit(1 if errs else 0)
    else:
        ap.print_help()


if __name__ == "__main__":
    main()
