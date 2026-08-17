---
title: Navnene overlapper på store oppstillinger
created: 2026-08-17
updated: 2026-08-17
---

## Mål

Man skal kunne lese hvem som står hvor i korpsoppsettet **på skjerm**, også
for et korps på 80. I dag overlapper navneetikettene hverandres bokser så mye
at utskrift er eneste måte å faktisk se oppstillingen på — det er en
omvei, ikke en preferanse.

Rammen er gitt: **dirigenten bestemmer antall rader og hvor mange som står i
hver.** Appen skal tilpasse seg det tallet, ikke forhandle om det. Ingen
«legg til en rad»-advarsler.

## Plan

- [ ] Fjern gulvet på etikettbredden. `nameWidth` er
      `Math.round(Math.max(50, baseSeatSize * 1.5))`
      ([index.html:3391](../../index.html)) — den slutter å krympe ved 50px
      selv når raden bare har 27px buelengde per plass. Det er hele årsaken
      til overlappet. Bind bredden til plassens faktiske andel av buen i
      stedet, ikke til et fast tall.
- [ ] **Fall tilbake til fornavn, så til ingenting.** Når hele navnet ikke får
      plass: vis fornavnet. Når heller ikke det går: dropp etiketten helt.
      Boksen har fortsatt initialer, og navnet finnes i plassmenyen ved trykk.
      Ingen ellipse-stubber — «Bjø…» skiller ikke Bjørn fra Bjørg, og en
      uleselig stub er verre enn tom plass. Se `## Notater` for begrunnelsen.
- [ ] **Sett skriftgrensa etter måling, ikke før.** `fontSize` er i dag
      `Math.max(7, ...)` ([index.html:3392](../../index.html)), og 7px er
      under lesbarhetsgrensen uansett. Rekkefølgen er bestemt: fjern
      breddegulvet først, mål på nytt med 80 musikanter, og la grensa følge av
      hva som faktisk kan leses — på skjerm *og* på papir, siden utskriften
      har sitt eget gulv på `16`. Tallet skal begrunnes i kortet når det
      settes, ikke gjettes nå.
- [ ] Behold radetiketten lesbar. Kort 4
      (`radetiketten-forsvinner-bak-plassen`, i `4-done`) løste nettopp dette
      med `z-index` og en flytting under linja — sjekk at endringen her ikke
      river opp den fiksen.
- [ ] Verifiser mot utskriften. `buildFormationPrintHtml` deler geometri med
      skjermvisningen men sender inn egne tall
      ([index.html:3562](../../index.html), gulv `16`). Utskriften er den som
      virker i dag — den skal ikke bli dårligere av at skjermen blir bedre.
- [ ] Mål på nytt etterpå med 80 musikanter på 5 rader: antall etiketter som
      dekkes av en boks skal være 0. Tallet før endringen er 18 av 80 (23%).

## Verifisering

- [ ] 80 musikanter på 5 rader: ingen navneetikett dekkes av en boks
- [ ] Man kan lese oppstillingen på skjerm uten å skrive den ut
- [ ] 20 musikanter ser like bra ut som før — den enden av skalaen var aldri
      ødelagt
- [ ] Utskrift/PDF er uendret eller bedre
- [ ] Testet på https://beitnes.net/Korpsapp-test
- [ ] Merget til `main`

## Notater

### Hva grillingen 2026-08-17 fastslo

Kortet het opprinnelig «Trykkflatene på kartet er for små» og handlet om
`--tap-min`. Grillingen flyttet det.

**Ingen har bommet på et trykk.** Spurt direkte: nei. Trykkflate-vinkelen
hadde ingen rapportert feil bak seg — den kom fra en måling gjort under kort
11, ikke fra bruk.

**Korpsene er 20–80.** Det finnes ingen «vanlig størrelse»: ved 20 er boksen
54px og ingenting er galt, ved 80 er den 21px. Det er to forskjellige
problemer i hver sin ende av samme skala.

**Den ekte feilen er overlapp, og den er observert.** Bjørn Erik er eneste
bruker av korpsoppsettet og ser den selv: boksene legger seg oppå navnene, og
derfor *må* oppstillingen skrives ut for å kunne leses.

