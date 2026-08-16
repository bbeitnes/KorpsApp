---
title: Korpsoppsett må kunne brukes fra iPad
created: 2026-08-16
updated: 2026-08-16
---

## Mål

Korpsoppsett skal kunne brukes helt ut fra en iPad: plassere en musiker,
flytte en plass, bytte navn og fjerne en plass — uten mus og uten at noe
krever et dra-og-slipp som iOS Safari ikke støtter. Dette kortet er først og
fremst en **kartlegging**: finn ut hva som faktisk ryker på iPad, og fiks det
som ryker.

Utgangspunktet er at hoved­interaksjonen i dag er HTML5 drag-and-drop
(`draggable="true"` + `dragstart`/`dragover`/`drop`), som **ikke virker med
touch i iOS Safari**. Det finnes en trykk-basert reservevei
([index.html:3462](../../index.html)), men den er aldri verifisert på ekte
iPad, og den er ikke synlig i grensesnittet — ingenting forteller brukeren at
den finnes.

## Plan

- [ ] Kartlegg hele trykkveien for **ny plassering**: velg navn i sidepanelet
      (`selectName`, [index.html:2449](../../index.html)) → trykk på lerretet
      (`formationCanvasClick`, [index.html:3464](../../index.html)).
      Sjekk at et valgt navn faktisk er synlig valgt etter at sidepanelet er
      lukket.
- [ ] Kartlegg trykkveien for **flytting**: trykk plass → modal → «↔️ Flytt»
      ([index.html:3575](../../index.html)) → trykk der plassen skal stå
      (`startMoveFormationSeat` + banneret på
      [index.html:3320](../../index.html)).
- [ ] Test i **begge orienteringer**. Grensa på `1024px`
      ([index.html:270](../../index.html)) deler iPad i to helt ulike
      oppsett: liggende (≥1024) har fast sidepanel, stående (768–834) har
      sidepanelet som overlegg med bakteppe. Trykkveien over er bare testet
      i tankene på det liggende.
- [ ] Se på at `selectName` **ikke lukker sidepanelet**
      ([index.html:2449](../../index.html)). I stående orientering ligger
      sidepanelet oppå lerretet, så brukeren må velge navn, lukke panelet og
      så treffe riktig punkt på et lerret hen ikke så da valget ble tatt.
- [ ] Mål trykkmålene på plassene. `--tap-min` er `44px`
      ([index.html:190](../../index.html)) og håndheves bare på `.btn`
      ([index.html:419](../../index.html)). `computeAutoSeatSize`
      ([index.html:3143](../../index.html)) krymper plassene fritt under 44px
      når raden er trang.
- [ ] Sjekk at `formationCanvasClick` sin `if (e.target.closest('.seat')) return;`
      ([index.html:3465](../../index.html)) ikke gjør det umulig å slippe en
      plass i et tett område — med små plasser i en full rad kan det være
      lite bar bakgrunn igjen å treffe.
- [ ] Sjekk at vanlig rulling og knipe-zooming på lerretet ikke utløser en
      utilsiktet plassering. `#formation-canvas` har `onclick` direkte på seg
      ([index.html:720](../../index.html)).
- [ ] Bestem om trykkveien skal **gjøres synlig** i grensesnittet, eller bare
      virke for den som gjetter den. I dag står det ingen steder at man kan
      velge et navn og trykke på kartet.
- [ ] Fiks det kartleggingen finner, og skriv i `## Notater` hva som virket
      fra før — det er halve verdien av kortet.

Uavklart: Hva testes det på? Ekte iPad, iPad-simulator med Safari mot
https://beitnes.net/Korpsapp-test, eller nettleserens touch-emulering? De tre
gir ulikt svar, særlig på dra-og-slipp: emulering kan vise en «virker»-fasit
som ekte iOS Safari ikke deler.

Uavklart: Hvor mye er i scope? Bare Korpsoppsett, eller er dette egentlig
starten på touch-støtte for hele appen? Navnelista, `renderConcert`,
gruppene og romfordelingen bruker nøyaktig samme dra-og-slipp-mønster og har
samme problem.

Uavklart: Er dra-og-slipp med finger et *mål*, eller holder det at trykkveien
er komplett og synlig? Det første betyr `pointerdown`/`pointermove` slik
`.reorder-handle` allerede gjør ([index.html:4883](../../index.html)) — en
mye større jobb enn det andre.

Uavklart: Hvilken iPad-modell og hvilken iPadOS-versjon skal være
referansen? Bredden avgjør hvilken side av `1024px`-grensa man havner på, og
dermed hvilket av de to oppsettene som er «det normale».

## Verifisering

- [ ] Testet på https://beitnes.net/Korpsapp-test
- [ ] Merget til `main`

## Notater

**Funnet under skrivingen av kortet (2026-08-16), ikke verifisert på enhet:**

Korpsoppsett har to parallelle interaksjonsveier inn i samme funksjon
`placeFormationSeat`:

1. **Dra-og-slipp** — `attachFormationCanvasHandlers`
   ([index.html:3431](../../index.html)) setter `ondragover`/`ondrop` på
   lerretet, og hver plass er `draggable="true"`
   ([index.html:3344](../../index.html)). Dette er HTML5-drag-API-et, som
   iOS Safari ikke utløser fra touch.
2. **Trykk** — `formationCanvasClick` ([index.html:3464](../../index.html)).
   Kommentaren over funksjonen kaller den selv «Touch-fallback», så
   forfatteren har tenkt tanken. Om den er kjørt på en iPad vet vi ikke.

`.reorder-handle` ([index.html:306](../../index.html), logikken på
[index.html:4883](../../index.html)) er verdt å merke seg som presedens: den
er bevisst skrevet med `pointerdown`/`pointermove` og `touch-action: none`
nettopp for å virke likt med mus og touch. Det finnes altså allerede et
mønster i denne kodebasen for hvordan ekte fingerdrag gjøres — hvis det er
dit dette kortet skal.

**Beslektet kort:** `radetiketten-forsvinner-bak-plassen` (i `review`) rører
`z-index` og `:hover` i det samme lerretet. `:hover` er i praksis meningsløst
på touch, så den løsningen bør ses igjennom på nytt her — en tooltip som bare
kommer fram ved hover, kommer aldri fram på en iPad.
