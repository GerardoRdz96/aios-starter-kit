---
name: printing-press
description: Use when someone wants their AIOS to reach a tool it cannot reach yet — "connect my AIOS to X", "how do I wire up Gmail / Notion / Linear / my bank", "can it read my calendar", "I want it to post to LinkedIn", "add a connection", "is there an API for this". Finds the cheapest working way in, wires it, proves it with a real read, and registers it in connections.md. Never invents an integration that does not exist.
disable-model-invocation: true
---

## What this skill does

Turns "I wish my AIOS could touch X" into a working, registered connection.

The Connections layer is the one that turns a conversation into an action, and it is also
the layer most people stall on, because the honest answer to "how do I connect this?" is
usually "it depends" and nobody wants to research it. This skill does the research and
then does the wiring.

**It is also the layer where the risk lives.** More reach means more that can go wrong, so
this skill deliberately wires the smallest thing that works, read-only first, and proves it
before widening.

## The ladder: CLI > API > MCP

Walk it in order and stop at the first rung that works. This ordering is not a preference,
it is a cost and reliability ranking.

| Rung | Try when | Why it usually wins |
|---|---|---|
| **1. Official CLI** | The vendor ships a command line tool (`gh`, `stripe`, `supabase`, `az`, `gcloud`) | Auth is a solved path the vendor supports, output is scriptable, and your AIOS can run it directly. Usually the cheapest in tokens. |
| **2. Official hosted connector** | The vendor or your harness offers one | Sometimes safer than hand-rolled OAuth, because consent, scope and revocation are managed for you. |
| **3. HTTP API + a small wrapper script** | No CLI or connector, but there is a documented API | One thin script in `scripts/` becomes your CLI, and you choose exactly which calls it makes. |
| **4. MCP server** | None of the above, or the tool is genuinely conversational | Real capability, but it burns far more context per call, and it needs vetting (see below). |
| **5. No integration exists** | Nothing above is true | Say so. Suggest the manual bridge (export a file, forward an email) and stop. |

**This is a heuristic, not a law.** Check it against the actual tool, because an official CLI
can still authenticate as a broadly privileged human, demand an interactive browser, store
credentials in a plaintext file when no keychain exists, expire under cron or cloud
execution, or emit human-shaped output that breaks on the next release. When any of that is
true, a connector or a scoped API token is the better rung.

**Before adopting an MCP server**, check the publisher is official or audited, that a
legitimate upstream API sits underneath it (an MCP that "integrates" a service with no public
API may be wrapping scraping or authenticated browser automation), which tools it requests,
whether you can pin a version, and how you revoke it.

**Hold this order even when asked for the MCP directly.** "Is there an MCP for X" almost
always really means "how do I connect X", and a lower rung is usually better. Say why in one
line, then offer the MCP if they still want it.

## Execution

### Step 1: Name the job, not the tool

Ask what they actually want to happen, in one sentence. "Connect Gmail" is not a job.
"Every morning, tell me which emails need an answer today" is a job.

This matters because the job decides the scope. A read-only job needs a read-only key, and
that single distinction prevents most of what goes wrong in this layer.

### Step 2: Find the way in

Research the target for a CLI first, then an API, then an MCP server. Report what you found
as one short table using the ladder above, with the rung you recommend and why.

If the tool needs an account the user does not have, or a paid tier, say that now rather
than after they have spent twenty minutes.

### Step 3: Scope the credential before creating it

**First, check what the credential you already have can do.** Reusing an existing CLI login is
the fastest path and the easiest way to hand an agent far more authority than the job needs.
An existing session often authenticates as you, with everything you can do. Verify the
identity and the *effective* scopes before you build on it:

```bash
gh auth status          # which account, and which scopes that token carries
gcloud auth list        # active account
aws sts get-caller-identity
```

`gh auth login`, for example, requests a set that includes `repo`, `read:org` and `gist` by
default, which is far more than "read one repository". If the existing session is broader than
the job, mint a narrower credential for the job instead of reusing it.

Then say out loud what permission the job needs, and take the narrowest set the provider
actually enforces:

- Read-only when the job only reads. Most first connections only read.
- **The smallest documented set of scopes and resources**, not "all". Ask for the specific
  scope, the specific resource, and an expiry if the provider offers one.
- **Only the provider can enforce capability.** OAuth scopes, IAM policy, resource
  restrictions, tenant, expiry and revocation are the boundary. Your script is not. If the
  provider cannot enforce the limit the job needs, isolate the credential or stop.
