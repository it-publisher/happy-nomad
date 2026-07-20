#!/usr/bin/env bash
#
# slice.sh — stage 0 of the Happy Nomad pipeline.
# Cuts a Telegram JSON export into per-topic text slices so an agent
# reads only relevant messages instead of the whole (huge) export.
#
# Noise control:
#   - de-dup: identical message texts (ad reposts, forwards) are collapsed.
#   - spam:   patterns in scripts/spam.txt are dropped (tune per chat).
#
# Usage:
#   ./scripts/slice.sh <export.json> [out_dir] [topics.json]
#
# Output: <out_dir>/<topic>.txt, one line per message: "<ISO date>\t<text>"
#
set -euo pipefail

EXPORT="${1:?Usage: slice.sh <export.json> [out_dir] [topics.json]}"
OUT="${2:-_slices}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOPICS="${3:-$SCRIPT_DIR/topics.json}"
SPAM="$SCRIPT_DIR/spam.txt"

command -v jq >/dev/null 2>&1 || { echo "Error: jq is required (https://jqlang.org)"; exit 1; }
[ -f "$EXPORT" ] || { echo "Error: export not found: $EXPORT"; exit 1; }
[ -f "$TOPICS" ] || { echo "Error: topics config not found: $TOPICS"; exit 1; }

mkdir -p "$OUT"

# Build one spam regex from spam.txt (skip blanks and #-comments).
# Fall back to a never-matching sentinel so nothing is dropped when empty.
SPAM_RE=''
if [ -f "$SPAM" ]; then
  SPAM_RE="$(grep -vE '^[[:space:]]*(#|$)' "$SPAM" | paste -sd '|' - || true)"
fi
SPAM_RE="${SPAM_RE:-__HAPPYNOMAD_NEVER_MATCH__}"

# Normalize a Telegram message to plain text, handling all three shapes:
#   text_entities[] (preferred), plain string text, mixed array text.
# Keep it only if it matches the topic regex AND not the spam regex.
JQ_PROG='
def msgtext:
  if (.text_entities? | type) == "array" then ([.text_entities[].text] | join(""))
  elif (.text | type) == "string" then .text
  elif (.text | type) == "array" then ([.text[] | if type == "object" then .text else . end] | join(""))
  else "" end;
.messages[]? | msgtext as $t
| select($t | length > 0)
| select($t | test($re; "i"))
| select(($t | test($spam; "i")) | not)
| "\(.date)\t\($t | gsub("\n"; " "))"
'

echo "Slicing $EXPORT → $OUT/  (de-dup + spam filter on)"
total=0
while IFS=$'\t' read -r topic re; do
  out="$OUT/$topic.txt"
  # jq filter → de-dup identical texts (keep first) via awk on the post-tab field.
  jq -r --arg re "$re" --arg spam "$SPAM_RE" "$JQ_PROG" "$EXPORT" \
    | awk -F'\t' '!seen[$2]++' > "$out"
  n=$(wc -l < "$out" | tr -d ' ')
  printf '  %-14s %6s msgs → %s\n' "$topic" "$n" "$out"
  total=$((total + n))
done < <(jq -r 'to_entries[] | "\(.key)\t\(.value)"' "$TOPICS")

echo "Done. $total matched lines across topics."
echo "Next: point your agent at $OUT/ and run the guide-builder skill."
