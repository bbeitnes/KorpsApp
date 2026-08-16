---
title: Instrumenttekst er for stor
created: 2026-08-14
updated: 2026-08-16
---

## Mål

Navneetiketten på **store rader** (de som merkes med `:x`, typisk slagverk)
er for stor. Etter dette skal navnet være nøyaktig like stort som på vanlige
rader — samme skriftstørrelse og samme etikettbredde — selv om boksen bak er
større.

Årsaken er funnet: etiketten skaleres to ganger. Boksen er allerede gjort
1,6 ganger større før den sendes til tegnefunksjonen, og så legges det på et
*ekstra* påslag for store rader oppå det. Se `## Notater` for tallene.

## Plan

- [x] Steg 1 — Send basisstørrelsen med inn i `renderFormationSeat`
      ([index.html:3306](../../index.html))
  - `autoSeatSize` finnes allerede i `renderFormation`
    ([index.html:3279](../../index.html)) og er størrelsen før
    «stor rad»-ganget på 1,6
  - Kallet ligger på [index.html:3286](../../index.html)
  - Alternativet — å regne baklengs med `seatSize / 1.6` inne i funksjonen —
    ville lagt tallet 1,6 på et sted til. Det står i dag kun ett sted
    ([index.html:3132](../../index.html)) og bør fortsette med det
- [x] Steg 2 — Bruk basisstørrelsen til navneetiketten
  - Skriftstørrelse ([index.html:3325](../../index.html)): `0.19` for alle
    rader, regnet ut fra basisstørrelsen. `row.large`-forgreningen forsvinner
  - Etikettbredde ([index.html:3324](../../index.html)): `Math.max(50, …*1.5)`
    for alle rader, også regnet fra basisstørrelsen
- [x] Steg 3 — La plasseringen være i fred
  - `nameTop` bruker `seatSize/2` for å legge etiketten over boksen. Den skal
    fortsatt bruke den **store** boksstørrelsen, ellers havner etiketten oppå
    boksen på store rader
- [x] Steg 4 — Ikke rør utskrift/PDF
  - `buildFormationPrintSeat` ([index.html:3455](../../index.html)) har ikke
    feilen: den bruker én faktor for alle rader og skalerer allerede riktig
  - Initialene inne i boksen ([index.html:3309](../../index.html)) har heller
    ikke feilen — én faktor for alle rader. Skal ikke endres

## Verifisering

- [x] En rad merket `:x` og en vanlig rad ved siden av hverandre: navnene er
      nøyaktig like store. Målt i nettleser: bokser 86 px mot 54 px (1,6× som
      før), etiketter 10 px / 81 px på **begge** rader
- [x] Både korte navn («Pauker») og lange («Skarptromme») sjekket — se
      `## Notater`, spådommen om linjebrekk slo ikke til
- [x] Tett oppsett (24 plasser, lange navn) og luftig oppsett sjekket: alle
      etiketter 7 px / 53 px, og **null overlappende par** målt
- [x] Utskrift/PDF er uendret — `buildFormationPrintSeat` har fortsatt 7
      parametre og gir 14 px på en stor rad, som før
- [x] Testet på https://beitnes.net/Korpsapp-test — bruker bekreftet «looks good» 2026-08-16
- [ ] Merget til `main`

## Notater

Oppdaget 2026-08-14 under testing av fargerefaktoreringen (steg 4). Ikke
forårsaket av den — fargecommitene inneholder ingen endringer i
skriftstørrelse i det hele tatt (verifisert med `git diff`).

### Gjennomført 2026-08-15

Endringen er tre linjer: basisstørrelsen (`autoSeatSize`) sendes med inn i
`renderFormationSeat`, og navneetiketten regnes fra den i stedet for fra
radens egen boksstørrelse. Plasseringen (`nameTop`) bruker fortsatt radens
egen størrelse, så etiketten ligger like riktig over den store boksen.

**Målt i nettleser, luftig oppsett (944 px lerret):**

| | Vanlig rad | Stor rad (`:x`) |
|---|---|---|
| Boks | 54 px | 86 px (1,6×) |
| Navnetekst | 10 px | **10 px** |
| Etikettbredde | 81 px | **81 px** |

