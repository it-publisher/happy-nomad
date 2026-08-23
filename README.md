# 🌍 Happy Nomad

**Turn an expat chat export into a ready-to-use country guide.**

Drop a Telegram chat export, run the pipeline, get a structured Markdown guide — housing, visas, budget, currency, connectivity, neighborhoods — with every figure dated and fact-checked.

A set of portable [Agent Skills](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview) (`SKILL.md`) plus working scripts. Works with any client that reads the Agent Skills format — Claude Code, Codex, and others.

> 🇷🇺 [Русская версия — README.ru.md](README.ru.md)

---

## Why

Expat chats hold the most current, practical relocation intel — but it's buried in tens of thousands of messages. This engine extracts it into a clean, verifiable guide instead of you scrolling for days.

Not another static "top 10 cities" listicle: **your** source chat, **current** prices with dates, contradictions flagged, stale data dropped.

---

## How it works — the 5-stage pipeline

```text
0. Slice      Nushell cuts the JSON export into per-topic slices (scripts + chat-slicer)
1. Extract    pull facts with dates and quotes                  (chat-analyzer)
2. Lay out    facts → topic .md files from templates            (guide-builder)
3. Assemble   build README — guide or personal mode             (guide-builder)
4. Fact-check verify, drop stale, mark confidence               (fact-checker)
```

The big win is **stage 0**: a 20k+ message export never fits in a model's context. Scripts slice it by topic keywords first, so the model only reads relevant chunks. Duplicate ad reposts are collapsed and known spam patterns (`scripts/spam.txt`) are dropped on the way.

---

## Quick start

### With an agent

Paste this into Claude Code, Codex, or any client that reads Agent Skills. It handles the setup, the tuning and the build; the only thing you do by hand is the chat export itself.

```text
Build me a country guide from an expat chat export.

Engine: https://github.com/it-publisher/happy-nomad
Clone it, install the skills from skills/ for my client,
then follow its README and SKILL files.

Destination: [city or country]
README mode: guide
Period: last 6 months

How to proceed:

1. Check whether Nushell is installed — the slicer only runs on it.
   Command: `nu --version`. If it is missing: install it yourself if you can
   (macOS `brew install nushell`, Windows `winget install nushell`,
   otherwise `cargo install nu`), and if you cannot — show me the exact
   command for my system and wait until I have done it.

2. I do not have the export yet. Explain how to make one, and call out
   the settings people get wrong.

3. scripts/topics.json is a universal RU+EN base. It catches general
   vocabulary but not local terms. Once the export exists, study the
   corpus and extend each topic with what actually appears in this chat:
   districts and place names, local banks and carriers, shop chains,
   service and app names, the currency and its slang, border crossings.
   Derive the terms from frequency analysis of the text, not from
   general assumptions about the country.

4. After slicing, show the per-topic counts. If a topic came out thin,
   say plainly that there is not enough data — do not invent. A topic
   with no data is better deleted than left as an empty stub.
```

<details>
<summary><b>Manual setup</b> — same thing, step by step</summary>

```bash
# 0. Install Nushell (the slicer runs on it) — https://www.nushell.sh/
#    macOS: brew install nushell · Windows: winget install nushell · cargo: cargo install nu

git clone https://github.com/it-publisher/happy-nomad
cd happy-nomad

# 1. Install the skills for your client (Claude Code example)
cp -r skills/* ~/.claude/skills/

# 2. Put your export in the destination's source folder
mkdir -p chile/chile_src && cp ~/Downloads/result.json chile/chile_src/result.json

# 3. Slice it by topic (stage 0) — slices land next to the export
nu scripts/slice.nu chile/chile_src/result.json

# 4. Drop the topic stubs in beside the sources
cp templates/*.md chile/

# 5. Ask your agent
#    "Build a country guide for Chile, mode: guide, period: last 6 months"
```

`scripts/topics.json` ships as a universal RU+EN base. Extend it with local terms — districts, banks, carriers, shop chains — or the slices will only catch generic vocabulary.

</details>

Your agent picks up the skills, reads the slices, fills the templates, and runs the fact-check.

---

## Two output modes

| Mode | README | For |
|------|--------|-----|
| **guide** | `README_guide.md` | a shareable, impersonal country guide |
| **personal** | `README_personal.md` | your own move — checklist + dated plan |

Topic files are identical in both modes; only the README differs.

---

## Repository layout

```
happy-nomad/
├── skills/            # Agent Skills (SKILL.md), the core
│   ├── chat-slicer/       # stage 0 — preprocessing
│   ├── chat-analyzer/     # stage 1 — extraction
│   ├── guide-builder/     # stages 2–3 — layout + assembly
│   └── fact-checker/      # stage 4 — verification
├── scripts/           # slice.nu (Nushell slicer) + topic keywords + spam stop-list
├── templates/         # country folder skeleton (2 README modes + topic stubs)
├── examples/argentina/# a de-identified filled guide (reference output)
├── agents/openai.yaml # Codex adapter (other clients ignore it)
└── README.md
```

### Guide and sources are separate

The pipeline writes into two folders per country, and the split is the point:

```
chile/                  # one folder per destination
├── README.md           # the guide — Markdown, safe to publish
├── Housing.md
├── ...
└── chile_src/          # sources — gitignored, stays on your machine
    ├── result.json         # raw chat export (other people's messages)
    ├── topics.json         # optional per-country keyword overrides
    └── _slices/            # intermediate topic slices
```

`*_src/` is in `.gitignore` and matches at any depth, so a careless `git add -A` cannot commit a raw export.

The Markdown comes out ready to publish: stage 4 de-identifies it, replacing chat members' names with roles like `long-timer, 3 years in the city`.

---

## Supported chat sources

- **Telegram Desktop** JSON export (`result.json`) — first-class.
- Others (Discord, WhatsApp, Reddit): normalize to the same `{ date, text }` shape and the pipeline works. See `scripts/topics.json`.

---

## Privacy

- Raw exports are **git-ignored** by default — your source data never leaves your machine.
- **Stage 4 de-identifies the guide** before it is considered done. Names are not dropped but replaced by roles — `long-timer, 3 years in the city`, `visa consultant` — so you still know whose experience a quote carries, without carrying the person.
- The bundled example (`examples/argentina/`) is de-identified: no raw chat, no names.

---

## Contributing

New topic keyword sets, chat-source adapters, and language translations are welcome. Keep it bilingual (EN + RU) and keep exports out of commits.

## License

[MIT](LICENSE)