**Overlappet er innenfor én rad, ikke mellom rader.** Målt på 80 musikanter
på 5 rader: 18 av 80 navneetiketter dekkes av en boks, og **alle 18
kollisjonene er med en nabo i samme rad — null mellom rader**. Radavstanden
har god plass (74px tilgjengelig, 33px nødvendig). Det utelukker radgeometri
som årsak.

**Årsaken er gulvet på etikettbredden.** Innerste rad har 27px buelengde per
plass; etiketten er låst til 50px. Hver etikett sprer seg altså over
nabo-boksene. Kommentaren over selve linja sier at etiketten «skal fortsatt
krympe i tette oppstillinger» og at den var «hovedårsaken til overlapping
før» — den krymper, men stopper på 50px, langt forbi der den fortsatt passer.

**Dirigenten bestemmer radene.** Foreslått at appen skulle advare og be om
flere rader ved trange oppstillinger. Avvist, og med rette: antall rader og
antall per rad er en musikalsk avgjørelse. Appen skal skalere boksene til å
passe tallet den får. Denne retningen er strøket fra planen.

### De to avgjørelsene grillingen tok

**Fornavn, så ingenting — ikke ellipse.** Selv med breddegulvet fjernet er det
27px og 7px skrift i innerste rad ved 80 musikanter; det holder til rundt fire
tegn. Valgt fordi et kuttet navn *ser ut som* informasjon uten å være det:
«Bjø…» skiller ikke Bjørn fra Bjørg, og man tror man har lest noe man ikke har
lest. Fornavn er en ekte enhet man kan kjenne igjen. Når heller ikke det går,
er tom plass det ærlige svaret — initialene står i boksen, og hele navnet er
ett trykk unna i plassmenyen.

**Skriftgrensa settes etter målingen, ikke nå.** Bevisst utsatt, ikke glemt.
Å velge 7, 9 eller 10px før breddegulvet er fjernet er å gjette på et tall som
endrer seg av selve fiksen. Rekkefølgen er derfor en del av planen: fjern
gulvet, mål på nytt, velg grensa, og skriv ned hvorfor den ble som den ble.

### Målingene (2026-08-17)

`computeAutoSeatSize(rader, bredde, {seatSize:54}, 20)`, boks i px. Lerretet
har `max-width: 1000px` ([index.html:725](../../index.html)), så 1000 er taket.

| musikanter | 1000px | 944px | 700px | 500px | 380px |
|---|---|---|---|---|---|
| 20 (4 rader) | 54 | 54 | 54 | 32 | 30 |
| 30 (4 rader) | 54 | 43 | 30 | 20 | 20 |
| 40 (4 rader) | 37 | 34 | 24 | 20 | 20 |
| 50 (4 rader) | 28 | 26 | 20 | 20 | 20 |
| 80 (5 rader) | 23 | **21** | 20 | 20 | 20 |

Hva gjengivelsen gir ved de størrelsene:

| boks | skrift på navnet | etikettbredde |
|---|---|---|
| 54px | 10px | 81px |
| 43px | 8px | 65px |
| 30px og under | **7px** (gulv) | **50px** (gulv) |

Begge gulvene slår inn samtidig, og det er ved 30px boks — altså allerede fra
rundt 30–40 musikanter.

### Trykkflatene, som kortet het før

Fortsatt sant, men nedgradert til en note: en plass er 43px ved 30 musikanter
og 21px ved 80, mot `--tap-min: 44px` ([index.html:190](../../index.html)),
som i dag bare håndheves på `.btn` ([index.html:419](../../index.html)).
`.avatar` i navnelista er målt 26×26px og har samme skavank.

Grunnen til at dette ikke er hovedsaken: ingen har bommet, og på en
oppstilling man uansett ikke kan lese er treffsikkerhet det andre problemet i
rekkefølgen. Ta det opp igjen som eget kort hvis det melder seg i bruk —
eller la det følge med hvis fiksen her uansett rører boksstørrelsen.

### Beslektet

Kort 11 (`korpsoppsett-maa-kunne-brukes-fra-ipad`, i `4-done`) gjorde
trykkveien synlig og fjernet de tause feilveiene. Den plasserer på buen og
krever aldri at man treffer en eksisterende boks — derfor kunne den lukkes
uten at dette var løst.

Kort 4 (`radetiketten-forsvinner-bak-plassen`, i `4-done`) er nærmeste
slektning: samme kart, samme type overlapp, og den prøvde og forkastet å
flytte etiketten i stedet for å endre størrelsen. Les den før du begynner.
