---
title: Nummerer kortene på tavla
created: 2026-08-16
updated: 2026-08-16
---

## Mål

Hvert kort får et fast nummer, slik at det kan omtales som «kort 7» i stedet
for `vis-avbryt-banneret-uansett-hvor-du-har-scrollet`.

Nummeret gjør to ting, og bare de to: det er en **kort referanse** man kan si
høyt, og det **viser hvor gammelt kortet er** — lavt nummer betyr gammelt, høyt
betyr nytt. Det sier ingenting om prioritet eller rekkefølge på arbeidet.

Nummeret er tre sifre med nuller foran, ligger fremst i filnavnet
(`007-adminvisning-velg-moduler-per-korps.md`), følger kortet livet ut og
gjenbrukes aldri. Å flytte et kort mellom kolonner endrer det ikke.

## Plan

- [x] Steg 1 — Etterfyll de 14 kortene som finnes i dag. Sorter på
      `created:`-dato, bryt likhet alfabetisk, og gi ut 001 og oppover på tvers
      av alle fire kolonnene. `git mv`, så historikken følger med.
- [x] Steg 2 — `cmd_new` leser høyeste nummer på tvers av kolonnene, legger til
      én og navngir den nye fila med det. Ingen frontmatter-endring; filnavnet
      er fasiten.
- [x] Steg 3 — `cmd_board` viser `#7` foran tittelen og **dropper**
      slug-parentesen bakerst. Nummeret har overtatt jobben den hadde.
- [x] Steg 4 — `find_card` tar imot et bart tall. Eksakt nummertreff prøves
      først, delstrengsøket er reserven. Uten den rekkefølgen treffer «1» både
      `001-`, `010-` … `014-` og alle slugger som har et ettall i seg.
- [x] Steg 5 — `cmd_board` tildeler nummer til kort som mangler det, og gir ut
      høyeste + 1. Bruk `move_file`, ikke `mv`, så sporede kort beholder
      historikken. Ser den flere unummererte i samme slengen, tildeles de i
      samme rekkefølge som steg 1: dato, så alfabetisk.
- [x] Steg 6 — Sjekk at `plan.sh check 7` virker. Den delegerer oppslaget til
      `kanban.sh` og bør arve det gratis — men `cmd_path` sluker feil, så dette
      må prøves, ikke antas.
- [x] Steg 7 — Oppdater `kanban/SKILL.md` og `planlegging/SKILL.md`. Begge sier
      i dag at kort adresseres med «en unik delstreng av filnavnet», og
      eksemplene må vise nummeret.

## Verifisering

<!-- Hvordan vet vi at det virker? F.eks.: pushet til `test`, sjekket på
     https://beitnes.net/Korpsapp-test på mobil og desktop. -->

- [x] `kanban.sh board` viser 14 kort, hvert med sitt eget nummer, 001–014
- [x] `kanban.sh path 7` og `kanban.sh path kundeoppsett` treffer samme kort
- [x] `plan.sh check 12` gir samme utskrift som `plan.sh check nummerer-kortene`
- [x] `kanban.sh path 1` gir kort 001 — ikke tvetydig, selv om seks andre
      filnavn har et ettall i seg. `path 99` faller gjennom og feiler riktig.
- [x] Et nytt kort laget med `kanban.sh new` fikk 015. Samme slug to ganger
      avvises.
- [x] Et kort lagt inn for hånd, uten nummer, fikk 015 neste gang `board` kjørte
- [x] `git status` viser de fire sporede kortene som ekte omdøpinger (`R`), ikke
      som slett + nyopprett
- [x] `git log --follow` finner historikken gjennom omdøpingen. Bekreftet etter
      commit `298c0f6` — kort 003 viser fortsatt hele rekka tilbake til
      «Navneetiketten er like stor på store rader». Før commit fant `--follow`
      ingenting, siden det nye filnavnet ikke fantes i noen commit ennå; det er
      kjent oppførsel, dokumentert i `kanban/SKILL.md`.
- [x] Testet på https://beitnes.net/Korpsapp-test — **verktøyendring, ikke
      appendring**: testsiden viser samme app som før. Reell testing er punktene
      over, kjørt lokalt. Se `## Notater`.
- [x] Merget til `main` — `97bbe08..ea78a8d`, ren fast-forward

## Notater

**Nummertildelingen etter steg 1** blir slik. Seks kort deler 14. august og
seks deler 16. august; de er sortert alfabetisk innbyrdes.

| # | kort | kolonne |
|---|---|---|
| 001 | arkitekturgjennomgang-struktur-tokens-og-cdn-risiko | backlog |
| 002 | fjern-unodvendige-404-er-ved-lasting-av-instrumentbilder | backlog |
| 003 | instrumenttekst-er-for-stor | done |
| 004 | radetiketten-forsvinner-bak-plassen | done |
| 005 | samle-farger-som-css-variabler | done |
| 006 | vis-avbryt-banneret-uansett-hvor-du-har-scrollet | backlog |
| 007 | flytt-kundeoppsett-ut-av-index-html | backlog |
| 008 | rydd-opp-i-hva-git-tar-vare-pa | backlog |
| 009 | gruppeinndeling-paa-ipad | backlog |
| 010 | konsertsal-paa-ipad | backlog |
| 011 | korpsoppsett-maa-kunne-brukes-fra-ipad | backlog |
| 012 | nummerer-kortene-paa-tavla | in-progress |
| 013 | nytt-utseende-designsystemet-broadsheet | done |
| 014 | rom-og-vakter-paa-ipad | backlog |

### Avklart i grillingen

