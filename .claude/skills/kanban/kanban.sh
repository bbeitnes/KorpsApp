#!/usr/bin/env bash
# Git-backed kanban board for KorpsApp.
# Columns are folders under .kanban/, cards are markdown plan files.
# Moving a card = git mv, so the board's history is the repo's history.
set -euo pipefail

# Repo root, regardless of where the script is called from.
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[ -n "$ROOT" ] || { echo "kanban: not inside a git repository" >&2; exit 1; }
BOARD="$ROOT/.kanban"

COLUMNS=(1-backlog 2-in-progress 3-review 4-done)
TODAY="$(date +%F)"

# --- helpers ---------------------------------------------------------------

# Accept short aliases: backlog, wip, in-progress, review, done, or the
# numbered folder name itself.
resolve_column() {
  case "${1:-}" in
    1|backlog|b)                 echo 1-backlog ;;
    2|in-progress|wip|progress|p) echo 2-in-progress ;;
    3|review|r|test)             echo 3-review ;;
    4|done|d|ferdig)             echo 4-done ;;
    1-backlog|2-in-progress|3-review|4-done) echo "$1" ;;
    *) echo "kanban: unknown column '${1:-}' (use backlog|in-progress|review|done)" >&2; return 1 ;;
  esac
}

slugify() {
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -e 's/æ/ae/g; s/ø/oe/g; s/å/aa/g' \
    | sed -e 's/[^a-z0-9]\{1,\}/-/g' -e 's/^-//' -e 's/-$//'
}

# Find a card by partial name across all columns. Prints its path.
find_card() {
  local q="$1" matches
  matches="$(find "$BOARD" -name '*.md' -type f 2>/dev/null | grep -i -- "$q" || true)"
  local n; n="$(printf '%s' "$matches" | grep -c . || true)"
  if [ "$n" -eq 0 ]; then
    echo "kanban: no card matching '$q'" >&2; return 1
  elif [ "$n" -gt 1 ]; then
    echo "kanban: '$q' is ambiguous:" >&2
    printf '%s\n' "$matches" | sed "s|$BOARD/|  |" >&2
    return 1
  fi
  printf '%s' "$matches"
}

# "3/7" checklist progress for a card, or "" if it has no checklist.
progress() {
  local f="$1" done_n total_n
  done_n="$(grep -c '^[[:space:]]*- \[[xX]\]' "$f" || true)"
  total_n="$(grep -c '^[[:space:]]*- \[[ xX]\]' "$f" || true)"
  [ "$total_n" -gt 0 ] && printf '%s/%s' "$done_n" "$total_n" || printf ''
}

# Rewrite an existing frontmatter key in place (portable: no sed -i).
set_field() {
  local f="$1" key="$2" val="$3" tmp
  tmp="$(mktemp)"
  awk -v k="$key" -v v="$val" '
    NR==1 && $0=="---" { infm=1; print; next }
    infm && $0=="---"  { infm=0; print; next }
    infm && $0 ~ "^"k": " { print k": "v; next }
    { print }
  ' "$f" > "$tmp"
  mv "$tmp" "$f"
}

# git mv when tracked, plain mv when not.
move_file() {
  local src="$1" dst="$2"
  if git -C "$ROOT" ls-files --error-unmatch "$src" >/dev/null 2>&1; then
    git -C "$ROOT" mv "$src" "$dst"
  else
    mv "$src" "$dst"
  fi
}

# --- commands --------------------------------------------------------------

cmd_board() {
  local col dir count f title prog
  for col in "${COLUMNS[@]}"; do
    dir="$BOARD/$col"
    count=0
    for f in "$dir"/*.md; do [ -e "$f" ] && count=$((count+1)); done
    printf '\n\033[1m%s\033[0m (%d)\n' "${col#*-}" "$count"
    if [ "$count" -eq 0 ]; then
      printf '  \033[2m—\033[0m\n'
      continue
    fi
    for f in "$dir"/*.md; do
      [ -e "$f" ] || continue
      title="$(grep -m1 '^title: ' "$f" | sed 's/^title: //' || true)"
      [ -n "$title" ] || title="$(basename "$f" .md)"
      prog="$(progress "$f")"
      if [ -n "$prog" ]; then
        printf '  • %s \033[2m[%s] (%s)\033[0m\n' "$title" "$prog" "$(basename "$f" .md)"
      else
        printf '  • %s \033[2m(%s)\033[0m\n' "$title" "$(basename "$f" .md)"
      fi
    done
  done
  printf '\n'
}

cmd_new() {
  local col slug file title
  col="$(resolve_column "${1:-backlog}")"
  shift || true
  title="$*"
  [ -n "$title" ] || { echo "kanban: new <column> <title>" >&2; exit 1; }
  slug="$(slugify "$title")"
  file="$BOARD/$col/$slug.md"
  [ -e "$file" ] && { echo "kanban: $file already exists" >&2; exit 1; }
  sed -e "s|{{TITLE}}|$title|" -e "s|{{DATE}}|$TODAY|" \
      "$ROOT/.claude/skills/kanban/card-template.md" > "$file"
  echo "$file"
}

cmd_move() {
  local src dst col
  src="$(find_card "${1:?kanban: move <card> <column>}")"
  col="$(resolve_column "${2:?kanban: move <card> <column>}")"
  dst="$BOARD/$col/$(basename "$src")"
  [ "$src" = "$dst" ] && { echo "kanban: already in ${col#*-}"; exit 0; }
  move_file "$src" "$dst"
  set_field "$dst" updated "$TODAY"
  echo "${col#*-}: $(basename "$dst" .md)"
}

cmd_show() { cat "$(find_card "${1:?kanban: show <card>}")"; }
cmd_path() { echo "$(find_card "${1:?kanban: path <card>}")"; }

cmd_log() {
  # Where a card has been: every commit that touched it, renames followed.
  git -C "$ROOT" log --follow --format='%ad %s' --date=short \
    -- "$(find_card "${1:?kanban: log <card>}")"
}

case "${1:-board}" in
  board|"")       cmd_board ;;
  new)   shift;   cmd_new "$@" ;;
  move|mv) shift; cmd_move "$@" ;;
  show)  shift;   cmd_show "$@" ;;
  path)  shift;   cmd_path "$@" ;;
  log)   shift;   cmd_log "$@" ;;
  *) echo "usage: kanban.sh [board|new <col> <title>|move <card> <col>|show <card>|path <card>|log <card>]" >&2; exit 1 ;;
esac