Til sammenligning ville den gamle koden gitt 19 px tekst i en 163 px etikett
på den store raden — nesten det dobbelte.

**Spådommen om linjebrekk slo ikke til.** Kortet advarte om at «Skarptromme»
ville brekke over flere linjer når etiketten ble smalere. Målingen viser én
linje i både luftig (81 px) og tett (53 px) oppsett. Advarselen var altså
unødvendig — men verdt å ha hatt, siden den var det eneste kjente
minuset ved valget.

**Fikset gjør det tette oppsettet bedre, ikke verre.** Med 12 plasser på en
`:x`-rad ville den gamle koden gitt 12 etiketter à 106 px på et 944 px
lerret — garantert kollisjon. Etter endringen: 53 px hver, og null
overlappende par målt. Det var nettopp overlapping kommentaren i koden
opprinnelig var redd for, så endringen tjener det hensynet bedre enn før.

**Verifisert uten innlogging.** Appen krever pålogging, så oppstillingen ble
bygget syntetisk i nettleseren og `renderFormation()` kalt direkte. Merk at
`t` på en plass er 0–100, ikke 0–1 — første forsøk la alle plassene oppå
hverandre.

Merk at dette er en ekte designendring, ikke en refaktorering. Den bør derfor
ikke blandes inn i fargearbeidet, som har «utseendet skal være 100 % identisk»
som krav.

Kommentaren i koden forklarer hvorfor skaleringen er som den er: etiketten er
mye bredere enn boksen, og var hovedårsaken til overlapping i tette oppsett
før den ble bundet til boksstørrelsen. En endring må ta hensyn til det.

### Avklart 2026-08-15

**Hvilken tekst:** navneetiketten på store rader — de som merkes med `:x` i
radoppsettet, typisk slagverk. Bekreftet av bruker. Hjelpeteksten viser
skrivemåten: `Tuba:s:x` ([index.html:2879](../../index.html)), og `:x` leses
inn som `large` ([index.html:2912](../../index.html)).

**Årsaken — dobbel skalering.** Boksen ganges med 1,6 for store rader
([index.html:3132](../../index.html)) *før* den sendes videre. Inne i
`renderFormationSeat` legges det så på et ekstra påslag for store rader oppå
den allerede forstørrede verdien. Med 40 px som basis:

| | Vanlig rad | Stor rad (`:x`) | Vekst |
|---|---|---|---|
| Boks | 40 px | 64 px | 1,60× |
| Navnetekst | 8 px | 14 px | **1,75×** |
| Etikettbredde | 60 px | 122 px | **2,03×** |
| *Utskrift, samme rader* | *9 px* | *14 px* | *1,56×* |

Etiketten blir altså dobbelt så bred på en boks som bare er 1,6 ganger
bredere. Det forklarer både at teksten ser for stor ut og at det blir trangt.

**Utskrift har ikke feilen** og er derfor beviset på hva som er riktig:
`buildFormationPrintSeat` bruker én faktor for alle rader og skalerer
proporsjonalt. Samme funksjon, to implementasjoner, og bare én av dem er
riktig.

**Valgt løsning: helt lik tekst på alle rader** — 8 px og 60 px etikett, uten
hensyn til boksstørrelsen. Bruker valgte dette framfor proporsjonal skalering
(som ville gitt 12 px). Begrunnelsen er at et navn er et navn: det skal være
like lesbart uansett hvor stor boksen bak er. Merk at dette gjør etiketten
**smalere** enn i dag på store rader, så lange navn brekker over flere linjer
— det er en villet konsekvens, men må sjekkes.

**Gulvene er ikke årsaken.** En tidligere hypotese var at minstestørrelsene
(`Math.max(7, …)`) slo inn i tette oppsett. Den holdt ikke: gulvene virker
likt for alle rader og forklarer ikke hvorfor det er nettopp `:x`-rader som
skiller seg ut. Dobbeltskaleringen gjør det.

**Mulig berøring med kortet i review:** `radetiketten-forsvinner-bak-plassen`
hevet radetiketten til `z-index: 3`, altså over boksene. Det er et annet
element enn navneetiketten, men de ligger i samme område. Verdt å se på
samlet.
