---
name: planlegging
description: Plan a piece of work for KorpsApp before writing any code — draft the kanban card, lint it, and get it grilled. Use when asked to plan or planlegge something, write a plan, think through a task, prepare a card before starting, sharpen or pressure-test a plan, or when work is about to start on something that has no plan yet.
---

# Planlegging

Turning a request into a card that survives contact with the code. The
[kanban](../kanban/SKILL.md) skill owns *where* a card sits; this one owns
*whether it is any good* before work starts.

The gate is a real one: a plan leaves `1-backlog` only when every open question
in it has been answered, and the way questions get found is a
**`/grill-me` interview that the user must run themselves** — see
[The grilling](#the-grilling), it is the one step you cannot do for them.

All paths below are relative to the repo root.

## Driver

`.claude/skills/planlegging/plan.sh` — works from any directory inside the
repo. Cards are addressed by **any unique substring** of their filename,
exactly like `kanban.sh`.

| command | what it does |
|---|---|
| `plan.sh check <kort>` | Lint one card. Exit 1 if something blocks. |
| `plan.sh open` | Sweep the whole board for cards that aren't ready. |
| `plan.sh brief <kort>` | Print the compact brief to bring into a grilling. |

```bash
.claude/skills/planlegging/plan.sh check instrumenttekst
```

```
Instrumenttekst er for stor (1-backlog)
  ÅPENT      linje 12: uavklart punkt — ta det i en grilling.

  0 blokkerende, 1 åpne.
```

Two severities, and the difference is the whole point:

- **BLOKKERER** — the card is not a plan yet. Exit 1. Fix it before moving on.
- **ÅPENT** — a loose end the card admits to. Fine in `1-backlog`, because
  that's what the grilling is for. **The same line blocks in every other
  column** — an unanswered question in `2-in-progress` means work started on
  a guess.

## The workflow

### 1. Is it already on the board?

```bash
.claude/skills/kanban/kanban.sh board
```

If the work is already a card, `check` it and pick up from step 3.

### 2. Draft the card

```bash
.claude/skills/kanban/kanban.sh new backlog "Fiks sortering i medlemslista"
```

It prints the path of the new file — and that file is still the bare template,
so `check` on it fails immediately with `2 blokkerende`. That is the starting
position, not a problem.

Then **open the file and write the plan** — in Norwegian, like every other
card. `## Mål` is one to three sentences on what is different when this is
done. `## Plan` is the steps. Leave the two `## Verifisering` lines alone;
they encode the test-branch workflow.

Write down what you *don't* know, explicitly, as `Uavklart: …`. Those lines
are the raw material for the next step — a card that pretends to have no open
questions just moves the guessing into the code.

### 3. Lint it

The examples from here on use `instrumenttekst-er-for-stor`, a card already in
`1-backlog` that is mid-way through this workflow — drafted, with one open
question still waiting on a grilling.

```bash
.claude/skills/planlegging/plan.sh check instrumenttekst
```

Clear every **BLOKKERER**. Leave the **ÅPENT** items — you are about to use
them.

### 4. The grilling

```bash
.claude/skills/planlegging/plan.sh brief instrumenttekst
```

This prints the goal, the steps, and every open question the card admits to.

**Now stop and hand it to the user.** Say roughly:

> The plan is drafted and the open questions are listed above. Run `/grill-me`
> and bring this brief into it — I can't start that session for you.

You cannot do this step yourself, and you must not work around it. `grill-me`
is marked `disable-model-invocation: true`; calling it returns:

```
Skill grill-me cannot be used with Skill tool due to disable-model-invocation.
Ask the user to run /grill-me themselves — it cannot be invoked via the Skill
tool. Do not replicate this skill's workflow by other means — it is reserved
for explicit user invocation.
```

Interviewing the user yourself instead is exactly the "by other means" that
error rules out. Draft, hand over, wait.

### 5. Fold the answers back in

After the grilling, edit the card: rewrite `## Mål` if the goal moved, redo
`## Plan` with what the interview actually established, and **delete every
`Uavklart:` line by answering it** — record the answer in `## Notater`, with
the reasoning, not just the verdict.

### 6. Gate, then start

```bash
.claude/skills/planlegging/plan.sh check instrumenttekst
```

Move only on `KLAR` — no blockers *and* no open items:

```bash
.claude/skills/kanban/kanban.sh move instrumenttekst in-progress
```

From here the [kanban](../kanban/SKILL.md) skill takes over: `review` when it's
pushed to `test`, `done` when it's merged to `main`.

## What the linter checks

| # | Rule | Severity |
|---|---|---|
| 1 | `{{TITLE}}`/`{{DATE}}` placeholders still in the file | blocks |
| 2 | `## Mål` has nothing but the template comment | blocks |
| 3 | `## Plan` still contains «Første steg»/«Andre steg» | blocks |
| 4 | `## Plan` has fewer than 2 checklist items | blocks |
| 5 | `## Verifisering` lost the `beitnes.net/Korpsapp-test` line | blocks |
| 6 | `## Verifisering` lost the «Merget til `main`» line | blocks |
| 7 | `Uavklart` / `TODO` / `???` / `⚠️` anywhere | open in backlog, **blocks elsewhere** |
| 8 | `## Notater` empty on a card in `review`/`done` | open |

Rule 8 is deliberately not a blocker — but a card that reaches `done` with no
notes has thrown away the only durable record of what was actually learned.
The `4-done` card `samle-farger-som-css-variabler` is the standard to match.

## Gotchas

- **`/grilling` does not exist on this machine.** The `grill-me` SKILL.md body
  is one line — "Run a `/grilling` session" — and there is no such command in
  `~/.claude/commands/`, in any installed plugin, or in the bundled skills.
  The user typing `/grill-me` still works; it just loads that one line, and the
  interview is improvised from it. So **the brief is doing real work** — it is
  the only structured input the session gets. Don't skimp on it.
- **A blank template already passes rules 5 and 6.** The card template ships
  both `## Verifisering` lines, so a freshly created, entirely empty card
  reports exactly `2 blokkerende` (Mål and Plan). Read that as "still empty,"
  not "mostly fine."
- **`kanban.sh path` exits 0 with empty output when nothing matches** — its
  `cmd_path` wraps the lookup in an `echo`, which swallows the failure. If you
  call it directly in a script, test the output is a real file; `plan.sh` does
  this for you.
- **`brief` drops indented sub-bullets** under a checklist item. It prints
  lines matching `- [`, so nested detail under a step doesn't survive into the
  brief. Read the full card with `kanban.sh show` when the nesting matters.
- **The ANSI codes render as `[1m` when piped.** Same as `kanban.sh`. The text
  is still readable; ignore the escapes.
- **Written for bash 3.2 and BSD awk** — the macOS defaults. No associative
  arrays, no `sed -i` without an argument, no GNU-only flags. Keep it that way
  if you edit it.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `kanban: no card matching 'x'` | `plan.sh` delegates matching to `kanban.sh`. Run `kanban.sh board` and copy the name from the parentheses. |
| `kanban: 'x' is ambiguous:` + a list | Pass a longer substring; the candidates are printed for you. |
| `check` says `KLAR` but the plan feels thin | The linter checks *structure*, not judgment. It cannot tell whether `## Mål` is honest. That's what the grilling is for. |
| An `ÅPENT` item you can't resolve | It's a real unknown — say so in `## Notater` and leave the card in `1-backlog`. Blocking in `2-in-progress` is the intended behaviour, not something to edit around. |
| `plan.sh: Permission denied` | `chmod +x .claude/skills/planlegging/plan.sh` |
