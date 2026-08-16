---
title: Korpsoppsett må kunne brukes fra iPad
created: 2026-08-16
updated: 2026-08-16
---

## Mål

Korpsoppsett skal kunne brukes fra iPad: plassere en musiker, flytte en
plass, bytte navn og fjerne en plass. I dag feiler dette — å velge et navn og
trykke på lerretet gir ingenting, observert på en iPad Pro 12,9" i fullskjerm.

Dette er ikke lenger et kartleggingskort. Grillingen 2026-08-16 snevret inn
feilen til tre mulige årsaker (se «Notater») og avdekket at den underliggende
defekten er at **hver eneste feilvei i denne flyten er taus**: ingenting sier
fra når et trykk ikke lander. Målet er både å få trykkveien til å virke og å
gjøre den umulig å bruke feil uten å få beskjed.

Korpsoppsett er **pilot**. Trykkveien finnes allerede i alle modusene, så
mønsteret som settes her skal kunne rulles ut til de andre etterpå — men de
er ikke med i dette kortet.

## Plan

- [ ] **Reproduser på desktop først.** Velg et navn i sidepanelet og klikk på
      lerretet med mus, uten å dra. Hvis det feiler der også, er ikke dette
      et iPad-kort i det hele tatt, og resten av planen skal skrives om.
      Dette steget er først fordi det er det billigste og fordi det kan
      endre hele diagnosen.
- [ ] Utelukk **allerede tildelt navn**. Et navn som står i oppsettet fra før
      får `onclick="locateName(...)"`, ikke `selectName`
      ([index.html:2411](../../index.html)) — det blar til plassen i stedet
      for å velge navnet. Trykker man et slikt navn og så på lerretet, skjer
      det ingenting, og det ser nøyaktig ut som feilen som ble observert.
- [ ] Utelukk at trykket ble **slukt av en plass**.
      `formationCanvasClick` starter med
      `if (e.target.closest('.seat')) return;`
      ([index.html:3465](../../index.html)). På et fullt lerret dekker
      plassene mye av buen, og «tom bakgrunn» kan i praksis være et sete.
- [ ] Utelukk at **klikk-hendelsen aldri fyres** på iPad. `onclick` ligger
      direkte på `#formation-canvas` ([index.html:720](../../index.html)).
      Bekreft med en midlertidig logg at `formationCanvasClick` faktisk
      kjører ved trykk på enheten.
- [ ] **Fjern de tause returene.** Uansett hvilken av de tre det var: alle
      feilveiene i `formationCanvasClick` og `placeFormationSeat`
      ([index.html:3413](../../index.html)) er `return` uten et ord til
      brukeren. Gi tilbakemelding når et trykk ikke fører til en plassering
      — særlig «du må velge et navn først» og «det navnet står allerede i
      oppsettet».
- [ ] **Gjør trykkveien synlig.** Ingenting i grensesnittet forteller at man
      kan velge et navn og trykke på kartet. Når et navn er valgt, bør det
      stå på eller ved lerretet hva som skjer nå — på samme måte som
      «↔️ Trykk der plassen skal flyttes»-banneret
      ([index.html:3320](../../index.html)) allerede gjør for flytting.
- [ ] Verifiser **flytteveien** ende til ende på enhet: trykk plass → modal →
      «↔️ Flytt» ([index.html:3575](../../index.html)) → trykk der den skal
      stå. Banneret finnes, så denne veien er den som har størst sjanse for
      allerede å virke.
- [ ] Mål trykkmålene. `--tap-min` er `44px`
      ([index.html:190](../../index.html)) men håndheves bare på `.btn`
      ([index.html:419](../../index.html)), mens `computeAutoSeatSize`
      ([index.html:3143](../../index.html)) krymper plassene fritt under det
      når en rad er trang.
- [ ] Sjekk at rulling og knipe-zoom på lerretet ikke utløser en utilsiktet
      plassering.
- [ ] Test **under 1024px bredde** — Split View eller Stage Manager på den
      samme iPad-en holder. Der bytter sidepanelet til overlegg
      ([index.html:270](../../index.html)), og `selectName`
      ([index.html:2449](../../index.html)) lukker det ikke, så man må velge
      navn, lukke panelet, og så treffe et punkt på et lerret man ikke så da
      valget ble tatt. Vurder om valg av navn skal lukke panelet automatisk
      på smale bredder.

## Verifisering

- [ ] Reprodusert i simulator/nettleser før fiks, og feilen forstått — ikke
      bare borte
- [ ] Ny plassering virker på iPad: velg navn, trykk lerret, plass dukker opp
- [ ] Flytting virker på iPad: trykk plass → «↔️ Flytt» → trykk mål
- [ ] Et trykk som ikke fører fram gir en forståelig beskjed, aldri stillhet
- [ ] Testet i fullskjerm (≥1024px) og i Split View (<1024px)
- [ ] Til slutt bekreftet på ekte iPad Pro 12,9" (5. gen), ikke bare simulator
- [ ] Testet på https://beitnes.net/Korpsapp-test
- [ ] Merget til `main`

