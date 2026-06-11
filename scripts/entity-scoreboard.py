#!/usr/bin/env python3
"""entity-scoreboard.py — your AIOS's objective self-measurement snapshot (charter §3).

Aggregates capability counts + wiki size + latest audit scores into one append-only
JSONL row at references/audits/scoreboard.jsonl. Trend > snapshot: regressions between
rows are what matter.

Usage:
  python3 scripts/entity-scoreboard.py            # append this week's row + print it
  python3 scripts/entity-scoreboard.py --dry-run  # print without appending
  python3 scripts/entity-scoreboard.py --trend    # print last 8 rows as a table

Run weekly (alongside /audit, or from a routine once you arm one). Scores it can't
compute locally (the Four-Cs audit grade) are read from the newest
references/audits/four-cs-*.md if present.

Charter: references/autonomous-entity-charter.md
"""
import argparse, datetime, json, pathlib, re, subprocess, sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = ROOT / "references" / "audits" / "scoreboard.jsonl"
SKIP = {"README.md", "index.md"}  # housekeeping files, not capabilities


def count(globpat, base=ROOT):
    return len([p for p in base.glob(globpat) if p.name not in SKIP])


def git(*args):
    try:
        return subprocess.run(["git", "-C", str(ROOT), *args], capture_output=True,
                              text=True, timeout=20).stdout.strip()
    except Exception:
        return ""


def latest_fourcs_score():
    audits_dir = ROOT / "references" / "audits"
    if not audits_dir.exists():
        return None
    for f in sorted(audits_dir.glob("four-cs-*.md"), reverse=True):
        m = re.search(r"(?:overall|total)[^\d]*(\d+(?:\.\d+)?)\s*/\s*(\d+)", f.read_text(), re.I)
        if m:
            return {"score": float(m.group(1)), "of": float(m.group(2)), "file": f.name}
    return None


def heading_count(path):
    return path.read_text().count("\n## ") if path.exists() else 0


def snapshot():
    today = datetime.date.today().isoformat()
    row = {
        "date": today,
        "capabilities": {
            "skills": count(".claude/skills/*/SKILL.md"),
            "agents": count(".claude/agents/*.md"),
            "teams": count(".claude/teams/*.md"),
            "workflows": count(".claude/workflows/*.js"),
            "routines": count("routines/*.md"),
            "scripts": count("scripts/*.py") + count("scripts/*.sh"),
            "provenance_records": count("references/provenance/*.md"),
        },
        "knowledge": {
            "wiki_pages": count("references/*.md") + count("references/**/*.md"),
            "log_entries": heading_count(ROOT / "references" / "log.md"),
            "decisions": heading_count(ROOT / "decisions" / "log.md"),
        },
        "activity": {
            "commits_7d": len(git("log", "--oneline", "--since=7 days ago").splitlines()),
        },
        "audit": {"four_cs": latest_fourcs_score()},
        "pending_open": (ROOT / "pending.md").read_text().count("- [ ]")
        if (ROOT / "pending.md").exists() else 0,
    }
    return row


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--trend", action="store_true")
    a = ap.parse_args()

    if a.trend:
        if not OUT.exists():
            sys.exit("no scoreboard yet — run once first")
        rows = [json.loads(l) for l in OUT.read_text().splitlines() if l.strip()][-8:]
        for r in rows:
            c, k = r["capabilities"], r["knowledge"]
            print(f"{r['date']}  caps={sum(v for v in c.values())}  wiki={k['wiki_pages']}"
                  f"  commits7d={r['activity']['commits_7d']}  pending={r['pending_open']}")
        return

    row = snapshot()
    print(json.dumps(row, indent=2))
    if not a.dry_run:
        OUT.parent.mkdir(parents=True, exist_ok=True)
        with OUT.open("a") as f:
            f.write(json.dumps(row) + "\n")
        print(f"\nappended → {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
