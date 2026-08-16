---
title: Radetiketten forsvinner bak plassen i Korpsoppsett
created: 2026-08-14
updated: 2026-08-16
---

## Mål

I Korpsoppsett blir radnavnet dekket av boksen til musikeren som står først i
raden. Etter dette skal radnavnet være lesbart også når plassen er fylt.

Løsningen er **både** å flytte etiketten ned under radens linje **og** å
beholde den hevet i lagdelingen. Grillingen 2026-08-14 konkluderte med at det
ikke fantes plass å flytte den til, og at heving var nok. Testingen 2026-08-16
viste at det ikke holdt: etiketten lå fortsatt oppå boksene, bare lesbart.
Bruker ba om at den skulle flyttes. Se «Utført 2026-08-16».

## Plan

- [x] Hev `z-index` på radetiketten fra `1` til `3`
      ([index.html:3191](../../index.html), `formationRowLabelHtml`).
      Boksene ligger på `2`, så `3` er nok. Hold deg under `5` — der ligger
      «Trykk der plassen skal flyttes»-banneret, som skal vinne.
- [x] Rett opp følgefeilen på tooltip-en: `.tooltip`
      ([index.html:453](../../index.html)) har `z-index: 20`, men ligger
      *inne i* boksen, som har `z-index:2` og `position:absolute` og dermed
      lager sin egen stablingskontekst. Tooltip-en er derfor låst til nivå 2
      og blir dekket av en etikett på nivå 3. Navnet på musikeren må fortsatt
      kunne leses ved hover.
- [x] Merk at boksens `z-index:2` er satt **inline**
      ([index.html:3299](../../index.html)). En CSS-regel som
      `.seat:hover { z-index: 4 }` slår derfor ikke gjennom uten
      `!important` — eller så må `z-index` flyttes ut av inline-stilen og
      inn i `.seat`-klassen.
- [x] Sjekk at etikettens halvgjennomsiktige bakgrunn
      (`rgba(var(--farge-bakgrunn-rgb), .9)`) er lesbar oppå et foto, ikke
      bare oppå initialer på ensfarget bunn.
- [x] Flytt etiketten ned under radens linje, rett under første boks
      (`formationRowLabelHtml`). Var `- 9` over linja, er nå
      `+ geom.seatSize/2 + 4` under den
- [x] Legg til `nudgeFormationRowLabels`: måler etikettene etter tegning og
      skyver dem til side hvis de lander oppå «🎼 Dirigent» eller utenfor
      kanten av kartet. Bredden avhenger av teksten og kan ikke regnes ut på
      forhånd, derfor måling i stedet for utregning

## Verifisering

- [x] Plasser en musiker først i raden (`t = 0`) — radnavnet skal være lesbart
      oppå boksen
- [x] Hold musepekeren over nettopp den musikeren — tooltip-en med fullt navn
      skal fortsatt være lesbar, ikke dekket av radetiketten
- [x] Sjekk både med foto og med initialer — godkjent av bruker på testsiden 2026-08-16
- [x] Sjekk dra-og-slipp: etiketten har `pointer-events:none`, så den skal
      ikke stjele klikk selv når den ligger øverst
- [x] Sjekk en `right`-justert rad spesielt — der ligger `t = 0` øverst i
      midten, ikke til venstre som i de andre radformene
- [x] Testet på https://beitnes.net/Korpsapp-test — bruker bekreftet «looks good» 2026-08-16
- [x] Merget til `main` — 2026-08-16, sammen med Broadsheet-redesignet

## Notater

**Utført 2026-08-14.** To endringer i `index.html`:
`formationRowLabelHtml` fikk `z-index:3` (var `1`), og det kom en ny CSS-regel
`#formation-canvas .seat:hover { z-index: 4 !important; }`. `!important` var
nødvendig fordi boksens `z-index:2` settes inline og ellers vinner over
klassen. Regelen er scopet til `#formation-canvas` slik at Billettfordeling
(`renderConcert`) ikke berøres — den er den eneste andre `.seat`-brukeren, og
den setter ingen inline `z-index`.

**Verifisert i nettleser** (lokal `serve` på port 8794, syntetisk oppstilling
med en musiker på `t = 0` i alle fire radene):

- Hver radetikett ble målt til å overlappe nøyaktig sin egen `t = 0`-musiker —
  det bekrefter årsaksforklaringen under.
- Skjermbilde viser alle fire radnavnene lesbare oppå boksene, inkludert
  `right`-raden der `t = 0` ligger øverst i midten i stedet for til venstre.
- Ved hover måltes boksen til `z-index: 4` og tooltip-en til `opacity: 1`,
  altså over etiketten på `3`.
- Dra-og-slipp er uberørt: `document.elementFromPoint` midt på etiketten
  returnerer *boksen*, ikke etiketten — `pointer-events:none` gjør etiketten
  usynlig for treff-testing. (Det betyr også at `elementFromPoint` ikke kan
  brukes til å måle tegnerekkefølge her; det må gjøres visuelt.)

De 404-ene som ligger i konsollen er `.jpg` som prøves før `.jpeg` på
instrumentbilder — kjent fra kortet `fjern-unodvendige-404-er…`, ikke fra
denne endringen.

**Årsaken**, funnet 2026-08-14: radetiketten ankres i `formationSeatXY(geom, 0)`
— nøyaktig samme punkt på kurven som en plass på `t = 0` opptar. Etiketten har
`z-index:1` ([index.html:3191](../../index.html)), boksen har `z-index:2`
([index.html:3299](../../index.html)). Boksen tegnes derfor oppå navnet.

