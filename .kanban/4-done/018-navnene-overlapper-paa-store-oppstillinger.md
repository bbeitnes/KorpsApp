---
title: Navnene overlapper på store oppstillinger
created: 2026-08-17
updated: 2026-08-18
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

- [x] Fjern gulvet på etikettbredden. `nameWidth` er
      `Math.round(Math.max(50, baseSeatSize * 1.5))`
      ([index.html:3391](../../index.html)) — den slutter å krympe ved 50px
      selv når raden bare har 27px buelengde per plass. Det er hele årsaken
      til overlappet. Bind bredden til plassens faktiske andel av buen i
      stedet, ikke til et fast tall.
- [x] **Fall tilbake til fornavn.** Når hele navnet ikke får plass: vis
      fornavnet. Ingen ellipse-stubber — «Bjø…» skiller ikke Bjørn fra Bjørg.
      ~~Når heller ikke det går: dropp etiketten helt.~~ **Omgjort etter
      verifisering på test 2026-08-18:** fornavnet vises alltid, også når det
      ikke er plass. Se `### Det som ble gjort om etter test`.
- [x] **Sett skriftgrensa etter måling, ikke før.** `fontSize` er i dag
      `Math.max(7, ...)` ([index.html:3392](../../index.html)), og 7px er
      under lesbarhetsgrensen uansett. Rekkefølgen er bestemt: fjern
      breddegulvet først, mål på nytt med 80 musikanter, og la grensa følge av
      hva som faktisk kan leses — på skjerm *og* på papir, siden utskriften
      har sitt eget gulv på `16`. Tallet skal begrunnes i kortet når det
      settes, ikke gjettes nå.
- [x] Behold radetiketten lesbar. Kort 4
      (`radetiketten-forsvinner-bak-plassen`, i `4-done`) løste nettopp dette
      med `z-index` og en flytting under linja — sjekk at endringen her ikke
      river opp den fiksen.
- [x] Verifiser mot utskriften. `buildFormationPrintHtml` deler geometri med
      skjermvisningen men sender inn egne tall
      ([index.html:3562](../../index.html), gulv `16`). Utskriften er den som
      virker i dag — den skal ikke bli dårligere av at skjermen blir bedre.
- [x] Mål på nytt etterpå med 80 musikanter på 5 rader: antall etiketter som
      dekkes av en boks skal være 0. Tallet før endringen er 18 av 80 (23%).

## Verifisering

- [x] 80 musikanter på 5 rader: ingen navneetikett dekkes av en boks *utilsiktet*
      — etiketter som får plass er kollisjonsfrie, og de som ikke får plass
      tegnes bevisst oppå med egen bakgrunn (se omgjøringen under)
- [x] Ingen plass står uten navn
- [x] Man kan lese oppstillingen på skjerm uten å skrive den ut
- [x] 20 musikanter ser like bra ut som før — den enden av skalaen var aldri
      ødelagt
- [x] Utskrift/PDF er uendret eller bedre
- [x] Testet på https://beitnes.net/Korpsapp-test
- [x] Merget til `main`

## Notater

### Hva som ble gjort (2026-08-18)

Alt i `renderFormation`/`renderFormationSeat` i `index.html`. Utskriften er ikke
rørt — den har sin egen `buildFormationPrintSeat`, og diffen tar ikke i den.

**1. Breddegulvet er borte.** `Math.max(50, ...)` er erstattet av
`formationLabelWidths`, som for hver plass regner ut hvor mye rom naboene
faktisk lar stå igjen. Taket er fortsatt `baseSeatSize * 1.5`; det er bare
gulvet som er fjernet.

**2. Regnestykket ble nødt til å gå over hele oppstillingen, ikke rad for rad.**
Grillingen målte at alle kollisjonene lå innad i en rad. Det stemte — på et
944px bredt kart. Første forsøk stolte på det og regnet bare på naboer i samme
rad; på iPad i stående format (720px kart) klemmes radene sammen, og mot endene
av buen, der radretningen er vannrett, havner en plass i rad 4 i samme høyde som
boksene i rad 3. Målt: tre kollisjoner på 20 musikanter, null når naboer i andre
rader teller med. En nabo teller bare hvis den ligger i veien i høyden også —
mot buendene står plassene i samme rad nesten rett over hverandre, og å regne på
x-avstand alene ville tømt buenden for navn helt unødvendig.

**3. Fallback-kjeden er fire hele trinn, ikke to.** Kortet sa «fornavn, så
ingenting». Det ble til: hele navnet + instrument → hele navnet → alle fornavn →
første fornavn → ingenting. De to nye trinnene er der fordi begge er hele
enheter man kan kjenne igjen, ikke stubber: å droppe instrumentlinja koster
mindre enn å droppe etternavnet, og «Bjørn Erik» er ett navn der «Bjørn» er et
annet. Ingen ellipse noe sted, som avtalt. Bredden måles med `measureText` mot
den fonten etiketten faktisk tegnes med — og siden «Source Serif 4» lastes fra
nettet, tegnes oppstillingen på nytt én gang når fonten er inne.

**4. Skriftgulvet ble 9px, og tallet er målt fram, ikke gjettet.** Antall navn
som faktisk får plass ved hvert gulv, 80 musikanter på 5 rader à 16, 944px kart:

