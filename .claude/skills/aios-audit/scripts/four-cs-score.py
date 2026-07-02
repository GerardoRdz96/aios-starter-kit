#!/usr/bin/env python3
"""Deterministic detection + scoring for /aios-audit (the Four-Cs audit).

The skill RUNS this script; the model never recomputes the arithmetic.
Two-pass contract:

  Pass 1:  python3 four-cs-score.py
           -> mechanical counts + partial scores + a `needs_judgment` list
              of flags the model must decide by reading targeted files.

  Pass 2:  python3 four-cs-score.py --tier1-domains 3 --identity-captured 1 \
               --connected-tools "gmail,stripe" --stale-connections 0 \
               --connections-doc 2 --write-path 1
           -> final deterministic scores, total, stage, and leverage-ranked gaps.

Only the flags are model judgment; every count, point, rounding, floor, cap,
and multiplier below is fixed code so week-over-week scores are comparable.
"""

import argparse
import json
import re
import sys
import time
from pathlib import Path

BOX_SKILLS = {
    "agent-builder", "agents-team-builder", "aios-audit", "grill-me",
    "hooks-builder", "level-up", "multi-brain", "onboard", "plugin-builder",
    "routines-builder", "session-handoff", "skill-builder", "workflow-builder",
}
BOX_AGENTS = {"scribe", "warden"}
RITUAL_RE = re.compile(r"^(morning-|daily-|weekly-|monthly-|standup)")
DAY = 86400


def word_count(p: Path) -> int:
    try:
        return len(p.read_text(encoding="utf-8", errors="ignore").split())
    except OSError:
        return 0


def entry_count(p: Path) -> int:
    """Rough entry count: bullet or heading lines after the title."""
    try:
        lines = p.read_text(encoding="utf-8", errors="ignore").splitlines()[1:]
    except OSError:
        return 0
    return sum(1 for l in lines if re.match(r"^\s*([-*]|#{2,})\s+\S", l))


def has_frontmatter_agent(p: Path) -> bool:
    try:
        text = p.read_text(encoding="utf-8", errors="ignore")
    except OSError:
        return False
    m = re.match(r"^---\n(.*?)\n---", text, re.DOTALL)
    return bool(m and "name:" in m.group(1) and "description:" in m.group(1))


