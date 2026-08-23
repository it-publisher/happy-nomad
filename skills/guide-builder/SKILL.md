---
name: guide-builder
description: Stages 2-3 of the Happy Nomad pipeline. Lay extracted facts into topic Markdown files from the country template, then assemble the README in guide (impersonal) or personal (checklist) mode. Use after chat-analyzer, before fact-checker.
---

# guide-builder — stages 2–3: layout + assembly

## When to use

After **chat-analyzer** produced fact lists. Build the country folder.

## Procedure

1. **Scaffold** — copy the template into a new country folder:
   ```bash
   cp -r templates <country>/   # e.g. chile/
   ```
   Sources stay separate in `<country>_src/` — the export, the slices, and any per-country config. Only `<country>/` is meant to be shared or published; `*_src/` is gitignored.
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

1. **Скелет**: `cp -r templates <country>/`. Исходники остаются отдельно, в `<country>_src/`: экспорт, срезы, свои конфиги. Наружу уходит только `<country>/`, а `*_src/` в gitignore.
2. **Раскладка (этап 2)**: наполняешь тематические стабы (`Housing.md`, `Visa_Documents.md`, ...) из фактов. Сохраняешь структуру секций; тему без данных — удаляешь, а не оставляешь пустой.
3. **Сборка (этап 3)**: выбираешь режим README, переименовываешь в `README.md`, второй удаляешь:
   - **guide** (`README_guide.md`) — публичный обезличенный гайд.
   - **personal** (`README_personal.md`) — свой переезд, чеклист + план по датам.

Правила: дата у каждой цифры; противоречия → диапазон, не выдуманное значение; в режиме guide — без «я», дат отъезда и личного бюджета; порядок секций — по шаблону.

Дальше — **fact-checker** (этап 4).