**Utskrift/PDF er ikke berørt.** `buildFormationPrintHtml`
([index.html:3469](../../index.html)) kaller aldri `formationRowLabelHtml` —
den skriver radnavnene som en tekstlig legende (`<strong>Rad 1:</strong> 4
plasser`) i stedet. Endringen gjelder bare skjerm.

### Hvorfor ikke flytte etiketten

Bestillingen var opprinnelig «legg etiketten under linja». Regnestykket sier
at det ikke virker, og grillingen forkastet tre varianter:

- **Rett under linja.** Boksen er `seatSize` høy og strekker seg `seatSize/2`
  (27 px ved standard 54) på hver side av kurven. Etiketten ligger i dag på
  −9 px, altså *inne i* det båndet. Å snu fortegnet gir +9 px — fortsatt inne
  i båndet. Det måtte ned mot 40 px for å klarere boksen.
- **Lenger ned enn det.** Radavstanden er `rowGap`. På et 900 px lerret med 8
  rader er den ~39 px — mindre enn de ~40 px etiketten trenger. `−9 px` er
  altså ikke slurv: fullt over boksen ville kollidert med raden bak, så
  forfatteren har gjemt etiketten inne i sitt eget rad-bånd med vitende og
  vilje.
- **Utover langs buen.** Ser fristende ut, men `t = 0` ligger på `x = −radius,
  y = 0` for center-, left-, bow- og flat-rader — alle radenes venstreender
  ligger på samme vannrette linje, med nøyaktig `rowGap` mellom seg. Å skyve
  etiketten utover går derfor rett inn i nabo­radens ende: samme 39 px-budsjett,
  bare rotert. For `right`-rader ligger `t = 0` dessuten på `x = 0, y = radius`
  — øverst i midten — så «utover» betyr noe helt annet der.

Konklusjonen er at den vertikale aksen er full i begge retninger og den
vannrette også. Derfor lagdeling i stedet for flytting.

**Bivirkningen er akseptert:** etiketten dekker nå et hjørne av fotoet eller
initialene til musikeren på `t = 0`. Det ble vurdert som mindre ille enn at
radnavnet forsvinner helt.

**Vurdert og forkastet:** å fjerne etiketten fra lerretet helt og la
`formation-legend` ([index.html:3284](../../index.html)) bære radnavnene alene
— den viser allerede «Rad 1: 4 plassert». Forkastet fordi den visuelle koblingen
mellom bue og radnavn går tapt.

**Merk:** `computeAutoSeatSize` ([index.html:3143](../../index.html)) krymper
bare boksene når en rad er trang *langs buen* — den ser aldri på radavstanden.
En oppstilling med mange rader og få musikere per rad beholder derfor
54 px-bokser med ~39 px radavstand, slik at nabo­radenes bokser overlapper
hverandre med ~15 px. Det er verdt å vite hvis noen senere prøver å løse dette
med geometri likevel.

**Beslektet kort:** `instrumenttekst-er-for-stor` gjelder navneetiketten over
hver boks — en annen etikett enn denne. Grillingen slo fast at de to kortene
*ikke* er samme sak, og de kan gjøres uavhengig.

### Utført 2026-08-16 — etiketten er flyttet ned

Bruker testet på testsiden og meldte at plasseringen ikke var som ønsket:
etiketten lå fortsatt oppå boksene, bare lesbart. Tre plasseringer ble tegnet
opp og målt i nettleser før valget:

| | Plassering | Problem |
|---|---|---|
| Dagens | Over linja, ved radens start | Ligger oppå første boks |
| A **(valgt)** | Rett ned, under første boks | Traff «🎼 Dirigent» på innerste rad |
| B | Ned og ut til venstre, utenfor buen | Ytterste rad falt 26 px utenfor kartet |

Bruker valgte A, og at etiketten fortsatt skal ligge øverst i lagdelingen
hvis den likevel kommer borti en boks. `nudgeFormationRowLabels` løser
Dirigent-kollisjonen: i eksempeloppsettet ble «4. rekke» dyttet 7 px til
venstre, resten sto urørt.

**Målt før og etter, antall etiketter som ligger oppå en boks:**

| Oppsett | Før | Etter |
|---|---|---|
| 4 rader, 35 plasser | 3 | **0** |
| Lange radnavn, 3 rader | 3 | **0** |
| 6 rader | 3 | **1** |

Null kollisjoner med Dirigent og null utenfor kartet i alle fem oppsettene
som ble testet (også flate rader, venstre/høyre-fløyer og én enkelt solist).

**Analysen i «Hvorfor ikke flytte etiketten» over holder fortsatt** — den er
ikke motbevist, bare avgrenset. Regnestykket der sier at etiketten trenger
~40 px for å klarere boksen, mens radavstanden kan komme ned i ~39 px ved
mange rader. Målingen bekrefter det: 6-raders oppsettet er nettopp det ene
tilfellet som fortsatt kolliderer. Flyttingen løser altså de vanlige
oppsettene, ikke geometrien i seg selv. Derfor er hevingen **ikke** reversert
— de to grepene dekker hver sin del av problemet.

**Det som gjenstår, ærlig sagt:**

- **Ett tilfelle igjen med 6 rader** der en etikett fortsatt lander på en
  boks. Den er lesbar, fordi `z-index:3` er beholdt — det er nettopp derfor
  hevingen ikke ble reversert.
- **To etiketter kan overlappe hverandre** ved svært lange radnavn. Dette er
  **ikke nytt** — det ble målt til å skje like mye med den gamle
  plasseringen, så det er en eksisterende svakhet og ikke en følgefeil.
  Eget kort hvis det blir plagsomt.

**Verifisert uten innlogging:** appen krever pålogging, så oppstillingene ble
bygget syntetisk i nettleseren og `renderFormation()` kalt direkte.