def recent(p: Path, days: int = 30) -> bool:
    try:
        return (time.time() - p.stat().st_mtime) < days * DAY
    except OSError:
        return False


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--root", default=".", help="project root (default: cwd)")
    ap.add_argument("--tier1-domains", type=int, default=None,
                    help="JUDGED: how many of the 7 tier-1 domains are reachable (0-7)")
    ap.add_argument("--identity-captured", type=int, choices=[0, 1], default=None,
                    help="JUDGED: identity/role/voice captured in CLAUDE.md or rules (0/1)")
    ap.add_argument("--connected-tools", default=None,
                    help="JUDGED: comma-separated reachable tools, '' if none (guides checked as references/{tool}-api.md)")
    ap.add_argument("--stale-connections", type=int, default=None,
                    help="JUDGED: connections in needs-auth/expired state or script not run in 30 days")
    ap.add_argument("--connections-doc", type=int, choices=[0, 1, 2, 3], default=None,
                    help="JUDGED: connections.md coverage — 0 missing, 1 sparse, 2 most, 3 all")
    ap.add_argument("--write-path", type=int, choices=[0, 1, 2], default=None,
                    help="JUDGED: +1 intentional scoped write path a cadence needs, +1 least-privilege keys")
    args = ap.parse_args()

    root = Path(args.root).resolve()
    needs = []

    # ---------- mechanical detection ----------
    claude_md = root / "CLAUDE.md"
    cm_words = word_count(claude_md)

    mem_entries = 0
    mem_md = root / "MEMORY.md"
    if mem_md.exists():
        mem_entries = sum(1 for l in mem_md.read_text(errors="ignore").splitlines()
                          if re.match(r"^\s*[-*]\s+\S", l))
    mem_dir = root / "memory"
    if mem_dir.is_dir():
        mem_entries = max(mem_entries, len(list(mem_dir.glob("*.md"))))

    ref_files = 0
    for d in ("references", "docs", "sops"):
        if (root / d).is_dir():
            ref_files += len(list((root / d).rglob("*.md")))

    dec_entries = 0
    for cand in (root / "decisions" / "log.md", root / "decisions.md"):
        if cand.exists():
            dec_entries = max(dec_entries, entry_count(cand))

    skill_dirs = sorted(p.parent.name for p in (root / ".claude" / "skills").glob("*/SKILL.md"))
    user_skills = [s for s in skill_dirs if s not in BOX_SKILLS]
    agent_files = [p for p in (root / ".claude" / "agents").glob("*.md")
                   if p.name != "README.md" and has_frontmatter_agent(p)]
    agents = sorted(p.stem for p in agent_files)
    user_agents = [a for a in agents if a not in BOX_AGENTS]

    hooks_configured = False
    for cand in (root / ".claude" / "settings.json", root / ".claude" / "settings.local.json"):
        try:
            if cand.exists() and '"hooks"' in cand.read_text(errors="ignore"):
                hooks_configured = True
        except OSError:
            pass
    ritual_skills = [s for s in skill_dirs if RITUAL_RE.match(s)]

    recent_skill_edit = any(recent(p) for p in (root / ".claude" / "skills").rglob("*.md"))
    recent_decision = recent(root / "decisions" / "log.md")

    template_files = 0
    for d in ("templates", ".claude/templates"):
        if (root / d).is_dir():
            template_files += sum(1 for p in (root / d).rglob("*") if p.is_file())

    # ---------- scoring (fixed arithmetic) ----------
    ctx = {
        "manual_substantive": 5 if cm_words > 200 else 0,
        "memory_entries": 5 if mem_entries > 3 else 0,
        "reference_docs": 5 if ref_files >= 1 else 0,
        "decisions_captured": 5 if dec_entries >= 1 else 0,
    }
    if args.identity_captured is None:
        needs.append("--identity-captured")
        ctx["identity_voice"] = 0
    else:
        ctx["identity_voice"] = 5 * args.identity_captured

    con = {}
    if args.tier1_domains is None:
        needs.append("--tier1-domains")
        t1 = 0
    else:
        t1 = max(0, min(7, args.tier1_domains))
    con["tier1_coverage"] = min(10.0, round(t1 * 1.4 * 2) / 2)

    if args.connected_tools is None:
        needs.append("--connected-tools")
        tools, missing_guides = [], 0
        con["reference_guides"] = 0
    else:
        tools = [t.strip() for t in args.connected_tools.split(",") if t.strip()]
        missing_guides = sum(1 for t in tools if not (root / "references" / f"{t}-api.md").exists())
        con["reference_guides"] = 0 if not tools else max(0, 5 - missing_guides)

    if args.stale_connections is None:
        needs.append("--stale-connections")
        con["auth_freshness"] = 0
    else:
        con["auth_freshness"] = 0 if not tools else max(0, 5 - max(0, args.stale_connections))

    if args.connections_doc is None:
        needs.append("--connections-doc")
        con["documented"] = 0
    else:
        con["documented"] = args.connections_doc

    if args.write_path is None:
        needs.append("--write-path")
        con["write_path"] = 0
    else:
        con["write_path"] = args.write_path

    cap = {
        "three_plus_skills": 10 if len(skill_dirs) >= 3 else 0,
        "user_built_skill": 10 if user_skills else 0,
        "user_built_agent": 5 if user_agents else 0,
    }
    cad = {
        "recurring_trigger": 10 if (hooks_configured or ritual_skills) else 0,
        "recent_activity": 10 if (recent_skill_edit or recent_decision) else 0,
        "templates": 5 if template_files >= 1 else 0,
    }

    subtotals = {
        "context": sum(ctx.values()),
        "connections": round(sum(con.values()), 1),
        "capabilities": sum(cap.values()),
        "cadence": sum(cad.values()),
    }
    total = round(sum(subtotals.values()), 1)
    stage = ("Stage 0: Foundation" if total < 40 else
             "Stage 1: Built" if total < 70 else
             "Stage 2: Compounding" if total < 90 else
             "Stage 3: Autonomous")

    # ---------- leverage-ranked gaps (fixed multipliers) ----------
    maxima = {
        ("context", "manual_substantive"): 5, ("context", "identity_voice"): 5,
        ("context", "memory_entries"): 5, ("context", "reference_docs"): 5,
        ("context", "decisions_captured"): 5,
        ("connections", "tier1_coverage"): 10, ("connections", "reference_guides"): 5,
        ("connections", "auth_freshness"): 5, ("connections", "documented"): 3,
        ("connections", "write_path"): 2,
        ("capabilities", "three_plus_skills"): 10, ("capabilities", "user_built_skill"): 10,
        ("capabilities", "user_built_agent"): 5,
        ("cadence", "recurring_trigger"): 10, ("cadence", "recent_activity"): 10,
        ("cadence", "templates"): 5,
    }
    scores = {"context": ctx, "connections": con, "capabilities": cap, "cadence": cad}

    def multiplier(c: str, crit: str) -> float:
        if (c, crit) == ("connections", "tier1_coverage"):
            return 4.0 if t1 == 0 else (3.0 if t1 <= 2 else 1.0)
        if (c, crit) == ("context", "manual_substantive"):
            return 3.0
        if (c, crit) == ("capabilities", "three_plus_skills") and not skill_dirs:
            return 2.0
        if (c, crit) == ("cadence", "recurring_trigger"):
            return 2.0
        if (c, crit) == ("connections", "write_path") and con["write_path"] == 0:
            return 2.0  # approximation: model may waive if no cadence needs a write
        if (c, crit) == ("connections", "reference_guides") and tools and con["reference_guides"] == 0:
            return 1.5
        if (c, crit) == ("context", "decisions_captured"):
            return 1.5
        return 1.0

    gaps = []
    for (c, crit), mx in maxima.items():
        lost = round(mx - scores[c][crit], 1)
        if lost > 0:
            m = multiplier(c, crit)
            gaps.append({"c": c, "criterion": crit, "lost": lost,
                         "multiplier": m, "leverage": round(lost * m, 1)})
    gaps.sort(key=lambda g: -g["leverage"])

    out = {
        "date": time.strftime("%Y-%m-%d"),
        "root": str(root),
        "needs_judgment": needs,
        "mechanical": {
            "claude_md_words": cm_words,
            "memory_entries": mem_entries,
            "reference_doc_files": ref_files,
            "decision_entries": dec_entries,
            "skills": skill_dirs,
            "user_built_skills": user_skills,
            "agents": agents,
            "user_built_agents": user_agents,
            "hooks_configured": hooks_configured,
            "ritual_skills": ritual_skills,
            "recent_activity_30d": recent_skill_edit or recent_decision,
            "template_files": template_files,
            "missing_reference_guides": missing_guides,
        },
        "scores": scores,
        "subtotals": subtotals,
        "total": total,
        "stage": stage,
        "gaps_by_leverage": gaps[:6],
        "final": not needs,
    }
    json.dump(out, sys.stdout, indent=2)
    print()


if __name__ == "__main__":
    main()
