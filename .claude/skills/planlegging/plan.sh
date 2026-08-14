#!/usr/bin/env bash
# Planning gate for KorpsApp kanban cards.
#
# kanban.sh moves cards between columns; it does not care what is written in
# them. This script does. It reads a card and answers one question: is this a
# real plan, or is it still the template with a title on top?
#
# Written for bash 3.2 / BSD awk (macOS default) — no associative arrays,
# no GNU-only flags.
set -uo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[ -n "$ROOT" ] || { echo "plan: not inside a git repository" >&2; exit 1; }
BOARD="$ROOT/.kanban"
KANBAN="$ROOT/.claude/skills/kanban/kanban.sh"

TEST_URL="https://beitnes.net/Korpsapp-test"

# --- helpers ---------------------------------------------------------------

# Reuse kanban.sh's matcher so both tools address cards identically.
# `kanban.sh path` exits 0 with empty output when nothing matches (its cmd_path
# wraps the lookup in an echo, which swallows the failure), so trusting its exit
# status alone lets an empty path through and every check below then "fails"
# against a file that does not exist. Verify we got a real file.
# kanban's own stderr already names the problem — and lists the candidates when
# a substring is ambiguous — so don't print a second, vaguer message over it.
find_card() {
  local p
  p="$("$KANBAN" path "$1")" || return 1
  [ -n "$p" ] && [ -f "$p" ] || return 1
  printf '%s' "$p"
}

# Which column a card file sits in, e.g. "1-backlog".
column_of() { basename "$(dirname "$1")"; }

# Print the body of one "## <name>" section, up to the next "## " heading.
section() {
  awk -v want="## $2" '
    $0 == want      { inside = 1; next }
    /^## /          { inside = 0 }
    inside          { print }
  ' "$1"
}

# A section counts as written only if it has a line that is not blank and not
# part of an HTML comment. The template ships every section pre-filled with
# comments, so "has content" must ignore them.
section_is_empty() {
  local body real
  body="$(section "$1" "$2")"
  real="$(printf '%s\n' "$body" \
    | awk '/<!--/ { skip = 1 } !skip && NF { print } /-->/ { skip = 0 }')"
  [ -z "$real" ]
}

count_matches() { grep -c "$@" 2>/dev/null || true; }

# --- the lint --------------------------------------------------------------

BLOCKERS=0
WARNINGS=0

say_block() { BLOCKERS=$((BLOCKERS + 1)); printf '  \033[31mBLOKKERER\033[0m  %s\n' "$1"; }
say_warn()  { WARNINGS=$((WARNINGS + 1)); printf '  \033[33mÅPENT\033[0m      %s\n' "$1"; }

lint_card() {
  local f="$1" col plan_body ticks placeholders
  col="$(column_of "$f")"

  # 1. Template placeholders that `new` should have replaced.
  placeholders="$(printf '%s' "$(count_matches -e '{{TITLE}}' -e '{{DATE}}' "$f")")"
  [ "${placeholders:-0}" -gt 0 ] && \
    say_block "Malen er ikke fylt ut — {{TITLE}}/{{DATE}} står igjen."

  # 2. A goal you can hold someone to.
  if section_is_empty "$f" "Mål"; then
    say_block "«## Mål» er tom — bare malkommentaren står igjen."
  fi

  # 3. The template's own example steps, still there.
  plan_body="$(section "$f" "Plan")"
  if printf '%s' "$plan_body" | grep -q -e 'Første steg' -e 'Andre steg'; then
    say_block "«## Plan» inneholder malens eksempelsteg («Første steg»)."
  fi

  # 4. A plan is more than one step.
  ticks="$(printf '%s\n' "$plan_body" | count_matches '^[[:space:]]*- \[[ xX]\]')"
  if [ "${ticks:-0}" -lt 2 ]; then
    say_block "«## Plan» har $ticks avkryssingspunkt — en plan trenger minst 2."
  fi

  # 5. The two verification lines the test-branch workflow depends on.
  if ! section "$f" "Verifisering" | grep -qF "$TEST_URL"; then
    say_block "«## Verifisering» mangler linja om $TEST_URL."
  fi
  if ! section "$f" "Verifisering" | grep -qi 'merget til'; then
    say_block "«## Verifisering» mangler linja «Merget til \`main\`»."
  fi

  # 6. Unresolved questions. Not a blocker in backlog — that is exactly what a
  #    grilling is for — but a blocker once the card claims to be in progress.
  #    A `grep | while` would put the loop in a subshell and lose every
  #    say_warn increment, so collect first and loop over the string.
  local hits
  hits="$(grep -n -e 'Uavklart' -e 'TODO' -e '???' -e '⚠️' "$f" 2>/dev/null || true)"
  if [ -n "$hits" ]; then
    while IFS= read -r hit; do
      [ -n "$hit" ] || continue
      if [ "$col" = "1-backlog" ]; then
        say_warn "linje ${hit%%:*}: uavklart punkt — ta det i en grilling."
      else
        say_block "linje ${hit%%:*}: uavklart punkt i kolonnen «${col#*-}»."
      fi
    done <<< "$hits"
  fi

  # 7. A finished card with no notes has thrown away the record.
  case "$col" in
    3-review|4-done)
      section_is_empty "$f" "Notater" && \
        say_warn "«## Notater» er tom, men kortet er i «${col#*-}»."
      ;;
  esac
}

