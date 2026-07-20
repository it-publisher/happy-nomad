#!/usr/bin/env bash
#
# slice.sh — stage 0 of the Happy Nomad pipeline.
# Cuts a Telegram JSON export into per-topic text slices so an agent
# reads only relevant messages instead of the whole (huge) export.
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

command -v jq >/dev/null 2>&1 || { echo "Error: jq is required (https://jqlang.org)"; exit 1; }
[ -f "$EXPORT" ] || { echo "Error: export not found: $EXPORT"; exit 1; }
[ -f "$TOPICS" ] || { echo "Error: topics config not found: $TOPICS"; exit 1; }

mkdir -p "$OUT"

# Normalize a Telegram message to plain text, handling all three shapes:
#   text_entities[] (preferred), plain string text, mixed array text.
JQ_PROG='
def msgtext:
  if (.text_entities? | type) == "array" then ([.text_entities[].text] | join(""))
  elif (.text | type) == "string" then .text
  elif (.text | type) == "array" then ([.text[] | if type == "object" then .text else . end] | join(""))
  else "" end;
.messages[]? | msgtext as $t
| select($t | length > 0)
| select($t | test($re; "i"))
| "\(.date)\t\($t | gsub("\n"; " "))"
'

echo "Slicing $EXPORT → $OUT/"
total=0
while IFS=$'\t' read -r topic re; do
  out="$OUT/$topic.txt"
  jq -r --arg re "$re" "$JQ_PROG" "$EXPORT" > "$out"
  n=$(wc -l < "$out" | tr -d ' ')
  printf '  %-14s %6s msgs → %s\n' "$topic" "$n" "$out"
  total=$((total + n))
done < <(jq -r 'to_entries[] | "\(.key)\t\(.value)"' "$TOPICS")

echo "Done. $total matched lines across topics."
echo "Next: point your agent at $OUT/ and run the guide-builder skill."
