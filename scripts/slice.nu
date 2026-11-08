#!/usr/bin/env nu
#
# slice.nu — stage 0 of the Happy Nomad pipeline.
# Cuts a Telegram JSON export into per-topic text slices so an agent
# reads only relevant messages instead of the whole (huge) export.
#
# Noise control:
#   - de-dup: identical message texts (ad reposts, forwards) are collapsed.
#   - spam:   patterns from scripts/spam.txt plus <src>/spam.txt are dropped.
#
# Usage:
#   nu scripts/slice.nu <country>/<country>_src/result.json [out_dir] [topics.json]
#
# Config lookup, so a per-country setup works without extra arguments:
#   topics: explicit arg > <src>/topics.json > scripts/topics.json  (replaces the base)
#   spam:   scripts/spam.txt + <src>/spam.txt                       (adds to the base)
# <src> is the export's folder. Without out_dir slices land in <src>/_slices/.
#
# Output: <out_dir>/<topic>.txt, one line per message: "<ISO date>\t<text>"

const NEVER_MATCH = "__HAPPYNOMAD_NEVER_MATCH__"

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

def resolve-topics [explicit: string, src_dir: string, script_dir: string] {
  if ($explicit | is-not-empty) { return $explicit }
  let local = ($src_dir | path join "topics.json")
  if ($local | path exists) { $local } else { $script_dir | path join "topics.json" }
}

# One case-insensitive regex from all spam files (skip blanks and #-comments).
def build-spam-re [paths: list<string>] {
  let pats = ($paths
    | each {|p| open --raw $p | lines }
    | flatten
    | each {|l| $l | str trim }
    | where {|l| ($l | is-not-empty) and (not ($l | str starts-with "#")) })
  if ($pats | is-empty) { $NEVER_MATCH } else { $"\(?i\)\(($pats | str join '|')\)" }
}

def main [export: string, out: string = "", topics: string = ""] {
  let script_dir = $env.FILE_PWD
  let src_dir = ($export | path dirname)
  let out = (if ($out | is-empty) { $src_dir | path join "_slices" } else { $out })
  let topics_path = (resolve-topics $topics $src_dir $script_dir)
  # uniq: when the export sits next to the script, both paths are the same file
  let spam_paths = ([($script_dir | path join "spam.txt") ($src_dir | path join "spam.txt")]
    | where {|p| $p | path exists }
    | each {|p| $p | path expand }
    | uniq)

  if not ($export | path exists) { print $"Error: export not found: ($export)"; exit 1 }
  if not ($topics_path | path exists) { print $"Error: topics config not found: ($topics_path)"; exit 1 }
  mkdir $out

  let spam_re = (build-spam-re $spam_paths)

  # Read once, normalize each message, drop empty + spam.
  let msgs = (open $export | get messages
    | insert txt {|m| norm-text $m }
    | where txt != ""
    | where txt !~ $spam_re
    | select date txt)

  print $"Slicing ($export) → ($out)/  \(de-dup + spam filter on\)"
  print $"  topics: ($topics_path)"
  print $"  spam:   (if ($spam_paths | is-empty) { 'none' } else { $spam_paths | str join ' + ' })"
  mut total = 0
  for row in (open $topics_path | transpose topic re) {
    let re = $"\(?i\)\(($row.re)\)"
    let out_path = ($out | path join $"($row.topic).txt")
    let rows = ($msgs | where txt =~ $re | uniq-by txt)
    let lines = ($rows | each {|r| $"($r.date)\t($r.txt | str replace --all "\n" ' ')" })
    let text = (if ($lines | is-empty) { "" } else { ($lines | str join "\n") + "\n" })
    $text | save --force --raw $out_path
    let n = ($rows | length)
    print $"  (($row.topic) | fill -a left -w 14)(($n | into string) | fill -a right -w 6) msgs → ($out_path)"
    $total = $total + $n
  }
  print $"Done. ($total) matched lines across topics."
  print $"Next: point your agent at ($out)/ and run the guide-builder skill."
}