- **Keys, not prompts.** "Never post without asking me" is an instruction and instructions
  are not a permission layer. If the capability is on the keyring, it can fire. Leave it off.

**Where the credential lives, in order of preference:**

1. The vendor's own OAuth or device flow, with the CLI storing the grant in its own
   credential store.
2. The OS keychain, or a real secret manager.
3. A local `.env` your script loads explicitly, as a fallback only.

`.gitignore` is not security. It keeps a file out of ordinary Git tracking; it does not
encrypt anything, does not stop backups, cloud-synced home directories, logs, indexers or
another agent on the same machine from reading it. And note that a script reading
`os.environ["TOKEN"]` does **not** load `.env` by itself; something has to load it.

**You never create, paste, or echo a secret.** Hand the user the exact steps and let them do it.

### Step 4: Wire the smallest thing that works

Write it into `scripts/<tool>.sh` (or `.py`) with a comment block saying what it does, which
credential it expects, and which scope that credential was granted. One script, one job.
Resist building the full client.

Be honest in that comment: it documents intent, it does not enforce anything. If the
credential can send, then `curl` can send, and so can an edited copy of your script.

### Step 5: Prove it, without dumping real data

Run it and confirm it works. **Prove it with the least sensitive thing that demonstrates
success**: HTTP status, a record count, the returned schema, a redacted identifier, or a
test/synthetic object where the provider offers one.

Do not paste real email bodies, calendar titles, balances, account numbers or verbose error
payloads into the terminal. That output lands in your scrollback, the agent transcript, and
any log or memory the session writes, which is the opposite of what this skill is for.

A connection you have not seen succeed is a hypothesis, not a connection. If it fails, debug
it now. A half-wired connection is worse than none, because six weeks later nobody remembers
whether it works.

### Step 6: Register it in `connections.md`

Not optional. An unregistered connection is invisible to every future session and to
`/aios-audit`. **Fill in the existing row for that domain, using the file's own columns** —
do not invent a second table:

```markdown
| # | Domain | Your tool(s) | Mechanism | Auth | Last checked |
|---|--------|--------------|-----------|------|--------------|
| 2 | Communication, email & chat | Gmail | `scripts/gmail.sh` (API + wrapper) | OAuth, `gmail.readonly` scope | 2026-08-03 |
```

Record the **actual** grant in the Auth column, in the provider's own vocabulary. "Read-only
key" is usually not a real thing: Gmail, for example, is an OAuth grant scoped to
`gmail.readonly`, and widening it later means re-consenting to a broader scope, not minting a
second key.

### Step 7: Offer the next rung, do not take it

If the job could grow (read today, act later), say what that would take and stop. Widening
reach is a decision the user makes deliberately, not a thing that happens because the
session had momentum.

## Guardrails

- **Never invent an integration.** If a tool has no API, say so plainly. A confidently
  described endpoint that does not exist costs more than an honest no.
- **Never script a password entry, an MFA code, a CAPTCHA, or a reused session cookie, and
  never scrape a private authenticated UI.** A documented OAuth or device-authorization flow
  is legitimate and is not what this bans. Typing someone's password into a browser you drive
  is not a connection, it is a workaround with someone else's terms of service attached.
- **Financial services get a hard stop.** Never ask for banking passwords, MFA codes,
  recovery codes or session cookies. Use vendor-supported OAuth or open-banking access only,
  and never request transaction-write scope for a read-only job.
- **Never put a secret in a script, the wiki, a committed file, or the terminal.** Prefer the
  vendor's own credential store or the OS keychain; treat `.env` as an explicitly loaded
  local fallback, and remember `.gitignore` is not encryption.
- **Sensitive-work boundary: this is a stop, not a redirect.** If the tool holds employer or
  client information, do not wire it until your organization has approved the whole processing
  path: the runtime, the device, the account and tenant, the OAuth application, the connector,
  the model, the storage, the retention and the data classes. Putting it "in the work folder
  with an approved model" is not approval, and neither is a private repo you happen to own.
  See `references/data-boundary.md`.

## Related

- `connections.md` — the registry every connection must land in
- `references/four-cs-framework.md` — why Connections is layer 2 and what it scores
- `references/data-boundary.md` — which of your two systems a connection belongs to
- `/routines-builder` — for putting a proven connection on a schedule. Note that proving it
  here does **not** make it available to a scheduled run: a local `.env` or a CLI login on your
  machine is not visible to a cloud routine, and a local routine still needs the machine awake.
  A scheduled run needs its own credential path, configured separately
