---
title: Arkitekturgjennomgang: struktur, tokens og CDN-risiko
created: 2026-08-14
updated: 2026-08-18
---

## Mål

Gå gjennom hvordan appen er bygget opp, med ett spørsmål som målestokk:
**hva gjør neste endring dyr?** To ting peker seg ut — at all koden ligger i
én fil på 4912 linjer, og at navnene på farger og mål ikke lenger stemmer
etter Broadsheet-redesignet. I tillegg skal én konkret risiko vurderes:
appens utseende hentes fra en server utenfor vår kontroll.

**Dette kortet handler ikke om fart.** Grillingen slo fast at det ikke finnes
noe fartsproblem å løse: en håndfull brukere, alltid på godt nett, og
lastetiden oppleves som helt grei. Måling av lastetid, skrifter og
Firestore-bruk er derfor bevisst holdt utenfor.

**Kortet endrer ikke appen.** Det leverer en rapport i `## Notater`, og hvert
funn som er verdt å gjøre blir sitt eget kort i backlog. Samme framgangsmåte
som fargekortet, som endte med tre nye kort.

## Plan

- [x] Steg 1 — Kartlegg filstrukturen
  - 4912 linjer i én fil: to script-blokker på ca. 1100 og 2900 linjer, én
    CSS-blokk på ca. 370, pluss to små `<style>`-blokker inne i JavaScript
    ([index.html:4601](../../index.html), [index.html:4676](../../index.html))
  - Tegn opp hvor hver av de fem modulene begynner og slutter:
    Billettfordeling, Korpsoppsett, Romfordeling, Vaktlister, Gruppeinndeling
  - Let etter samme logikk skrevet flere ganger — det er dette som koster når
    en ny funksjon skal inn i en modul som finnes fra før
  - Let etter død kode. Merk: fargekortet mistenkte død kode og tok feil, så
    her må hver mistanke bekreftes før den skrives ned som funn
- [x] Steg 2 — Gjennomgå token-taksonomien
  - Tre navnelag oppå hverandre: systemtokens (`--color-*` m.fl., 48 definert), appens
    palett (`--farge-*`, 44 definert) og Tailwind-klassene i markupen
  - **Klassenavnene lyver:** `bg-indigo-600` maler cyan, `text-red-500` maler
    magenta. 292 slike bruk. Den som leser koden blir aktivt villedet
  - Vurder om mellomlaget `--farge-*` fortsatt gjør en jobb, eller om det nå
    bare er et ekstra ledd å slå opp i
  - 45 `style="..."` rett i markupen omgår systemet helt — kartlegg hva de
    gjør og om de burde vært tokens
  - Finnes det tokens for avstand og typografi som burde vært brukt, men ikke
    er det? `--space-*` og `--font-*` er definert; sjekk hvor mye de brukes
  - Ta med de to «avvikerne» fra fargekortet
    (`--farge-ok-bakgrunn-avvik`, `--farge-ok-tekst-avvik`)
- [x] Steg 3 — Vurder byggesteg som felles løsning
  - Tailwind hentes i dag fra `https://cdn.tailwindcss.com`
    ([index.html:16](../../index.html)) — **uten versjonsnummer**. Det er
    Tailwinds utviklingsversjon, som selv sier den ikke er ment for drift
  - 545 `class=`-attributter og 114 ulike klasser avhenger av den. Faller
    adressen bort eller endrer innhold, vises appen som ustylet tekst for
    alle, på en dag ingenting er endret
  - Service workeren ([sw.js](../../sw.js)) cacher adressen, så
    gjengangere er delvis beskyttet — men ikke førstegangsbesøkende. Vurder
    hvor mye den beskyttelsen egentlig er verdt
  - Et byggesteg løser tre ting samtidig: Tailwind bakes permanent inn,
    kildekoden kan splittes i flere lesbare filer, og serveren får fortsatt
    én selvstendig fil. Vurder om det holder det det lover
  - Merk: `deploy.yml` kopierer `./*` med SFTP uten bygg i dag. Et byggesteg
    må inn her, og det er denne filen som må endres
- [x] Steg 4 — Skriv rapporten i `## Notater`
  - Hvert funn med: hva det koster i dag, hva det koster å fikse, og hvor
    stor risikoen er for at utseendet endrer seg
  - Sortert etter nytte delt på risiko, ikke etter hvor interessant det er
