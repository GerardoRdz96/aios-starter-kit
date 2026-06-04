# routines/

Definitions for **recurring, unattended automations** — work that runs on a schedule or an
event without you starting it. A daily news scan, a weekly audit, a "watch this repo" job.

Build one with `/routines-builder`, which first decides the right mechanism (a scheduled
cloud routine, a hook, a `/loop`, or a ritual skill) and then walks a supervised test before
arming it — because routines run on their own, you want to see one run before trusting it.

Each routine lives as its own `<name>.md` here, describing what it does, when it fires, and
what it produces. None ship pre-built — they're personal by nature.

> Routines run **as you**, with your access. Scope their tools tightly and never hard-code
> secrets — use environment variables.
