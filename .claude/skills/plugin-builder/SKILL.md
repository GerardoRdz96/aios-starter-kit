---
name: plugin-builder
description: Use when the user asks to build, package, bundle, optimize, or audit a Claude Code plugin or marketplace — a distributable bundle of skills + agents + commands + hooks installed via `/plugin`. Triggers — "build a plugin", "package this as a plugin", "bundle my skills", "make a marketplace", "turn these skills into something shareable", or `/plugin-builder`. The packaging + distribution sibling of `/skill-builder`, `/agent-builder`, `/agents-team-builder`, `/routines-builder`, `/hooks-builder`, `/workflow-builder`. Runs a decision gate and Discovery Interview before writing files.
argument-hint: [plugin name or what to package]
disable-model-invocation: true
---

## What This Skill Does

Guides creating, optimizing, and auditing Claude Code **plugins** and **marketplaces**. A plugin is a single installable package bundling any mix of commands, agents, skills, and hooks, distributed through a marketplace and installed with `claude plugin install`.

The six primitive builders each make *one loose capability* in `.claude/`. This one **bundles capabilities and makes them shippable** — to teammates, the public, or your own other machines. Build primitives with their builders first; package here.

### Plugin vs the primitive builders

| You want… | Use | Why |
|---|---|---|
| One reusable workflow/SOP here | **Skill** (`/skill-builder`) | Lives loose in `.claude/skills/` |
| One isolated-context delegate job | **Agent** (`/agent-builder`) | Lives loose in `.claude/agents/` |
| A small crew working in parallel | **Team** (`/agents-team-builder`) | Lives loose in `.claude/teams/` |
| Something unattended on a schedule | **Routine** (`/routines-builder`) | Scheduled, runs as you |
| An event-driven local trigger | **Hooks** (`/hooks-builder`) | Lives in `settings.json` hooks; bundleable into a plugin |
| Width fan-out to N parallel agents | **Workflow** (`/workflow-builder`) | Lives loose in `.claude/workflows/` |
| To **bundle + version + ship** any mix of the above | **Plugin** (this skill) | Distribution is the whole point |

## Mode 1: Build / Package a Plugin

### Step 0 — Decision Gate (FIRST, before any interview)

1. **Real distribution need?** Will this leave the project — a teammate, the public, another machine? **No → don't build a plugin.** A plugin you never distribute is just overhead.
2. **More than a single trivial primitive?** One tiny skill used only here doesn't need a package.
3. **Confidentiality gate (hard).** A plugin is built to leave the machine. If the bundle would contain employer-confidential content, client IP, or anything you're not free to publish → **stop.** Shipped plugins are personal- or public-data only.
4. **MCP check.** If the plugin wraps an external tool, prefer a CLI-backed skill/command over an MCP server (CLI > API > MCP — MCP burns far more tokens). Keep MCP only with a reason.

If 1–2 don't justify a plugin, recommend the right primitive builder and stop.

### Step 1 — Discovery Interview (one round at a time; skip rounds already answered)

1. **Purpose & name** — what it delivers, who installs it. Name: lowercase-hyphens; it becomes `plugin install <name>` and namespaces every component.
2. **The bundle** — which *existing* skills/agents/commands get packaged (copied in), which are *new*.
3. **Distribution** — local test only → this-repo-as-marketplace → standalone public repo. Starting version (default `0.1.0`).
4. **Manifest & guardrails** — author, license (MIT default for public), keywords; re-confirm the confidentiality gate; secrets come from env at runtime, never committed.
5. **Confirmation** — summarize the whole plan back; build only after a yes.

### Step 2 — Build

(`claude plugin new <name>` can scaffold the skeleton for you, then fill it in.)

Scaffold under `plugins/<name>/`:

```
plugins/<name>/
├── .claude-plugin/
│   ├── plugin.json          ← manifest (name, version, description, author, keywords)
│   └── marketplace.json     ← required to install via a marketplace; lives in the dir you run `marketplace add` against ("source": "./")
├── skills/<skill>/SKILL.md  ← components live at the plugin ROOT, not in .claude-plugin/
├── agents/<agent>.md
├── commands/<cmd>.md
└── README.md                ← what it does, install line, components, quick start
```

- **Components at the ROOT** — the #1 structural mistake is putting them inside `.claude-plugin/`.
- **No hardcoded paths** — use `${CLAUDE_PLUGIN_ROOT}` in every hook/script reference.
- Minimal manifest: `name`, `version`, `description`, `author`, `keywords`. Nothing unused.
- Minimal `marketplace.json` (one entry per plugin in the repo):

```json
{ "name": "<market>", "owner": { "name": "..." }, "plugins": [ { "name": "<plugin>", "source": "./", "description": "what the plugin does" } ] }
```

  `source` is the path to the plugin dir relative to the marketplace root — use `"./"` only when the plugin IS the repo root; otherwise point at it (e.g. `"./plugins/<name>"`).

### Step 3 — Validate (don't skip)

```bash
claude plugin validate ./plugins/<name>/.claude-plugin/plugin.json
claude plugin validate --strict ./plugins/<name>/.claude-plugin/plugin.json   # fail on warnings before shipping (use in CI)
claude plugin marketplace add ./plugins/<name> --scope local   # the dir holding .claude-plugin/marketplace.json (use "./" only if the plugin IS the repo root)
claude plugin install <name>@<marketplace> --scope local
claude plugin details <name>                       # inventory + token cost
# exercise each component, then tear down:
claude plugin uninstall <name> --scope local && claude plugin marketplace remove <marketplace>
```

Report exactly what ran and what passed. Don't claim it works without validate + a local install.

### Step 4 — Document & Register

Update `CLAUDE.md` (one line) the same session; note durable facts in the wiki; log the decision if it was one.

## Mode 2: Optimize / Mode 3: Audit

Read the plugin's `plugin.json` + tree first — never optimize what you haven't read. Checklist: components at the root (not in `.claude-plugin/`) · manifest minimal, semver matches the marketplace entry · `${CLAUDE_PLUGIN_ROOT}` everywhere (no absolute paths) · `claude plugin validate` passes on both manifests · no secrets committed · nothing confidential in a public bundle · README present. Show the diff and the *why* per change before applying. For a review of a plugin you just built, route to a different-lineage model (No-Self-Review Law in `multi-brain`).