- [x] Steg 5 — Opprett oppfølgingskort i backlog for funnene som er verdt å gjøre

## Verifisering

- [x] Rapporten er lesbar for en ikke-teknisk leser: hvert funn forklarer
      konsekvensen i praksis, ikke bare hva som er teknisk galt
- [x] Hvert funn om død kode eller duplisert logikk er bekreftet, ikke antatt
- [x] Testet på https://beitnes.net/Korpsapp-test — kortet endrer ingen kode,
      så kravet her er at appen er uendret etter at rapporten er lagt til
- [ ] Merget til `main`

## Notater

### Avklart i grilling (2026-08-14)

**Fartsarbeidet ble kuttet, og det var grillingens viktigste resultat.**
Utkastet startet med to steg om måling og lasteoptimalisering. Fire svar
avlivet dem: ingen konkret utløsende hendelse, en håndfull brukere, appen
oppleves som helt grei, og den brukes aldri uten nett. Å optimalisere
lastetid her ville vært arbeid uten mottaker. Bjørn Erik sin opprinnelige
formulering — «særlig taksonomi for tokens» — traff bedre enn utkastet.

**Firestore-bruk er utenfor.** Samme begrunnelse: ingen symptomer, ingen
klage. Å ta det med ville vært scope-vekst forkledd som grundighet.

**Rapporten skal ligge i `## Notater`, ikke i egen fil i repoet.** Det er
mønsteret fra fargekortet, og en egen fil er én ting til som kan bli
utdatert.

**CDN-risikoen skal fjernes, ikke bare dokumenteres.** Argumentet som
overlevde er robusthet, ikke fart: en uversjonert avhengighet utenfra kan
ta ned utseendet på appen uten at noen har rørt koden.

**Byggesteg er akseptert med åpne øyne.** Prisen er forstått og godtatt:
filen på serveren blir maskingenerert, så den kan ikke lenger rettes for
hånd — alt må gå via GitHub. Brekker bygget, oppdateres ikke appen før noen
teknisk har fikset det. Gevinsten er at tre problemer løses av én endring.

**Struktur og tokens skal ha lik vekt.** Her ble en anbefaling overstyrt, og
det er verdt å vite hvorfor: siden neste arbeid er *nye funksjoner i
eksisterende moduler* og ikke flere utseende-endringer, ble det anbefalt å
legge mest kraft på filstrukturen — det er den som koster når en funksjon
skal inn. Bjørn Erik valgte lik vekt likevel. **Konsekvens: kortet blir
større enn det ellers ville vært.** Sprer arbeidet seg, er steg 2 det som
skal nedskaleres først, siden det er det med svakest dokumentert gevinst.

### Grunnlag samlet før grillingen

- 4912 linjer, 245 kB, én fil
- 48 systemtokens og 44 palett-variabler definert i `:root`, 292
  Tailwind-fargeklasser i bruk
- 545 `class=`-attributter, 114 ulike klasser
- 45 `style="..."` rett i markupen
- Deploy er ren SFTP-kopi av `./*`, uten byggesteg, til
  `Korpsapp` (main) og `Korpsapp-test` (test)

---

## Rapport (2026-08-18)

Gjennomgangen er gjort på `index.html` slik den står i dag: **5269 linjer**,
259 kB. Kortet ble skrevet da fila var 4912 linjer, så den har vokst med 357
linjer (7 %) mens den lå i backlog. Det er i seg selv et lite funn: fila
vokser jevnt, og ingenting bremser den.

Hvert funn under er **bekreftet**, ikke antatt. Der en mistanke ikke holdt,
står det også — se «Mistanker som ikke holdt».

### Slik henger fila sammen

Fila er ikke det kaoset linjetallet antyder. Den har 32 tydelige
banner-merkede seksjoner, og de fem modulene er lette å finne. Fordelingen:

| Del | Linjer | Hva |
|---|---|---|
| `<head>` + Tailwind-oppsett | 1–107 | Fargekartet mot paletten |
| CSS | 108–502 | Hele designsystemet |
| Markup | 504–905 | Alle fem moduler + modaler |
| Kundeoppsett | 906–913 | `config.js` |
| Firebase-modul | 915–2028 | Innlogging, korps, arrangementer, delt lagring |
| Hovedlogikk | 2030–5267 | 32 seksjoner, 162 funksjoner |