**Nummeret er identitet, ikke prioritet.** De to utelukker hverandre: et
prioritetsnummer må kunne endres når kort bytter plass, og da kan man ikke
lenger si «kort 7» og mene det samme neste måned.

**Kortene i `4-done` får nummer de også.** De er de eldste, så hopper vi over
dem, får aldersrekka hull og nummeret slutter å si noe om alder.

**Dato på dagsnivå er nøyaktig nok.** `created:` lagrer bare dato, så de seks
kortene fra 14. august er uskilleligere enn som så. Å grave fram rekkefølgen
fra git-historikken ble vurdert og forkastet — poenget er «lavt = gammelt»,
ikke rettsmedisin. To av kortene er dessuten ikke committet ennå og har ingen
historikk å grave i.

**Nummeret i filnavnet, ikke i frontmatter.** Da sorterer `ls .kanban/1-backlog/`
etter alder i stedet for alfabet. Prisen er 14 `git mv` nå og litt lengre stier
for alltid.

**Derfor tre sifre med nuller foran.** Nullpolstring har ingenting med tale å
gjøre — ingen sier «kort null-null-sju». Den er der utelukkende for at `ls` skal
sortere riktig: uten den kommer `1, 10, 11, 12, 13, 14, 2, 3 …`, og da er hele
grunnen til å legge nummeret i filnavnet borte. Tre sifre rekker til 999 kort;
to hadde stoppet på 99, og det ble laget 14 kort på tre dager.

**Filnavnet er eneste fasit.** Ikke noe `nummer:`-felt i frontmatter i tillegg
— to kopier som kan komme i utakt er en feil som venter på å skje, og `git mv`
holder filnavnet ærlig av seg selv.

**`board` tildeler nummer til unummererte kort når den ser dem.** Valgt bevisst,
med én kjent bivirkning: en etternøler får høyeste + 1, altså et nummer som
sier når tavla *oppdaget* kortet, ikke når det ble laget. Alternativet — å
skyte det inn på riktig plass etter dato — ville tvinge fram omnummerering av
alt bak, og da er ikke nummeret en stabil adresse lenger. Stabil identitet
vinner. Konsekvensen er at `board` er en kommando som *skriver*, og den må
bruke `move_file` slik at sporede kort ikke mister historikken.

Dette er ikke et hypotetisk tilfelle: `adminvisning-velg-moduler-per-korps`
dukket opp i `1-backlog` midt under denne planleggingen, usporet og uten
commit som la den til.

**Testsidelinja hukes av med forklaring.** `beitnes.net/Korpsapp-test` serverer
appen; `kanban.sh` havner aldri dit, så siden ser nøyaktig lik ut før og etter.
Linja er likevel påkrevd — `plan.sh` regel 5 blokkerer kort som mangler den —
så den hukes av med en merknad om hva som faktisk ble testet. Å lære `plan.sh`
at noen kort ikke rører appen er den ryddige løsningen, men det er en endring i
`plan.sh` selv og fortjener sitt eget kort hvis verktøykort viser seg å komme
oftere. `Merget til main`-linja er ekte som den er: skriptet ligger i repoet og
merges som alt annet.

### Funn under arbeidet

**Å slette det nyeste kortet frigjør nummeret.** «Aldri gjenbruk» holder i
praksis, men ikke i koden: `max_number` teller høyeste nummer blant filene som
*finnes*, så sletter du det høyest nummererte kortet, deles nummeret ut igjen.
Det ble demonstrert utilsiktet under testingen — testkortet fikk 015, ble
slettet, og neste kort fikk 015 på nytt. I normal bruk skjer det ikke, for kort
havner i `4-done` i stedet for å bli slettet. En vanntett variant måtte lagret
telleren i en egen fil, og det er nettopp den andre fasiten vi valgte bort.
Dokumentert som gotcha i `kanban/SKILL.md` i stedet.

**`10#` foran nummeret er ikke pynt.** `008` og `009` er ugyldige oktaltall, så
`$((008))` er en feil som stopper skriptet. Alle steder nummeret regnes om fra
streng til tall bruker `$((10#$n))`.

**`while … | read` måtte bli `while … < <(…)`.** En `while`-løkke bak et rør
kjører i en subshell, og da forsvinner hver eneste økning av telleren når
løkka er ferdig. Prosessubstitusjon holder løkka i samme shell. Bash 3.2
støtter dette.

**`assign_numbers` bruker `move_file`, ikke `mv`.** `git status` bekrefter at de
fire sporede kortene i `4-done` er registrert som omdøpinger (`R`), ikke som
slett + nyopprett.

**Kort dukker opp på tavla utenfra.** `adminvisning-velg-moduler-per-korps`
kom til i `1-backlog` midt under planleggingen og var byttet ut med
`flytt-kundeoppsett-ut-av-index-html` da nummereringen kjørte — samme dato, og
fortsatt foran `rydd-opp` alfabetisk, så nummeret ble 007 uansett. Tabellen
over er rettet. Det er nettopp dette tilfellet auto-tildelingen finnes for.

**`kanban.sh log` åpner personsøker.** `cmd_log` kaller `git log` uten
`--no-pager`, så kommandoen henger i påvente av tastetrykk når den kjøres uten
terminal. Uendret her — det er eldre oppførsel og hører hjemme på sitt eget
kort.

### Filer og begrensninger

`.claude/skills/kanban/kanban.sh` (`cmd_new`, `cmd_board`, `find_card`,
`move_file`), `.claude/skills/kanban/SKILL.md`,
`.claude/skills/planlegging/SKILL.md`.

Skriptet er skrevet for bash 3.2 og BSD awk — ingen assosiative arrays, ingen
`sed -i` uten argument. Nummertildelingen må klare seg innenfor det.
