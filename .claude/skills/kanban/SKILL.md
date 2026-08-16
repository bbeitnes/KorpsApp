---
name: kanban
description: Git-backed kanban board for KorpsApp. Columns are folders under .kanban/, cards are markdown plan files. Use when asked to show the board, see what's in progress or what's next, add a task/plan/card, move something to in-progress/review/done, or when starting or finishing a piece of work that should be tracked.
---

# Kanban board

Planning lives in the repo, not in a separate tool. Each task is one markdown
file with a plan and a checklist; each status is a folder. Moving a card is
`git mv`, so the board's history *is* the repo's history — `git log --follow`
on a card shows when it started and when it finished.

```
.kanban/
  1-backlog/       ← ideas and queued work
  2-in-progress/   ← being worked on now
  3-review/        ← pushed to `test`, awaiting verification on
                     https://beitnes.net/Korpsapp-test
  4-done/          ← merged to `main`, kept as a record
```

All paths below are relative to the repo root.

## Driver

`.claude/skills/kanban/kanban.sh` — works from any directory inside the repo
(it resolves the root with `git rev-parse`). Column names accept short
aliases: `backlog`/`b`, `in-progress`/`wip`, `review`/`r`, `done`/`d`.
Cards are addressed by **their number** — `move 7 review` — or by **any unique
substring** of their filename. The number is tried first, so a bare `1` means
card 1 and never the six other cards with a `1` somewhere in the name.

```bash
.claude/skills/kanban/kanban.sh board
```

```
backlog (1)
  • #16  Fiks sortering i medlemslista [0/4]

in-progress (1)
  • #5   Samle farger som CSS-variabler (steg 3-6) [2/4]

review (0)
  —

done (1)
  • #3   Samle farger som CSS-variabler (steg 1-2) [4/4]
```

`[2/4]` is checklist progress, counted from `- [ ]` / `- [x]` lines anywhere
in the card.

### The number

Every card carries a three-digit number at the front of its filename
(`007-flytt-kundeoppsett-ut-av-index-html.md`). The filename is the only place
it lives — there is no frontmatter copy to drift out of sync.

It does exactly two jobs: it is a **short handle you can say out loud** ("card
7"), and it **shows how old the card is** — low is old, high is recent. It says
nothing about priority, and it never changes when a card moves between columns.

Numbers are handed out in creation order, `created:` date first and
alphabetically within a day, because the date is stored to the day and cards
made on the same day have no recorded order among them. The zero-padding is
there purely so `ls` sorts correctly; unpadded you get `1, 10, 11, 2`. Nobody
says "card zero-zero-seven".

A card added by hand, without `kanban.sh new`, is numbered the next time
`board` runs — which makes `board` a command that *writes*. It uses `git mv`
for tracked cards, so history survives. A straggler gets the highest number
plus one, so its number records when the board noticed it rather than when it
was written; slotting it in by date would mean renumbering everything after it,
and then card 7 stops meaning card 7 forever.

### Add a card

```bash
.claude/skills/kanban/kanban.sh new backlog "Fiks sortering i medlemslista"
```

Prints the path of the new file — `016-fiks-sortering-i-medlemslista.md`, with
the next free number already on the front. It is created from
`.claude/skills/kanban/card-template.md` with `title` and `created` filled in
— **then open it and write the actual plan.** A card with an empty template
body is not a plan. Norwegian æ/ø/å are transliterated in the filename
(`ø` → `oe`), and punctuation collapses to dashes.

### Move a card

```bash
.claude/skills/kanban/kanban.sh move 16 in-progress
```

Uses `git mv` when the card is tracked, plain `mv` when it isn't, and stamps
`updated:` in the frontmatter with today's date. The move is left **staged,
not committed** — commit it with the code change it belongs to, so one commit
tells the whole story.

### Read a card / find it / see its history

```bash
.claude/skills/kanban/kanban.sh show 16
```

```bash
.claude/skills/kanban/kanban.sh path 16
```

```bash
.claude/skills/kanban/kanban.sh log 16
```

`log` is `git log --follow`, so it tracks the card through every column it has
passed:

```
2026-08-14 Ferdig: Test kort
2026-08-14 Start: Test kort
2026-08-14 Legg til kort: Test kort
```

## How to use it during work

- **Starting something:** `board` first. If the work isn't on the board, `new`
  it and write the plan before touching code. Then `move … in-progress`.
- **Pushing to `test`:** `move … review`. The card stays there until it's been
  checked on https://beitnes.net/Korpsapp-test.
- **Merging to `main`:** `move … done`. Tick the remaining checkboxes; leave
  the notes section as-is — that's the record of what actually happened.
- Keep **one** card in `2-in-progress` unless there's a reason not to.

## Gotchas

- **`move` stages, it doesn't commit.** `git status` will show a rename you
  didn't ask git to record. That's deliberate — pair it with the code commit.
  If you only want the board change, `git commit .kanban`.
- **Ambiguous substrings fail loudly rather than guessing.** Two cards named
  `…css-variabler-steg-1-2` and `…css-variabler-steg-3-6` mean `css-variabler`
  is rejected with both candidates listed; use `steg-3-6`, or just the number.
- **Deleting the newest card frees its number.** The next number is «highest in
  use, plus one», counted from the files that exist — so numbers are never
  reused in normal work, where cards end in `4-done` rather than being deleted,
  but deleting the highest-numbered card does hand its number out again.
- **`log` on an uncommitted card prints nothing.** `--follow` needs at least
  one commit touching the file. Not an error — the card just has no history yet.
- **`.gitkeep` files hold the empty columns.** Don't delete them, or an empty
  column disappears from a fresh clone.
- **Cards are for plans, not for the app.** `.kanban/` is developer-facing and
  ships with the repo; nothing in `index.html` reads it.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `kanban: not inside a git repository` | You're outside the repo. `cd` into `KorpsApp/`. |
| `kanban: unknown column 'testing'` | Only `backlog`, `in-progress`, `review`, `done` (plus aliases) exist. |
| `kanban: no card matching 'x'` | Run `board` and copy the name from the parentheses. |
| `kanban: … already exists` | A card with that slug is already on the board — `move` it instead of creating a duplicate. |
| Board renders with literal `[1m` escape codes | Output is being piped somewhere that strips TTY handling; pipe through `cat -v` to confirm, or just read the filenames. |
