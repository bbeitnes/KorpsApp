#!/usr/bin/env bash
# Git-backed kanban board for KorpsApp.
# Columns are folders under .kanban/, cards are markdown plan files.
# Moving a card = git mv, so the board's history is the repo's history.
set -euo pipefail

# Repo root, regardless of where the script is called from.
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[ -n "$ROOT" ] || { echo "kanban: not inside a git repository" >&2; exit 1; }
BOARD="$ROOT/.kanban"

COLUMNS=(1-backlog 2-in-progress 3-review 4-done 5-rejected)
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
    5|rejected|rej|avvist)       echo 5-rejected ;;
    1-backlog|2-in-progress|3-review|4-done|5-rejected) echo "$1" ;;
    *) echo "kanban: unknown column '${1:-}' (use backlog|in-progress|review|done|rejected)" >&2; return 1 ;;
  esac
}

slugify() {
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -e 's/æ/ae/g; s/ø/oe/g; s/å/aa/g' \
    | sed -e 's/[^a-z0-9]\{1,\}/-/g' -e 's/^-//' -e 's/-$//'
}

# A card's number, from its filename prefix. "" when it hasn't got one.
# The filename is the only place the number lives — no frontmatter copy to
# drift out of sync.
card_number() {
  local b; b="$(basename "$1")"
  case "$b" in
    [0-9][0-9][0-9]-*) printf '%s' "${b%%-*}" ;;
    *)                 printf '' ;;
  esac
}

# Highest number in use across every column, or 0 on an unnumbered board.
# Numbers are never reused, so this only ever goes up.
max_number() {
  local f n max=0
  for f in "$BOARD"/*/*.md; do
    [ -e "$f" ] || continue
    n="$(card_number "$f")"
    [ -n "$n" ] || continue
    n=$((10#$n))            # 10# or 008/009 read as bad octal
    [ "$n" -gt "$max" ] && max="$n"
  done
  printf '%d' "$max"
}

# Give a number to every card that lacks one, oldest first. Ties inside a day
# break alphabetically — created: only records the date, and day-level
# accuracy is all the number promises.
assign_numbers() {
  local f d b list next dst
  list=""
  for f in "$BOARD"/*/*.md; do
    [ -e "$f" ] || continue
    [ -n "$(card_number "$f")" ] && continue
    d="$(grep -m1 '^created: ' "$f" | sed 's/^created: //' || true)"
    [ -n "$d" ] || d="9999-99-99"   # undated sorts last
    list="$list$d	$(basename "$f")	$f
"
  done
  [ -n "$list" ] || return 0
  next=$(( $(max_number) + 1 ))
  # Process substitution, not a pipe: a piped `while` runs in a subshell and
  # every increment of $next would be thrown away.
  while IFS='	' read -r d b f; do
    [ -n "$f" ] || continue
    dst="$(dirname "$f")/$(printf '%03d' "$next")-$b"
    move_file "$f" "$dst"
    next=$((next+1))
  done < <(printf '%s' "$list" | LC_ALL=C sort)
}

# Find a card by number or by partial name across all columns. Prints its path.
find_card() {
  local q="$1" matches
  # A bare number is an exact lookup, and must be tried first: as a substring
  # "1" would also hit 001-, 010-…014- and every slug containing a 1.
  case "$q" in
    ''|*[!0-9]*) ;;
    *)
      matches="$(find "$BOARD" -name "$(printf '%03d' "$((10#$q))")-*.md" -type f 2>/dev/null || true)"
      if [ -n "$matches" ]; then printf '%s' "$matches"; return 0; fi
      ;;
  esac
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
  local col dir count f title prog num
  # Stragglers added by hand get a number on sight. This makes `board` a
  # command that writes — hence move_file, so tracked cards keep their history.
  assign_numbers
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
      num="$(card_number "$f")"
      # Spoken, not typed: "#7", never "#007".
      [ -n "$num" ] && num="$((10#$num))" || num="—"
      if [ -n "$prog" ]; then
        printf '  • \033[2m#%-3s\033[0m %s \033[2m[%s]\033[0m\n' "$num" "$title" "$prog"
      else
        printf '  • \033[2m#%-3s\033[0m %s\n' "$num" "$title"
      fi
    done
  done
  printf '\n'
}

cmd_new() {
  local col slug file title num dupe
  col="$(resolve_column "${1:-backlog}")"
  shift || true
  title="$*"
  [ -n "$title" ] || { echo "kanban: new <column> <title>" >&2; exit 1; }
  slug="$(slugify "$title")"
  # The number is always fresh, so only the slug can collide.
  dupe="$(find "$BOARD" -name "*-$slug.md" -type f 2>/dev/null || true)"
  [ -n "$dupe" ] && { echo "kanban: $dupe already exists" >&2; exit 1; }
  num="$(printf '%03d' "$(( $(max_number) + 1 ))")"
  file="$BOARD/$col/$num-$slug.md"
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
