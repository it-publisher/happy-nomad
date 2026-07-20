---
name: fact-checker
description: Stage 4 (final) of the Happy Nomad pipeline. Verify a built country guide before shipping — date every figure, drop or flag stale data, resolve contradictions into ranges, mark confidence, and cross-check legal/visa/tax claims against official sources. Use as the last step before a guide is considered ready.
---

# fact-checker — stage 4: verification

## When to use

The last step, always. A guide is not "done" until it passes this pass.

## Checklist (run per topic file)

- [ ] **Date on every figure.** A price/rate without a message date is removed.
- [ ] **Freshness.** Data older than ~6 months is marked `⚠️ stale (date)` or dropped.
- [ ] **Contradictions.** Conflicting numbers → a range with a note on the spread, never one invented value.
- [ ] **Confidence tags.** Disputed facts labeled `✅ confirmed (N msgs)` / `⚠️ single mention` / `❓ needs check`.
- [ ] **Official cross-check.** Legal, visa, tax and border-rule claims verified against an official source, not only the chat.
- [ ] **No hallucination.** Anything absent from the slices is absent from the guide; thin topics are honestly marked "insufficient data".
- [ ] **De-identified.** No usernames, phone numbers, or personal identifiers leaked from the chat.

## Output

Append an "Accuracy & verification" block to the README:

```markdown
## Accuracy & verification

- Source: [chat], N messages, period [dates]
- Analyzed: [date]
- Sections marked ⚠️ need re-checking before you rely on them
```

## Principle

The engine's credibility is this stage. A wrong dated figure is recoverable; a confident undated guess is not. When unsure, downgrade the confidence tag rather than assert.

---

## 🇷🇺 Русская версия

**Этап 4 — проверка. Финальный, всегда.** Гайд не готов, пока не прошёл фактчек.

Чек-лист по каждому файлу:

- дата у каждой цифры; без даты — удаляем;
- данные старше ~6 мес → `⚠️ устарело (дата)` или убрать;
- противоречия → диапазон + отметка разброса, не выдуманное значение;
- метки уверенности: `✅ подтверждено (N)` / `⚠️ единичное` / `❓ проверить`;
- визовые/налоговые/юридические факты — сверить с официальным источником, не только с чатом;
- чего нет в срезах — того нет в гайде; тонкие темы честно помечаем;
- обезличено: без юзернеймов, телефонов, личных идентификаторов.

Итог — блок «Актуальность и проверка» в README. Принцип: неуверен — понижай метку уверенности, а не утверждай.
