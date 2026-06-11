# references/provenance/ — provenance records

One record per self-created capability (Tier S/X of the [autonomous-entity charter](../autonomous-entity-charter.md)) and per community import. Filename: `<date>-<name>.md`. These records are what make autonomy auditable: when something misbehaves six weeks later, the record tells you where it came from, who reviewed it, and whether it was ever verified.

## Record template

```markdown
# Provenance: <capability name>

- **What:** <type + files created/installed>
- **Type/Tier:** <skill/agent/routine/hook/workflow/plugin/import> · Tier <P/S/X> per charter §2
- **Why:** <directive, backlog item, or need that triggered it>
- **Source:** <for imports: URL + license + install method. For self-built: the spec/interview>
- **Builder:** <which builder skill / session / loop produced it>
- **Reviewer verdict:** <different-lineage review result — No-Self-Review Law. "N/A + reason" allowed>
- **Validator verdict:** <static scan result: CLEAN / FLAG / REJECT, with anything flagged-then-cleared>
- **Test evidence:** <what was run, what happened. "pending first fire" allowed, with the planned occasion>
- **Armed-by:** <Tier X only: who armed it + date, or NOT ARMED>
- **Post-ship verification:** <charter §3.1 graduation evidence — filled in after it does its job once>
```

## The community-import discipline

Installing community skills/agents/plugins = letting someone else's instructions run inside your AIOS. Before ANY install:

1. **Static validation scan** of every file you're about to install. Look for: prompt-injection patterns ("ignore previous instructions", hidden imperatives), instructions that touch secrets/`.env`/credentials, network calls to unexpected hosts, `eval`/arbitrary-execution instructions, tool grants wider than the description claims, and descriptions that oversell their trigger scope.
2. **Verdict:** CLEAN (install), FLAG (install only after a human reads the flagged lines), REJECT (don't install; note why).
3. **Install only what you need** — skip the source repo's root README/config files meant for other setups.
4. **File the provenance record** (template above) with the verdict. For unmodified third-party imports, the validator scan stands in for the different-lineage review gate.
5. **Earmark a first fire** — the record stays "pending" until the capability demonstrably does its job once (charter graduation rule).
