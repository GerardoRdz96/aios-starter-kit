# Contributing / Contribuir

First time contributing to open source? This is a great place to start. Most tasks here are small, self-contained, and merged fast. / ¿Primera vez contribuyendo a open source? Este es un gran lugar para empezar. La mayoría de las tareas son pequeñas y se aprueban rápido.

> **Our promise:** we aim to review every PR within 48 hours and merge anything reasonable. A tiny PR that improves one thing is exactly what we want. / **Nuestra promesa:** revisamos cada PR en menos de 48 horas y aprobamos todo lo razonable. Un PR pequeño que mejora una cosa es justo lo que buscamos.

## Three easy ways to contribute / Tres formas fáciles de contribuir

### 1. Add yourself to the Showcase (easiest) / Agrégate al Showcase (lo más fácil)

Built your own AIOS from this kit, or just cloned it to try? Add one line to [`SHOWCASE.md`](SHOWCASE.md) telling us what you're building. One small PR, you're a contributor. / ¿Ya armaste tu AIOS con este kit, o lo clonaste para probar? Agrega una línea a [`SHOWCASE.md`](SHOWCASE.md). Un PR pequeño y ya eres contribuidor.

### 2. Grab a `good first issue` / Toma un `good first issue`

Browse the [open issues labeled **`good first issue`**](../../issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22). Each is scoped to a single file or a single change. Comment "I'll take this" and go. / Revisa los [issues con la etiqueta **`good first issue`**](../../issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22). Cada uno es una sola cosa. Comenta "yo lo tomo" y adelante.

Good starter categories:
- **Translations** — port a section of the README, `class/`, or a skill's docs to another language.
- **Skill recipes** — add a small, useful skill template under `.claude/skills/` with a README.
- **Connection recipes** — add a CLI-first integration recipe to `connections.md`.
- **Examples** — add an example `knowledge/` source or a `decisions/log.md` entry showing the wiki loop.
- **Docs polish** — fix a typo, clarify a step, improve the Quickstart.

### 3. Propose something / Propón algo

Have an idea the kit is missing? Open an issue with the **Idea / Propuesta** template. Small, additive ideas get merged; we'll help you scope it.

## How to submit a PR / Cómo enviar un PR

```bash
# 1. Fork + clone your fork
git clone https://github.com/<your-username>/aios-starter-kit.git
cd aios-starter-kit

# 2. Branch
git checkout -b my-contribution

# 3. Make ONE focused change, then commit
git add -A && git commit -m "docs: add Portuguese translation of Quickstart"

# 4. Push and open a PR against main
git push origin my-contribution
```

Then open a Pull Request. Fill in the short template. That's it.

## Ground rules / Reglas básicas

- **Keep PRs small and focused.** One change per PR merges faster than a big mixed one.
- **This kit is a template, not a product with secrets.** Never add real API keys, personal data, or client/company content. `.env` and `knowledge/` are gitignored for a reason.
- **Be kind.** We follow the standard [Contributor Covenant](https://www.contributor-covenant.org/version/2/1/code_of_conduct/) spirit: assume good faith, be welcoming, no harassment.
- **You keep credit.** Every merged PR shows up in the contributor list. That's the point.

## Questions? / ¿Dudas?

Open an issue with the **Question / Pregunta** template, or start a discussion. No question is too basic here. / Abre un issue con la plantilla de pregunta. Ninguna pregunta es demasiado básica.

Thank you for helping other people build their own AI operating system. / Gracias por ayudar a que más personas construyan su propio sistema operativo de IA.
