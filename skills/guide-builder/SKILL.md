---
name: guide-builder
description: Stages 2-3 of the Happy Nomad pipeline. Lay extracted facts into topic Markdown files from the country template, then assemble the README in guide (impersonal) or personal (checklist) mode. Use after chat-analyzer, before fact-checker.
---

# guide-builder — stages 2–3: layout + assembly

## When to use

After **chat-analyzer** produced fact lists. Build the country folder.

## Procedure

1. **Scaffold** — the country folder already exists — it was created in stage 0 to hold the sources. Copy the stubs in beside them:
   ```bash
   cp templates/*.md <country>/     # e.g. chile/
   ```
   ⚠️ Not `cp -r templates <country>/` — with the folder already there that nests a `templates/` directory inside it.

   Layout after this step:
   ```
   chile/
   ├── README_guide.md, Housing.md, …   # stubs to fill
   └── chile_src/                       # sources, gitignored
   ```
   The Markdown comes out ready to publish — stage 4 de-identifies it before you ship.
2. **Lay out (stage 2)** — fill each topic stub (`Housing.md`, `Visa_Documents.md`, `Budget.md`, ...) from the matching fact list. Keep the section structure; drop topic files with no data instead of leaving empty placeholders.
3. **Assemble (stage 3)** — pick the README mode, rename it to `README.md`, delete the other:

   | Mode | File | For |
   |------|------|-----|
   | **guide** | `README_guide.md` | shareable, impersonal country guide |
   | **personal** | `README_personal.md` | the user's own move — checklist + dated plan |

   Fill the README navigation, key figures, and the "last updated / source" block.

## Rules

- Every price/rate carries a date. No date → not published.
- Contradictions → show a range and note the spread, never a single made-up number.
- Impersonal in `guide` mode: no "I", no travel dates, no personal budget framing.
- Topic files are identical across modes; only the README differs.
- Follow the template section order — it's the proven structure, don't reinvent it.

## Next stage

Send the assembled folder to **fact-checker** (stage 4) before shipping.

---

## 🇷🇺 Русская версия

**Этапы 2–3 — раскладка и сборка.** После `chat-analyzer` собираем папку страны.

1. **Скелет**: папка страны уже создана на этапе 0 под исходники, поэтому кладём стабы рядом с ними: `cp templates/*.md <страна>/`. ⚠️ Не `cp -r templates <страна>/` — так внутрь ляжет лишний каталог `templates/`. Наружу уходят файлы Markdown — этап 4 готовит их к публикации.
2. **Раскладка (этап 2)**: наполняешь тематические стабы (`Housing.md`, `Visa_Documents.md`, ...) из фактов. Сохраняешь структуру секций; тему без данных — удаляешь, а не оставляешь пустой.
3. **Сборка (этап 3)**: выбираешь режим README, переименовываешь в `README.md`, второй удаляешь:
   - **guide** (`README_guide.md`) — публичный обезличенный гайд.
   - **personal** (`README_personal.md`) — свой переезд, чеклист + план по датам.

Правила: дата у каждой цифры; противоречия → диапазон, не выдуманное значение; в режиме guide — без «я», дат отъезда и личного бюджета; порядок секций — по шаблону.

Дальше — **fact-checker** (этап 4).
