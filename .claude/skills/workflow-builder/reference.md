# Workflow harness — JS API reference

The API for saved dynamic workflows (`.claude/workflows/*.js`). Provenance: verified against live harness RUNS (June 2026). The harness is a research-preview-adjacent surface — re-verify against a live run if a field misbehaves, and update this page.

## File anatomy

```js
export const meta = {
  name: 'find-flaky-tests',            // MUST match filename <name>.js; becomes the invocable skill name
  description: 'One line — shown in the permission dialog and skill list',
  whenToUse: 'Optional — shown in the workflow/skill list; write it like a skill description',
  phases: [                            // optional; one entry per phase() call, titles matched EXACTLY
    { title: 'Scan', detail: 'grep test logs' },
    { title: 'Fix', detail: 'one agent per flaky test', model: 'haiku' },  // model = display hint
  ],
}
// body runs in an async context — top-level await is fine. Plain JS, NOT TypeScript.
phase('Scan')
const found = await agent('…', { schema: FINDINGS })
// …
return { found }                       // the run's result value
```

**meta must be a PURE LITERAL** — no variables, calls, spreads, or template strings.

## Primitives

- `agent(prompt, opts?) → Promise<any>` — spawn one sub-agent. Returns its final text, or the validated object when `opts.schema` (JSON Schema) is set — the sub-agent is forced through a StructuredOutput tool, retries on mismatch. Returns `null` if skipped/dead — **always `.filter(Boolean)`** collections of agent results.
  - `opts`: `label` (display), `phase` (progress group — use INSIDE pipeline/parallel stages to avoid races on global phase state), `schema`, `model` ('haiku'|'sonnet'|'opus' — house default: Haiku for mechanical work, Sonnet for judgment; inheriting the session model needs an explicit reason), `isolation: 'worktree'` (only when agents mutate files in parallel — expensive), `agentType` (custom subagent type, e.g. 'Explore'; composes with schema).
- `pipeline(items, ...stages) → Promise<any[]>` — each item flows through all stages independently, NO barrier between stages. **The default for multi-stage work.** Stage callbacks receive `(prevResult, originalItem, index)`. A throwing stage drops that item to `null`.
- `parallel(thunks) → Promise<any[]>` — concurrent with a BARRIER: awaits all before returning. Thunk errors resolve to `null` (never rejects). Use ONLY when stage N needs cross-item context from ALL of stage N−1 (dedupe across the full set, early-exit on zero, "compare with the other findings").
- `phase(title)` — start a progress group; subsequent `agent()` calls group under it.
- `log(message)` — narrator line to the user. Log dropped scope (caps, sampling) — silent truncation reads as full coverage.
- `args` — the value passed at invocation, verbatim. Parameterize scope ("only these files", a question, a config object). Arrays/objects arrive as real JSON values.
- `budget` — `{ total, spent(), remaining() }`, the session token target. Guard loops: `while (budget.total && budget.remaining() > 50_000) { … }` — without the `budget.total` guard, remaining() is Infinity and the loop runs to the agent cap.
- `workflow(nameOrRef, args?)` — run another saved workflow inline as a child (one nesting level only; shares caps/budget).

## Hard rules

- `Date.now()`, `Math.random()`, argless `new Date()` **throw** (they'd break resume). Timestamps come in via `args`; stamp results after the run.
- No filesystem/Node APIs in the script body itself — agents do the file work.
- Caps: ~10-16 concurrent agents (excess queue), 1000 agents per run lifetime, 4096 items per pipeline/parallel call.
- Sub-agents inherit NO conversation history — the prompt carries everything.

## House patterns

**Schema'd worker (default):**
```js
const FINDINGS = { type: 'object', properties: { findings: { type: 'array', items: { type: 'object',
  properties: { title: {type:'string'}, file: {type:'string'}, severity: {type:'string'} },
  required: ['title','file','severity'] } } }, required: ['findings'] }
```

**Pipeline with per-item verify (no barrier):**
```js
const results = await pipeline(DIMENSIONS,
  d => agent(d.prompt, { label: `find:${d.key}`, phase: 'Find', schema: FINDINGS }),
  r => parallel(r.findings.map(f => () =>
    agent(`Adversarially verify: ${f.title}. Try to REFUTE it.`, { phase: 'Verify', schema: VERDICT })
      .then(v => ({ ...f, verdict: v })))))
const confirmed = results.flat().filter(Boolean).filter(f => f.verdict?.isReal)
```

**Loop-until-dry (unknown-size discovery):** keep spawning finders until K consecutive rounds add nothing new. **Dedupe vs ALL seen, never vs confirmed** — else judge-rejected findings reappear forever.
```js
const seen = new Set(); let dry = 0
while (dry < 2) {
  const fresh = (await parallel(FINDERS.map(f => () => agent(f.prompt, {schema: FINDINGS}))))
    .filter(Boolean).flatMap(r => r.findings).filter(b => !seen.has(key(b)))
  if (!fresh.length) { dry++; continue }
  dry = 0; fresh.forEach(b => seen.add(key(b)))
  // …verify fresh, accumulate confirmed
}
```

**Adversarial verify:** N independent skeptics prompted to REFUTE; kill on majority refute. **Diverse-lens variant:** distinct lenses (correctness/security/repro) instead of identical refuters when a finding can fail in more than one way.

**Judge panel:** N attempts from different angles → parallel judges score → synthesize from the winner, graft runners-up.

**Completeness critic:** final agent asks "what's missing — modality not run, claim unverified?" — its findings become the next round.

## Cost doctrine

One unbounded community workflow famously burned half a $200/mo subscription in a single run. Every saved workflow ships with: explicit caps (items + rounds), the smallest worker model that survives the task, `args`-narrowable scope, and a Cost reality note in its chat brief. Build = cheap; fire = expensive; never fire on the user's behalf.
