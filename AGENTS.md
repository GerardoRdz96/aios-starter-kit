# Agent entry point

This AIOS is **tool-agnostic**: it's folders and markdown, so any agent that can read and write files can drive it — Claude Code, Codex CLI, Gemini CLI, Cursor, or whatever comes next.

**Read `CLAUDE.md` first.** It is the operating manual for this repo regardless of which harness you are: who the user is, where things live, the knowledge-wiki protocol, and the working rules. Treat every instruction in it as applying to you, substituting your own tool names where needed (e.g. your platform's equivalent of skills/commands).

Notes for non-Claude harnesses:

- **Skills** live in `.claude/skills/*/SKILL.md`. If your platform doesn't load them natively, read the relevant SKILL.md and follow it as a procedure — they're written as plain instructions.
- **Agents** in `.claude/agents/*.md` are role prompts; run them as sub-tasks or separate sessions if your platform has no subagent primitive.
- The **wiki protocol** (`references/wiki-protocol.md`) and folder layout are pure files — they work identically everywhere.
