#!/usr/bin/env nu
#
# slice.nu — stage 0 of the Happy Nomad pipeline (Nushell port of slice.sh).
# Cuts a Telegram JSON export into per-topic text slices so an agent
# reads only relevant messages instead of the whole (huge) export.
#
# Noise control:
#   - de-dup: identical message texts (ad reposts, forwards) are collapsed.
#   - spam:   patterns in scripts/spam.txt are dropped (tune per chat).
#
# Usage:
#   nu scripts/slice.nu <country>/<country>_src/result.json [out_dir] [topics.json]
#
# Без out_dir срезы ложатся рядом с экспортом: <country>/<country>_src/_slices/
#
# Output: <out_dir>/<topic>.txt, one line per message: "<ISO date>\t<text>"

def norm-text [m] {
  if ($m.text_entities? != null) {
    $m.text_entities | get text | str join
  } else {
    let t = $m.text?
    let d = ($t | describe)
    if $d == "string" {
      $t
    } else if ($d | str starts-with "list") {
      $t | each {|e| if (($e | describe) | str starts-with "record") { $e.text } else { $e } } | str join
    } else {
      ""
    }
  }
}

def main [export: string, out: string = "", topics: string = ""] {
  let script_dir = $env.FILE_PWD
  # По умолчанию срезы ложатся рядом с экспортом, на любой вложенности:
  # chile/chile_src/result.json → chile/chile_src/_slices
  let out = (if ($out | is-empty) { ($export | path dirname | path join "_slices") } else { $out })
  let topics_path = (if ($topics | is-empty) { $script_dir | path join "topics.json" } else { $topics })
  let spam_path = ($script_dir | path join "spam.txt")

  if not ($export | path exists) { print $"Error: export not found: ($export)"; exit 1 }
  if not ($topics_path | path exists) { print $"Error: topics config not found: ($topics_path)"; exit 1 }
  mkdir $out

  # Build one case-insensitive spam regex from spam.txt (skip blanks and #-comments).
  let spam_re = (
    if ($spam_path | path exists) {
      let pats = (open --raw $spam_path | lines
        | each {|l| $l | str trim }
        | where {|l| ($l | is-not-empty) and (not ($l | str starts-with "#")) })
      if ($pats | is-empty) { "__HAPPYNOMAD_NEVER_MATCH__" } else { $"\(?i\)\(($pats | str join '|')\)" }
    } else { "__HAPPYNOMAD_NEVER_MATCH__" }
  )

  # Read once, normalize each message, drop empty + spam.
  let msgs = (open $export | get messages
    | insert txt {|m| norm-text $m }
    | where txt != ""
    | where txt !~ $spam_re
    | select date txt)

  print $"Slicing ($export) → ($out)/  \(de-dup + spam filter on\)"
  mut total = 0
  for row in (open $topics_path | transpose topic re) {
    let re = $"\(?i\)\(($row.re)\)"
    let out_path = ($out | path join $"($row.topic).txt")
    let rows = ($msgs | where txt =~ $re | uniq-by txt)
    let lines = ($rows | each {|r| $"($r.date)\t($r.txt | str replace --all "\n" ' ')" })
    # trailing newline on non-empty output for byte-parity with the bash version
    let text = (if ($lines | is-empty) { "" } else { ($lines | str join "\n") + "\n" })
    $text | save --force --raw $out_path
    let n = ($rows | length)
    print $"  (($row.topic) | fill -a left -w 14)(($n | into string) | fill -a right -w 6) msgs → ($out_path)"
    $total = $total + $n
  }
  print $"Done. ($total) matched lines across topics."
  print $"Next: point your agent at ($out)/ and run the guide-builder skill."
}
