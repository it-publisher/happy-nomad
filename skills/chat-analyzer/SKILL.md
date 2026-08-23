---
name: chat-analyzer
description: Stage 1 of the Happy Nomad pipeline. Extract structured, dated, practical facts (prices, rules, neighborhoods, resources) from per-topic chat slices produced by chat-slicer. Use after slicing, before building the guide.
---

# chat-analyzer — stage 1: extraction

## When to use

After **chat-slicer** produced `<country>_src/_slices/<topic>.txt`. Turn raw messages into structured facts.

## Input / output

- **Input**: one or more `<country>_src/_slices/<topic>.txt` files + the period of interest (e.g. last 6 months).
- **Output**: a structured fact list per topic, ready for **guide-builder** to lay out.

## What to extract

- **Prices** — always with a date and currency; prefer ranges over single values.
- **Rules & procedures** — visas, rental terms, exchange limits.
- **Places** — neighborhoods (pros/cons, safety), stores, services.
- **Resources** — links, channels, groups, specialist contacts.
- **Patterns** — inflation, seasonality, recurring warnings.

## Principles

1. **Freshness** — prioritize the requested period; tag every fact with its message date.
2. **Concreteness** — numbers, names, links, not vibes.
3. **Traceability** — keep the message date next to each claim.
4. **De-identification** — capture the fact, not who said it. No usernames in output.
5. **No invention** — if a slice is thin, say "insufficient data", never fill gaps from imagination.

## Method

- Read each slice; the date is the first tab-field, the text follows.
- Cluster messages that agree; note the spread when they disagree.
- Mark confidence: `✅ confirmed (N msgs)` / `⚠️ single mention` / `❓ needs check`.
- For large slices, sample across the whole period, not just the top.

## Next stage

Pass the fact lists to **guide-builder** (stages 2–3). Verification happens later in **fact-checker** (stage 4).

---

## 🇷🇺 Русская версия

**Этап 1 — извлечение.** После `chat-slicer` превращаем сырые сообщения в структурированные факты.

- **Вход**: `<страна>_src/_slices/<тема>.txt` + период актуальности.
- **Выход**: список фактов по темам для `guide-builder`.

Что извлекать: цены (всегда с датой и валютой, диапазоны), правила и процедуры (визы, аренда, лимиты обмена), места (районы с плюсами/минусами и безопасностью), ресурсы (ссылки, чаты, контакты), паттерны (инфляция, сезонность).

Принципы: свежесть (дата у каждого факта), конкретика (цифры/названия/ссылки), обезличивание (факт, а не кто сказал — без юзернеймов), никаких выдумок (тонкий срез → «данных недостаточно»). Метки уверенности: `✅ подтверждено (N)` / `⚠️ единичное` / `❓ проверить`.

Дальше — **guide-builder** (этапы 2–3), затем **fact-checker** (этап 4).