De fem modulene deler allerede kode der det teller: `renderRows(kind)` dekker
Billettfordeling + Korpsoppsett, `renderGroups(kind)` dekker Romfordeling +
Vaktlister. Gruppeinndeling står for seg selv (393 linjer).

**De to tyngste seksjonene er `ROW-BASED` (1040 linjer) og `GRUPPEINNDELING`
(393 linjer).** Til sammen er de 27 % av all logikk. Skal noe deles opp
senere, er det her det monner.

### Funn, sortert etter nytte delt på risiko

#### 1. Uversjonert Tailwind fra en server vi ikke eier — og den advarer selv

**Bekreftet live på testsiden.** Nettleserkonsollen viser, akkurat nå:

> cdn.tailwindcss.com should not be used in production.

Utseendet til appen hentes ved hvert besøk fra
`https://cdn.tailwindcss.com`, **uten versjonsnummer**. 552 `class=`-
attributter avhenger av den.

**Men risikoen er større enn kortet antok — det er ikke én ekstern
avhengighet, det er fire:**

| Adresse | Versjon | Hva som ryker hvis den faller |
|---|---|---|
| `cdn.tailwindcss.com` | **ingen** | Alt utseende. Appen blir ustylet tekst |
| `fonts.googleapis.com` | **ingen** | Source Serif 4 — hele Broadsheet-uttrykket er serif |
| `fonts.gstatic.com` | **ingen** | Samme |
| `gstatic.com/firebasejs/**10.13.0**` | pinnet | Innlogging og lagring. Appen slutter å virke, ikke bare se rart ut |

Firebase er den eneste som er pinnet til en versjon. Skriftene er like
uversjonerte som Tailwind, og de er ikke nevnt i kortet.

**Kostnad i dag:** null, helt til dagen det smeller.
**Kostnad å fikse:** byggesteg (allerede godtatt i grillingen).
**Risiko for endret utseende:** lav for Tailwind, men skriftene må lastes ned
og legges i repoet for å fjerne den avhengigheten også.

#### 2. Service workeren beskytter dårligere enn den ser ut til

`sw.js` cacher Tailwind-adressen, så gjengangere skal være dekket. To ting
gjør at beskyttelsen er tynnere enn den virker:

- **`cache.addAll(ASSETS)` er alt-eller-ingenting.** Er CDN-en nede akkurat
  når service workeren installeres, feiler hele `addAll`, installasjonen
  ryker, og **ingenting** blir cachet — heller ikke `index.html`. Beskyttelsen
  mot at CDN-en faller, forutsetter altså at CDN-en var oppe på
  installasjonstidspunktet.
- **Skriftene og Firebase er ikke i `ASSETS` i det hele tatt.** Kun Tailwind.

Cachenavnet `fordeling-v1` har heller aldri blitt bumpet.

**Kostnad i dag:** null i praksis, men den falske tryggheten er verdt å vite om.
**Kostnad å fikse:** liten — `addAll` → `Promise.allSettled`, eller la
byggesteget gjøre problemet irrelevant.
**Risiko for endret utseende:** ingen.

#### 3. Klassenavnene i markupen lyver om fargen — bekreftet

Dette er reelt, og verre enn navnene antyder. Sporet hele veien:

- `bg-indigo-600` → `--farge-primar` → `--color-accent` → **`#0088b0`, cyan**
- `text-red-500` → `--farge-fare` → `--color-accent-2-700` → **`#aa0b56`, magenta**
- `text-emerald-*` → cyan
- `text-amber-700` → magenta

**296 slike bruk.** Den som leser markupen og ser `text-red-600` på en
slett-knapp, tenker rødt. Knappen er magenta. Ingenting i markupen røper det.

**Kostnad i dag:** hver gang noen leser eller endrer markup, må de vite om
oversettelsen. Det står forklart i kommentarer øverst i fila, men markupen
selv sier fortsatt «indigo».
**Kostnad å fikse:** stor — 296 bruk må skrives om, og et byggesteg må på
plass først for at egne klassenavn skal virke.
**Risiko for endret utseende:** **høy.** Dette er den endringen som lettest
kan endre utseendet ved et uhell.

