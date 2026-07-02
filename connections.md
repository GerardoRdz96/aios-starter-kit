# Connections

The registry of every system your AIOS can reach — or that you want it to reach later.
`/onboard` populates this from your intake (Q4–Q7); `/aios-audit` scores it as the **Connections**
C; you keep it current as you wire things up.

**Connecting principle: CLI > API > MCP.** Prefer a command-line tool the AI can drive
directly; fall back to a small script against an API; reach for an MCP server last.

These seven rows map to the life-areas an AIOS usually needs to see. Fill in the tools you
actually use; leave the rest blank.

| # | Domain | Your tool(s) | Mechanism | Auth | Last checked |
|---|--------|--------------|-----------|------|--------------|
| 1 | Outcomes / where the value of your work lands | _e.g. a dashboard, a grade portal, revenue_ | not yet connected | — | — |
| 2 | Communication — email & chat | _e.g. Gmail, Slack_ | not yet connected | — | — |
| 3 | Calendar | _e.g. Google Calendar_ | not yet connected | — | — |
| 4 | External / social / outside world | _e.g. LinkedIn, X_ | not yet connected | — | — |
| 5 | Tasks / to-do tracker | _e.g. Todoist, Jira_ | not yet connected | — | — |
| 6 | Meetings / recordings / notes | _e.g. a notetaker, a notes app_ | not yet connected | — | — |
| 7 | Docs / files | _e.g. Google Drive, a folder_ | not yet connected | — | — |

## How to wire one up (Day 2+)

1. Pick a row. Check **CLI first** — is there a command-line tool the AI can run? Install it.
2. No CLI? Write a small script in `scripts/` against the tool's API, and save a one-page
   `references/<tool>-api.md` so Sage remembers how it works.
3. Only then consider an MCP server.
4. Update this row's **Mechanism / Auth / Last checked** when it's live.

> Never hard-code secrets here. Keep API keys in a gitignored `.env` file.