## Notater

### Hva grillingen 2026-08-16 fastslo

**Feilen er observert, ikke antatt.** iPad Pro 12,9" (5. gen), nyere iPadOS,
fullskjerm: navn valgt i sidepanelet, trykk på lerretet, ingen plass dukket
opp.

**Geometrien er uskyldig.** Dette er den viktigste innsnevringen.
`renderFormation` skjuler hele `#formation-layout` når det ikke finnes rader
([index.html:3296](../../index.html)) — så hvis lerretet i det hele tatt var
synlig, var `formationGeometry` satt. Og `resolveFormationDrop`
([index.html:3371](../../index.html)) snapper til *nærmeste* rad over hele
lerretet; den kan i praksis ikke returnere `null` når geometrien finnes.
Et trykk som nådde `placeFormationSeat` ville derfor ha plassert en musikant
et eller annet sted — kanskje på feil rad, men *noe* ville skjedd.

Siden ingenting skjedde, nådde trykket aldri dit. Gjenstående mistenkte, i
den rekkefølgen planen prøver dem:

1. `selectedName` var aldri satt — navnet var allerede plassert, så
   `locateName` kjørte i stedet for `selectName`.
2. Trykket traff et `.seat` og ble returnert bort på første linje i
   `formationCanvasClick`.
3. Klikk-hendelsen fyres ikke på iPad i det hele tatt.

**Den egentlige defekten er tausheten.** Alle tre veiene over ender i en
`return` uten tilbakemelding. Brukeren kan ikke skille «dette støttes ikke»
fra «du må velge et navn først». Å fikse den enkeltbugen uten å fikse
tausheten løser bare denne ene rapporten.

### Antakelser som ble revet ned under grillingen

**«Dra-og-slipp virker ikke med touch» er for grovt på iPad.** Kortets
opprinnelige premiss var at HTML5-drag er dødt på touch. Det stemmer for
iPhone, men iPadOS Safari har støttet native dra-og-slipp fra touch-and-hold
siden iOS 11 — `dragstart` og `drop` *kan* fyre. Om dra-og-slipp faktisk
virker på denne iPad-en er ikke testet, og planen bygger ikke lenger på at
det ikke gjør det.

**«Test i begge orienteringer» var nesten verdiløst.** iPad Pro 12,9" (5. gen)
er 1024×1366 pt. Stående er den 1024 pt bred, som treffer
`@media (min-width: 1024px)` ([index.html:278](../../index.html)) nøyaktig.
Begge orienteringer gir altså desktop-oppsettet med fast sidepanel. Overlegg-
sidepanelet er uoppnåelig på denne enheten ved vanlig rotering — men fullt
oppnåelig i Split View og Stage Manager, og det er normalen på iPad Air
(820 pt) og mini (744 pt). Derfor er steget skrevet om fra «begge
orienteringer» til «begge sider av 1024px-grensa».

**«Dette er egentlig hele appen» viste seg å være mye mindre enn det høres
ut som.** Trykkveien er allerede koblet opp overalt, ikke bare i
Korpsoppsett: `.room-slot` har `groupSlotClick`
([index.html:3801](../../index.html)), konsertseter har `seatClick`
([index.html:3065](../../index.html)), gruppekort har `teamAddSlotClick`
([index.html:3905](../../index.html)). Ingen trenger å bygge en ny
interaksjonsmodell — den finnes, den er bare uverifisert og usynlig.
Korpsoppsett er valgt som pilot fordi det er det vanskeligste tilfellet:
fri plassering på et lerret i stedet for faste båser.

**Oppfølgingskort forventes** for konsertsal, rom, vakter og grupper når
mønsteret er satt her. De er bevisst ikke med i dette kortet.

### Beslektet

`.reorder-handle` ([index.html:306](../../index.html), logikken på
[index.html:4883](../../index.html)) er skrevet med
`pointerdown`/`pointermove` og `touch-action: none` nettopp for å virke likt
med mus og touch. Det er presedensen å følge *hvis* det senere viser seg at
ekte fingerdrag må til — men grillingen konkluderte med at en komplett og
synlig trykkvei er nok, så det er ikke i scope her.

`radetiketten-forsvinner-bak-plassen` (i `review`) la inn
`#formation-canvas .seat:hover { z-index: 4 !important; }`
([index.html:464](../../index.html)) for å holde tooltip-en lesbar. `:hover`
er meningsløst på touch, så navnet på musikeren i en plass er utilgjengelig
på iPad. Det er ikke en regresjon fra dette kortet, men det er den samme
brukeren som rammes, og det bør vurderes når trykkveien uansett gås opp.