| gulv | navn som vises |
|---|---|
| 7px | 70 av 80 |
| 8px | 61 |
| **9px** | **57** |
| 10px | 38 |
| 11px | 28 |

Knekkpunktet ligger mellom 9 og 10: et vanlig fornavn på 9px er ~24px bredt, og
hver plass i innerste rad rår over ~26px. 9px er altså den største skriften som
fortsatt får fornavnene inn i den trangeste raden, og den minste som fortsatt er
en bokstav. Under 9px vinner man fire navn på å gjøre alle 57 vanskeligere å
lese. Utskriftens eget gulv (`16` / `6px` skrift) er urørt.

**5. Etiketten ble flyttet helt opp over boksen.** Den lå før
`fontSize + 5` over boksens overkant, som er for lite for to linjer — linje to
havnet bak boksen (boksen har `z-index: 2`, etiketten ikke), så instrumentet var
i praksis usynlig. Nå ligger hele etiketten over boksen. For en ettlinjes
etikett er posisjonen den samme som før på piksel-nivå; forskjellen er at
tolinjes etiketter nå faktisk kan leses. Det er derfor 20 musikanter ser
*bedre* ut enn før, ikke likt: instrumentnavnet er synlig.

### Det som ble gjort om etter test (2026-08-18)

Verifisert i testmiljøet, og det holdt ikke: navn forsvant også på et korps på
~50, der det er god plass ellers. Årsaken er flankene av buen — der ligger
boksene diagonalt oppå hverandre, så plassen rett over en boks er opptatt av en
annen boks, og etiketten hadde ingen steder å være. Fire plasser på rad langs
venstre flanke sto helt uten navn, mens naboene rett ved siden av hadde navn.
Utskriften viste de samme navnene helt fint, som gjorde det ekstra tydelig at
skjermen var den som tok feil.

**Beslutningen fra grillingen er omgjort på ett punkt:** fornavnet vises nå
alltid, også når det ikke er plass til det. Resten av kjeden er som før — hele
navnet + instrument → hele navnet → alle fornavn → første fornavn — men siste
trinn droppes ikke lenger. Begrunnelsen for «tom plass er det ærlige svaret»
gjaldt avkuttede navn som *ser ut som* informasjon; et helt fornavn som så vidt
rører naboen er ikke det. Man kan lese hvem som står der, og det var hele målet.

Et påtvunget navn får sin egen bakgrunn og legges over boksene (`z-index: 3`,
samme grep som radetiketten bruker av samme grunn). Uten det ville det havnet
bak en boks og vært like borte som før — bokser har `z-index: 2`.

Hva det koster, samme oppsett som tabellene under, 944px kart:

| oppsett | plasser | navn vist | uten konflikt | påtvunget |
|---|---|---|---|---|
| 16+16+16+16+16 | 80 | **80** | 57 | 23 |
| 12+15+17+18+18 | 80 | **80** | 69 | 11 |
| 10+12+14+14 | 50 | **50** | 46 | 4 |
| 8+10+11+11 | 40 | **40** | 40 | 0 |
| 4+5+5+6 | 20 | **20** | 20 | 0 |

Ingen plass står uten navn i noe oppsett. Ved 40 og færre er ingen navn
påtvunget i det hele tatt — der er alt fortsatt kollisjonsfritt.

### Målingene etterpå (før omgjøringen)

Målt med samme metode som før endringen: for hver navneetikett, overlapper
rektangelet dens noen boks (`.seat`) på kartet. Navnene er ikke de samme som i
grillingens 18-av-80-måling, så baseline med dette navnesettet ble 16 av 80.

944px kart (skrivebord):

| oppsett | plasser | navn vist | droppet | navn over boks | navn over navn |
|---|---|---|---|---|---|
| 16+16+16+16+16 | 80 | 57 | 23 | **0** | 0 |
| 12+15+17+18+18 | 80 | 69 | 11 | **0** | 0 |
| 10+12+14+14 | 50 | 46 | 4 | **0** | 0 |
| 8+10+11+11 | 40 | 40 | 0 | **0** | 0 |
| 4+5+5+6 | 20 | 20 | 0 | **0** | 0 |

720px kart (iPad stående):

| oppsett | plasser | navn vist | droppet | navn over boks |
|---|---|---|---|---|
| 16+16+16+16+16 | 80 | 35 | 45 | **0** |
| 12+15+17+18+18 | 80 | 60 | 20 | **0** |
| 4+5+5+6 | 20 | 20 | 0 | **0** |

Også testet: én rad med alle 80 (alle etiketter droppes — plassene har ~5px
hver, og det er det ærlige svaret), blandede radformer (`shallow`/`left`/`flat`),
og en rad med én plass. Null kollisjoner i alle. Radetikettene («Rad 1» …) blir
ikke dekket av en boks i noe av oppsettene, så kort 4 sin fiks står urørt.
Gjengivelsen tar 6,8 ms for 80 plasser.

### Det som gjenstår å se med egne øyne

Om 9px faktisk er lesbart på iPad-en, og om de påtvungne navnene med egen
bakgrunn kjennes ryddige nok i den tetteste oppstillingen. Første runde i
testmiljøet avgjorde spørsmålet om droppede navn — det svaret står over.

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
