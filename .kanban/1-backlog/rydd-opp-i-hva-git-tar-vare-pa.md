---
title: Rydd opp i hva git tar vare på
created: 2026-08-15
updated: 2026-08-15
---

## Mål

Sørge for at git tar vare på alt som ikke finnes andre steder — og ikke noe
annet. I dag stemmer ingen av delene.

**Det som haster:** `kanban.sh` og `card-template.md` ligger ikke i git.
De er skrevet for hånd til KorpsApp og finnes ingen andre steder. Går fila
tapt, er tavleverktøyet borte for godt. Git er sikkerhetskopien, og akkurat
denne fila står utenfor den.

**Det som er opprydding:** 9489 filer i `node_modules` som appen aldri
bruker, og en `.gitignore` på én linje som ikke hindrer at de blir dratt inn.

## Plan

- [ ] Steg 1 — Legg det egenskrevne verktøyet i git
  - Hele `.claude/skills/kanban/`: `kanban.sh`, `card-template.md`, `SKILL.md`
  - `plan.sh` og planlegging-`SKILL.md` er allerede i git, men `plan.sh`
    slår opp alle kort via `kanban.sh`. Repoet inneholder altså i dag et
    verktøy som ikke kan kjøre
  - Dette er eneste steg som fikser noe som er galt nå. Resten er opprydding
- [ ] Steg 2 — Legg `skills-lock.json` i git
  - Den er oppskriften som gjør de 11 Firebase-ferdighetene gjenskapbare
  - Uten den er hverken ferdighetene eller måten å hente dem på tatt vare på
- [ ] Steg 3 — Skriv en ordentlig `.gitignore`
  - Inneholder i dag én linje: `.DS_Store`
  - Skal holdes utenfor: `node_modules/`, `.firebase/` (hurtigbuffer fra
    Firebase-verktøyet, lages på nytt selv), `.agents/`, og de nedlastede
    Firebase-ferdighetene under `.claude/skills/`
  - De nedlastede ferdighetene krever unntak, siden kanban og planlegging
    skal med:
    ```
    .claude/skills/*
    !.claude/skills/kanban/
    !.claude/skills/planlegging/
    ```
  - Bekreft at `.gitignore` faktisk virker etterpå — ikke bare anta
- [ ] Steg 4 — Slett `node_modules`, `package.json` og `package-lock.json`
  - Verifisert som rester: se `## Notater`. Appen henter Firebase fra
    `gstatic.com` ([index.html:869](../../index.html)) og importerer ikke
    pakken noe sted
  - Angrepunkt: ett `npm install firebase` gjenskaper alt, hvis det skulle
    vise seg å trenges
- [ ] Steg 5 — Sjekk at en fersk kopi faktisk virker
  - Klon repoet til en midlertidig mappe og kjør `kanban.sh board` og
    `plan.sh check` derfra
  - Dette er hele poenget med kortet, så det holder ikke å anta at det virker

## Verifisering

- [ ] Fersk klon i midlertidig mappe: `kanban.sh board` og `plan.sh check`
      kjører uten feil
- [ ] `git status` viser ingenting uventet etterpå
- [ ] Testet på https://beitnes.net/Korpsapp-test — kortet rører ikke appen,
      så kravet er at den er helt uendret
- [ ] Merget til `main`

## Notater

**Bakgrunn:** funnet mens kortet om arkitekturgjennomgang ble committet
(`e0073dd`). Ikke en del av det arbeidet, og derfor eget kort.

### Avklart i grilling (2026-08-15)

**Verktøyet er verdt å ta vare på.** Går kanban og planlegging tapt, er det
et reelt tap — det er slik oversikten holdes. Merk at kortene i seg selv
allerede er i git; det er verktøyet som mangler.

**Begrunnelsen er sikkerhetskopi, ikke kloning.** Utkastet begrunnet steg 1
med at «en fersk klone skal virke». Det er en svakere begrunnelse enn den
egentlige: git *er* sikkerhetskopien, og en fil som står utenfor den er
uopprettelig hvis den forsvinner. Ingen trenger å klone noe for at det skal
gjøre vondt.

**Ny maskin er sannsynlig nok.** Ingen andre skal bruke repoet, men
framtidige Bjørn Erik på ny Mac teller. Derfor er steg 5 med.

**Skillet mellom ferdighetene er avgjort av bevis, ikke smak.**
`skills-lock.json` viser at de 11 Firebase-ferdighetene kommer fra
`firebase/agent-skills` på GitHub og kan hentes ned igjen. Kanban og
planlegging står ikke i lockfila — de er skrevet for hånd til dette
prosjektet og finnes ingen andre steder. Derfor: lockfil og egenskrevne
ferdigheter inn i git, nedlastede ferdigheter og `.agents/` utenfor.

**`node_modules` er bekreftet rester — dette var det siste åpne punktet.**
Tidsstemplene viser én økt 26. juli: `skills-lock.json` 23:01:16,
`.agents/` 23:01:29, `package.json` 23:10:50, `node_modules` 23:38:20. To av
de nyinstallerte ferdighetene ber om `npm install firebase`
(`firebase-basics/references/web_setup.md` og
`firebase-data-connect/reference/sdk_web.md`). En økt fulgte altså en
generell oppskrift, installerte pakken, og appen ble aldri lagt om til å
bruke den. Trygt å slette, og billig å angre.

**`.firebase/` er avgjort uten spørsmål:** det er Firebase-verktøyets
hurtigbuffer, lages på nytt av seg selv, og skal aldri i git uansett hvordan
den havnet der.

### Grunnlag

- 36 sporede filer i dag — repoet er lite og ryddig, og poenget er å holde
  det slik
- `deploy.yml` kjører `actions/checkout` og kopierer `./*`, altså bare det
  som er i git. `./*` treffer ikke skjulte mapper, så `.claude/`, `.kanban/`
  og `.github/` havner uansett ikke på webserveren. Blir `node_modules`
  derimot committet, blir den også lastet opp — enda en grunn til steg 3