**Anbefaling: ikke gjør dette nå.** Nytten er lesbarhet; risikoen er at
utseendet endrer seg. Vent til byggesteget står, og gjør det da som en egen,
isolert endring.

#### 4. Fire sidepanellister er nesten samme kode — og de har allerede sklidd fra hverandre

`renderNames`, `renderInstruments`, `renderGroupLeaders` og
`renderReiseledere` har samme form: sorter, tomtekst, bygg `.name-item`-HTML,
heng på dra-og-slipp. Fire kopier, ~200 linjer til sammen.

Kopiene har drevet fra hverandre, og **det har gitt en ekte feil**:

De fire `selected*`-variablene skal være gjensidig utelukkende, og hver
`select*`-funksjon nullstiller de andre for hånd. Men de nullstiller ikke de
samme:

| Funksjon | Nullstiller | Mangler |
|---|---|---|
| `selectName` | Instrument, Reiseleder | **Gruppeleder** |
| `selectInstrument` | Navn, Reiseleder | **Gruppeleder** |
| `selectGroupLeader` | Navn, Instrument | **Reiseleder** |
| `selectReiseleder` | Navn, Instrument, Gruppeleder | — |

Bare `selectReiseleder` er komplett.

**Dette gir en reproduserbar feil i Gruppeinndeling** (for korps som har en
egen Gruppeledere-liste):

1. Velg en gruppeleder i Gruppeledere-lista → «Kari» blir markert.
2. Velg et navn i Navnelista → «Ola» blir markert. `selectedGroupLeader` blir
   **ikke** nullstilt, og `renderGroupLeaders()` blir ikke kalt — så **Kari
   står fortsatt markert**. To navn ser valgt ut samtidig.
3. Trykk på lederfeltet til en gruppe → `teamLeaderSlotClick` sjekker
   `selectedGroupLeader` først, og setter inn **Kari**, ikke Ola.

Brukeren valgte Ola sist, og fikk Kari. Sist valgte vinner ikke.

*Merk: dette er sporet i koden, gjennom hver gren, ikke reprodusert i
nettleseren — det krever et korps med registrerte gruppeledere.*
`setMode` nullstiller alle fire, så feilen lekker ikke mellom moduler.

**Kostnad i dag:** en feil brukeren vil oppleve som at appen «gjør noe
annet enn jeg ba om».
**Kostnad å fikse:** feilen selv er en tolinjers retting. Å slå sammen de
fire listene er større, men fjerner hele klassen av feil.
**Risiko for endret utseende:** lav for rettingen, middels for sammenslåingen.

**Dette er funnet med best nytte delt på risiko.** Rettingen er billig og
gevinsten er konkret.

#### 5. To importfunksjoner er 70 % samme kode

`importRowsFromGSheetsModal` (53 linjer) og `importGroupsFromGSheetsModal`
(43 linjer) har **32 identiske linjer**. Forskjellen er tre felt og to
funksjonsnavn.

**Kostnad i dag:** enhver retting i Google Sheets-importen må gjøres to
steder, og glemmer man den ene, virker halve importen annerledes.
**Kostnad å fikse:** liten — én funksjon med parametere.
**Risiko for endret utseende:** ingen. Dette er dialoglogikk.

#### 6. Død CSS fra designsystemet — bekreftet

Fire klasser er definert og brukes **null** steder, verifisert mot hele
repoet (også dynamisk sammensatte navn):

- `.chip-assigned`, `.chip-free` — søsknene `.chip-confirmed`, `.chip-gap`,
  `.chip-sm` er i bruk, disse to er ikke
- `.empty-state` (+ regelen `.empty-state h3`)
- `.skeleton` (+ `@keyframes skeleton-pulse`)

I tillegg er **12 av 92 tokens definert uten å bli brukt**:
`--color-accent-2`, `--color-accent-2-400`, `--color-accent-900`,
`--color-divider`, `--color-neutral-600`, `--farge-ok`,
`--farge-ok-bakgrunn`, `--farge-ok-kant`, `--farge-svart-rgb`,
`--farge-tekst-graa`, `--space-2`, `--space-6`.

To detaljer verdt å merke seg:

