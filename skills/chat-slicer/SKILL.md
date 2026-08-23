---
name: chat-slicer
description: Stage 0 of the Happy Nomad pipeline. Slice a large Telegram/expat chat JSON export into per-topic text slices with Nushell, so later stages read only relevant messages instead of the whole export. Use when a chat export is too big to read directly (thousands of messages).
---

# chat-slicer — stage 0: preprocessing

## When to use

A raw expat chat export has tens of thousands of messages and does not fit in context. Before any analysis, cut it into small per-topic slices.

## Input / output

- **Input**: a Telegram Desktop JSON export at `<country>_src/result.json`, with a `messages[]` array.
- **Output**: `<country>_src/_slices/<topic>.txt`, one line per message — `<ISO date>\t<text>`.

**Folder convention.** Everything raw lives in `<country>_src/` — the export, the slices, and an optional per-country `topics.json`. The guide folder `<country>/` holds only publishable Markdown. `*_src/` is gitignored, so a raw export never reaches a repository by accident.

## Procedure

1. Confirm Nushell (`nu`) is installed — https://www.nushell.sh/
2. Run the bundled slicer:
   ```nu
   nu scripts/slice.nu <country>_src/result.json
   ```
   With no output path given, slices land next to the export, in `<country>_src/_slices/`.
   It reads `scripts/topics.json` (per-topic keyword regexes, RU+EN) and writes one slice per topic.
   Noise control runs automatically: identical texts (ad reposts, forwards) are de-duped, and patterns from `scripts/spam.txt` are dropped.
3. Report the per-topic message counts. Thin slices (< ~20 messages) mean the source chat is weak on that topic — flag it; don't invent content later.

## Message normalization

Telegram `text` can be a string, an array (with links/emoji), or empty. Always build plain text from `text_entities` first (Nushell):

```nu
if ($m.text_entities? != null) { $m.text_entities | get text | str join } else { $m.text? | default "" }
```

## Extending

- New topic → add a `"topic": "regex"` line to `scripts/topics.json`. Include RU, EN, and local-language terms (city names, local brands, carriers).
- Ads leaking through → add a tight regex to `scripts/spam.txt` (e.g. a spammy rental bot's `@name`). Keep patterns precise; over-filtering drops real messages.
- Other chat sources (Discord/WhatsApp) → normalize to `{ date, text }` and reuse the same slicer.

## Next stage

Hand the slices to **chat-analyzer** (stage 1).

---

## 🇷🇺 Русская версия

**Этап 0 — предобработка.** Большой экспорт чата (десятки тысяч сообщений) не влезает в контекст. Сначала режем его на срезы по темам.

- **Вход**: JSON-экспорт Telegram в `<страна>_src/result.json`, массив `messages[]`.
- **Выход**: `<страна>_src/_slices/<тема>.txt`, строка на сообщение — `<дата>\t<текст>`.

**Конвенция папок.** Всё сырое лежит в `<страна>_src/` — экспорт, срезы и, при необходимости, свой `topics.json`. В папке гайда `<страна>/` только публикуемый Markdown. `*_src/` в gitignore, поэтому сырой экспорт не попадёт в репозиторий по случайности.

Порядок:

1. Проверь, что установлен Nushell (`nu`) — https://www.nushell.sh/
2. Запусти `nu scripts/slice.nu <страна>_src/result.json` — он читает `scripts/topics.json` (регулярки RU+EN по темам). Без указания пути срезы лягут рядом с экспортом.
3. Покажи счётчики по темам. Тонкий срез (< ~20 сообщений) = чат слабо покрывает тему; помечай, не выдумывай.

Текст сообщения собирай из `text_entities` (учитывает ссылки, эмодзи). Шумоподавление включено автоматически: дубли (репосты рекламы) схлопываются, паттерны из `scripts/spam.txt` вырезаются. Новая тема — строка в `topics.json`; протекает реклама — добавь точный паттерн в `spam.txt`.

Дальше — скилл **chat-analyzer** (этап 1).
