#!/usr/bin/env python3
"""entity-scoreboard.py — your AIOS's objective self-measurement snapshot (charter §3).

Aggregates capability counts + wiki size + latest audit scores into one append-only
JSONL row at references/audits/scoreboard.jsonl. Trend > snapshot: regressions between
rows are what matter.

Usage:
  python3 scripts/entity-scoreboard.py            # upsert this week's row + print it
  python3 scripts/entity-scoreboard.py --dry-run  # print without writing
  python3 scripts/entity-scoreboard.py --trend    # print last 8 rows as a table
  python3 scripts/entity-scoreboard.py --gate     # fail if a should-only-grow metric dropped

Re-running on the same day upserts (replaces today's row) instead of appending a
duplicate, so the trend window stays one-row-per-day.

Run weekly (alongside /audit, or from a routine once you arm one). Scores it can't
compute locally (the Four-Cs audit grade) are read from the newest
references/audits/four-cs-*.md if present. --gate makes the charter's "numbers gate
evolution" rule real — the verification-loop doctrine lives in references/agent-loops.md.

Charter: references/autonomous-entity-charter.md
"""
import argparse, datetime, json, pathlib, re, subprocess, sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = ROOT / "references" / "audits" / "scoreboard.jsonl"
SKIP = {"README.md", "index.md"}  # housekeeping files, not capabilities


def count(globpat, base=ROOT):
    return len([p for p in base.glob(globpat) if p.name not in SKIP])


# Sub-trees under references/ that are already tallied by other metrics, so
# counting their .md files here would double them: provenance/ → provenance_records,
# audits/ → the scoreboard + four-cs audit files themselves.
WIKI_EXCLUDE_DIRS = {"provenance", "audits"}


def count_wiki_pages():
    """De-duped recursive count of wiki pages (references/**/*.md).

    One recursive glob — not references/*.md + references/**/*.md, which
    double-counts every top-level page (** already includes the top level).
    A set de-dupes, SKIP drops housekeeping files, and WIKI_EXCLUDE_DIRS drops
    sub-trees counted by other metrics. Verification doctrine: references/agent-loops.md.
    """
    pages = set()
    for p in ROOT.glob("references/**/*.md"):
        if p.name in SKIP:
            continue
        rel = p.relative_to(ROOT / "references")
        # rel.parts[0] is the immediate subdir (or the filename, for a top-level page)
        if len(rel.parts) > 1 and rel.parts[0] in WIKI_EXCLUDE_DIRS:
            continue
        pages.add(p)
    return len(pages)


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
            "wiki_pages": count_wiki_pages(),
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
    ap.add_argument("--gate", action="store_true",
                    help="diff the last two rows; exit non-zero if a should-only-grow metric dropped")
    a = ap.parse_args()

    if a.gate:
        # Make "numbers gate evolution" (charter §3) real: compare the last two
        # rows and flag any STRUCTURAL count that shrank. capabilities.* and
        # knowledge.* should only grow; commits_7d / pending_open fluctuate by
        # design, so they're not gated. Doctrine: references/agent-loops.md.
        if not OUT.exists():
            sys.exit("no scoreboard yet — run once first")
        rows = [json.loads(l) for l in OUT.read_text().splitlines() if l.strip()]
        if len(rows) < 2:
            print("need ≥2 rows to gate — nothing to compare yet")
            return
        prev, cur = rows[-2], rows[-1]
        regressions = []
        for section in ("capabilities", "knowledge"):
            for metric, now in cur.get(section, {}).items():
                before = prev.get(section, {}).get(metric, 0)
                if isinstance(now, (int, float)) and now < before:
                    regressions.append(f"{section}.{metric}: {before} → {now}")
        if regressions:
            print(f"GATE FAIL ({prev['date']} → {cur['date']}) — these should only grow:")
            for r in regressions:
                print("  ↓ " + r)
            print("\nverify-or-revert: confirm this was an intentional prune (then it's fine)\n"
                  "or revert the regression. See references/agent-loops.md.")
            sys.exit(1)
        print(f"GATE OK ({prev['date']} → {cur['date']}) — no should-only-grow metric dropped.")
        return

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
        # Same-date upsert: re-running the weekly job shouldn't write a second
        # row for today, which would skew the trend window (and the --gate diff).
        # Drop any existing row dated today, then append the fresh one.
        existing = [l for l in OUT.read_text().splitlines() if l.strip()] if OUT.exists() else []
        kept = [l for l in existing if json.loads(l).get("date") != row["date"]]
        replaced = len(kept) != len(existing)
        kept.append(json.dumps(row))
        OUT.write_text("\n".join(kept) + "\n")
        verb = "upserted" if replaced else "appended"
        print(f"\n{verb} → {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
