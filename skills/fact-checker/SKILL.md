---
name: fact-checker
description: Stage 4 (final) of the Happy Nomad pipeline. Verify a built country guide before shipping — date every figure, drop or flag stale data, resolve contradictions into ranges, mark confidence, and cross-check legal/visa/tax claims against official sources. Use as the last step before a guide is considered ready.
---

# fact-checker — stage 4: verification

## When to use

The last step, always. A guide is not "done" until it passes this pass.

## Checklist (run per topic file)

- [ ] **Date on every figure.** A price/rate without a message date is removed.
- [ ] **Freshness.** Every figure gets a staleness mark from the scale below.
- [ ] **Contradictions.** Conflicting numbers → a range with a note on the spread, never one invented value.
- [ ] **Confidence tags.** Disputed facts labeled `✅ confirmed (N msgs)` / `⚠️ single mention` / `❓ needs check`.
- [ ] **Official cross-check.** Legal, visa, tax and border-rule claims verified against an official source, not only the chat.
- [ ] **No hallucination.** Anything absent from the slices is absent from the guide; thin topics are honestly marked "insufficient data".
- [ ] **De-identified.** Run the pass below — this is a step, not a glance.

## Staleness scale

Age is counted **from today, not from the day you analysed the chat.** A guide built six months ago has to be re-scored, not trusted.

| Mark | Age of the data | How to use it |
|------|-----------------|---------------|
| *(none)* | under 3 months | a working figure |
| `⚠️ approximate (date)` | 3–6 months | an order of magnitude, not a fact |
| `⚠️ stale (date)` | over 6 months | do not use without re-checking |

Two corrections to the scale:

- **Currency decides.** In a high-inflation economy, prices in local currency rot several times faster than dollar-denominated ones. A six-month-old peso price is rubbish; a dollar price of the same age is an approximation.
- **Rules outlive figures.** "You need a SUBE card to ride" or "carrier A is steadier than B" stays true long after the specific tariff is garbage. Mark the amount stale, not the whole point.

## De-identification pass (required)

The chat members wrote for the room, not for publication. The guide gets shared; they never agreed to that.

**Don't drop attributions — replace them.** Who said a thing is real signal: a three-year resident and a first-week tourist deserve different weight. Anonymising to "someone said" destroys that. Substitute a role instead.

| Found in the draft | Replace with |
|--------------------|--------------|
| A recurring voice with visible tenure | `long-timer, 3 years in the city` |
| A visa agent answering professionally | `visa consultant` |
| A one-off quote, no context | `chat member` |

**Strip:** personal names and surnames, phone numbers, apartment and street addresses, employers, anything identifying a private person.

**Keep:** public channel handles (`@vietnam_viza`), business and venue names, blogger accounts and their published referral codes. These are public by nature, and removing them destroys the guide's usefulness.

**Verify before shipping** — a grep is enough to catch what the eye misses:

```bash
# Capitalised words in attribution position — should return role labels only
grep -ohE "^> — .+|— [A-ZА-ЯЁ][a-zа-яё]+ [A-ZА-ЯЁ][a-zа-яё]+" <country>/*.md | sort -u
```

After this pass the guide is ready to publish.

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
- срок годности: каждая цифра получает метку по шкале ниже;
- противоречия → диапазон + отметка разброса, не выдуманное значение;
- метки уверенности: `✅ подтверждено (N)` / `⚠️ единичное` / `❓ проверить`;
- визовые/налоговые/юридические факты — сверить с официальным источником, не только с чатом;
- чего нет в срезах — того нет в гайде; тонкие темы честно помечаем;
- **обезличено** — прогон ниже, это шаг, а не беглый взгляд.

### Шкала срока годности

Возраст считается **от сегодняшней даты, а не от даты анализа.** Гайд, собранный полгода назад, надо переоценивать заново.

| Метка | Возраст данных | Как использовать |
|-------|----------------|------------------|
| *(без метки)* | до 3 месяцев | рабочая цифра |
| `⚠️ ориентир (дата)` | 3–6 месяцев | порядок величины, не факт |
| `⚠️ устарело (дата)` | больше 6 месяцев | без перепроверки не использовать |

Две поправки к шкале:

- **Валюта решает.** В стране с высокой инфляцией цены в местной валюте протухают в разы быстрее, чем номинированные в долларах. Песо-цену полугодовой давности выкидывай, долларовую того же возраста помечай ориентиром.
- **Правила живут дольше цифр.** «Для проезда нужна карта SUBE» или «оператор A стабильнее B» остаются верными, когда конкретный тариф уже мусор. Помечай устаревшей саму сумму, а не весь пункт.

### Обезличивание (обязательный шаг)

Участники чата писали для своей комнаты, а не для публикации. Гайд уходит наружу, они на это не соглашались.

**Атрибуции не выбрасывать, а заменять.** Кто сказал — это сигнал: старожил и турист первой недели весят по-разному. «Кто-то писал» этот сигнал уничтожает. Вместо имени — роль.

| Что в черновике | Чем заменить |
|-----------------|--------------|
| Постоянный голос с понятным стажем | `старожил, 3 года в городе` |
| Визовый агент, отвечающий профессионально | `визовый консультант` |
| Разовая цитата без контекста | `участник чата` |

**Убирать:** имена и фамилии, телефоны, адреса квартир и улиц, места работы — всё, что указывает на конкретного частного человека.

**Оставлять:** публичные хендлы каналов (`@vietnam_viza`), названия заведений и бизнесов, аккаунты блогеров и их же опубликованные промокоды. Это публично по своей природе, а без них гайд теряет практическую ценность.

**Проверить перед сдачей** — грепом ловится то, что глаз пропускает:

```bash
grep -ohE "^> — .+|— [A-ZА-ЯЁ][a-zа-яё]+ [A-ZА-ЯЁ][a-zа-яё]+" <страна>/*.md | sort -u
```

После этого прогона гайд готов к публикации.

Итог — блок «Актуальность и проверка» в README. Принцип: неуверен — понижай метку уверенности, а не утверждай.
