# teams/

**Agent teams** are 2–5 specialized Claudes that share one task list, talk to each other
peer-to-peer, and work in parallel — a small crew instead of a single assistant.

None ship pre-built (a team is shaped around a specific job). Design your own with
`/agents-team-builder`: it runs a discovery interview and saves a rerunnable template here as
`<name>.md`, plus a paste-ready invocation prompt.

**Heads up:** teams need the experimental flag `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` and a
fresh Claude Code session to launch. The builder walks you through it.

When to reach for a team instead of one agent: the work breaks into parts that genuinely
benefit from specialists working at the same time (e.g. a researcher + a writer + a
reviewer). For most things, a single skill or agent is simpler — start there.