- **`--farge-svart-rgb` har en kommentar som sier «bakteppe bak modaler».
  Den brukes ikke.** Kommentaren beskriver noe som ikke lenger er sant.
- **Ingen token blir brukt uten å være definert** (0 av 80 referanser peker i
  løse lufta). Det er et godt tegn — systemet er helt, bare litt for stort.

**Kostnad i dag:** liten, men hver ubrukt token er et valg å ta stilling til
neste gang noen leter etter riktig farge.
**Kostnad å fikse:** liten.
**Risiko for endret utseende:** ingen, forutsatt at slettingen verifiseres.

#### 7. «Avvikerne» er nå rene duplikater — og nås bare via ubrukte klasser

Kortet ba om at disse to ble sett på. Status etter fargekortet:

    --farge-ok-bakgrunn-avvik:  var(--color-accent-100);
    --farge-ok-tekst-avvik:     var(--color-accent-800);

De peker nå på nøyaktig samme verdier som `--farge-ok-bakgrunn` og
`--farge-ok-tekst`. To navn, én farge.

Verre: de brukes **kun** til å mate Tailwind-klassene `green-100` og
`green-700` — og **ingen av dem brukes noe sted i markupen** (verifisert: null
treff på `green-` i hele fila). Samtidig er «originalene» `--farge-ok-bakgrunn`
og `--farge-ok-kant` blant de 12 ubrukte.

Så: det kanoniske navnet er dødt, og avviker-navnet lever — via en klasse
ingen bruker. Hele `green`-blokken i Tailwind-oppsettet kan gå.

**Kostnad å fikse:** svært liten. **Risiko:** ingen.

#### 8. 46 `style="..."` omgår designsystemet

46 inline-stiler i markupen. De fleste er posisjonering i
oppstillingsdiagrammet (`position:relative`, beregnede `px`-verdier), som
**ikke** hører hjemme som tokens — de regnes ut i JavaScript.

**Konklusjon: dette er stort sett legitimt.** Verdt en opprydding bare hvis
noen av dem koder farge eller avstand som burde vært token. Lav prioritet.

### Mistanker som ikke holdt

Kortet ba uttrykkelig om at død kode skulle bekreftes, ikke antas. Tre
mistanker falt:

- **Død JavaScript: ingen.** Alle **162** funksjoner er referert minst én
  gang utenfor sin egen definisjon — også de som bare kalles fra `onclick` i
  markupen. Ingen å slette.
- **`heartbeats undefined` i konsollen er ikke vår.** Den ser ut som en
  glemt `console.log`, men kommer fra Firebase-SDK-en. Det finnes **null**
  `console.log` i `index.html`. Hadde jeg ikke sjekket, ville dette blitt
  rapportert som en feil vi ikke har.
- **Første måling av ubrukte tokens var feil.** Et første forsøk meldte at 92
  av 92 tokens var ubrukte — skallet tolket søkemønsteret som noe annet.
  Riktig tall er 12. Tas med fordi det er nettopp fellen kortet advarte mot.

### Bekrefter kort #2

Testsiden gjør **12 forgjeves nettverkskall ved hver eneste lasting**: den
prøver `.jpg` først for hvert slagverksbilde, får 404, og prøver `.jpeg` som
virker. Alle 12 filene ligger som `.jpeg`-filer. Det er nøyaktig det kort #2
beskriver, nå bekreftet med tall.

### Hva jeg ville gjort, i rekkefølge

1. **Rett `selected*`-feilen** (funn 4). Billigst, mest konkret gevinst.
2. **Slå sammen de to importfunksjonene** (funn 5). Liten, null risiko.
3. **Rydd død CSS og de 12 tokenene** (funn 6 og 7). Liten, null risiko.
4. **Byggesteg** (funn 1 og 2). Størst gevinst, men også størst endring —
   og den er allerede godtatt med åpne øyne i grillingen.
5. **Ikke rør klassenavnene ennå** (funn 3). Høyest risiko for utseendet,
   lavest konkret gevinst. Venter på byggesteget.

Steg 2 i planen — token-taksonomien — ga mindre enn ventet: systemet er helt,
og de reelle funnene er små oppryddinger. Grillingen forutså dette («steg 2
er det som skal nedskaleres først»), og det stemte.
