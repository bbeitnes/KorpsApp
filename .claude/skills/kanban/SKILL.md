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
Cards are addressed by **any unique substring** of their filename.

```bash
.claude/skills/kanban/kanban.sh board
```

```
backlog (1)
  • Fiks sortering i medlemslista [0/4] (fiks-sortering-i-medlemslista)

in-progress (1)
  • Samle farger som CSS-variabler (steg 3-6) [2/4] (samle-farger-som-css-variabler-steg-3-6)

review (0)
  —

done (1)
  • Samle farger som CSS-variabler (steg 1-2) [4/4] (samle-farger-som-css-variabler-steg-1-2)
```

`[2/4]` is checklist progress, counted from `- [ ]` / `- [x]` lines anywhere
in the card. The name in parentheses is what you pass to the other commands.

### Add a card

```bash
.claude/skills/kanban/kanban.sh new backlog "Fiks sortering i medlemslista"
```

Prints the path of the new file. It is created from
`.claude/skills/kanban/card-template.md` with `title` and `created` filled in
— **then open it and write the actual plan.** A card with an empty template
body is not a plan. Norwegian æ/ø/å are transliterated in the filename
(`ø` → `oe`), and punctuation collapses to dashes.

### Move a card

```bash
.claude/skills/kanban/kanban.sh move medlemslista in-progress
```

Uses `git mv` when the card is tracked, plain `mv` when it isn't, and stamps
`updated:` in the frontmatter with today's date. The move is left **staged,
not committed** — commit it with the code change it belongs to, so one commit
tells the whole story.

### Read a card / find it / see its history

```bash
.claude/skills/kanban/kanban.sh show medlemslista
```

```bash
.claude/skills/kanban/kanban.sh path medlemslista
```

```bash
.claude/skills/kanban/kanban.sh log medlemslista
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
  is rejected with both candidates listed; use `steg-3-6`.
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