# --- commands --------------------------------------------------------------

cmd_check() {
  local f title
  f="$(find_card "${1:?plan: check <kort>}")" || exit 1
  title="$(grep -m1 '^title: ' "$f" | sed 's/^title: //')"
  printf '\n\033[1m%s\033[0m \033[2m(%s)\033[0m\n' "$title" "$(column_of "$f")"
  lint_card "$f"
  if [ "$BLOCKERS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
    printf '  \033[32mKLAR\033[0m       Ingen mangler.\n\n'
    return 0
  fi
  printf '\n  %d blokkerende, %d åpne.\n\n' "$BLOCKERS" "$WARNINGS"
  [ "$BLOCKERS" -eq 0 ]
}

cmd_open() {
  # Board-wide sweep: which cards are not ready, and why.
  local f col title bad=0 tmp
  tmp="$(mktemp)"
  for col in 1-backlog 2-in-progress 3-review 4-done; do
    for f in "$BOARD/$col"/*.md; do
      [ -e "$f" ] || continue
      BLOCKERS=0; WARNINGS=0
      # Redirection, not "$(...)" — a subshell would discard the counters.
      lint_card "$f" > "$tmp"
      [ "$BLOCKERS" -eq 0 ] && [ "$WARNINGS" -eq 0 ] && continue
      title="$(grep -m1 '^title: ' "$f" | sed 's/^title: //')"
      printf '\n\033[1m%s\033[0m \033[2m(%s / %s)\033[0m\n' \
        "$title" "${col#*-}" "$(basename "$f" .md)"
      cat "$tmp"
      bad=$((bad + 1))
    done
  done
  rm -f "$tmp"
  [ "$bad" -eq 0 ] && printf '\nAlle kort er ferdig planlagt.\n\n' || printf '\n%d kort trenger arbeid.\n\n' "$bad"
  return 0
}

cmd_brief() {
  # The compact summary to bring into a /grill-me session. Deliberately short:
  # goal, steps, and every loose end the card admits to.
  local f title col
  f="$(find_card "${1:?plan: brief <kort>}")" || exit 1
  title="$(grep -m1 '^title: ' "$f" | sed 's/^title: //')"
  col="$(column_of "$f")"

  printf '# Grillingsbrief: %s\n' "$title"
  printf '_Kort: %s (%s)_\n\n' "$(basename "$f" .md)" "${col#*-}"

  printf '## Mål\n'
  section "$f" "Mål" | sed '/^[[:space:]]*$/d' | grep -v '^[[:space:]]*<!--' | grep -v -- '-->'
  printf '\n## Foreslåtte steg\n'
  section "$f" "Plan" | grep '^[[:space:]]*- \[' || printf '(ingen)\n'

  printf '\n## Uavklart\n'
  if grep -n -e 'Uavklart' -e 'TODO' -e '???' -e '⚠️' "$f" >/dev/null 2>&1; then
    grep -n -e 'Uavklart' -e 'TODO' -e '???' -e '⚠️' "$f" \
      | sed 's/^\([0-9]*\):[[:space:]]*/  linje \1: /'
  else
    printf '  (kortet oppgir ingen — så finn dem i grillingen)\n'
  fi
  printf '\n---\nKjør `/grill-me` og lim inn dette. Brief-en er inndata til\n'
  printf 'intervjuet, ikke en erstatning for det.\n'
}

case "${1:-}" in
  check) shift; cmd_check "$@" ;;
  open)  shift; cmd_open "$@" ;;
  brief) shift; cmd_brief "$@" ;;
  *) echo "usage: plan.sh [check <kort>|open|brief <kort>]" >&2; exit 1 ;;
esac
