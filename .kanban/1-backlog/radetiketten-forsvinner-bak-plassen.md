---
title: Radetiketten forsvinner bak plassen i Korpsoppsett
created: 2026-08-14
updated: 2026-08-14
---

## Mål

I Korpsoppsett blir radnavnet dekket av boksen til musikeren som står først i
raden. Etter dette skal radnavnet være lesbart også når plassen er fylt.

Løsningen er å heve radetiketten over boksene i lagdelingen — ikke å flytte
den. Grillingen 2026-08-14 viste at det ikke finnes ledig plass å flytte den
til, verken over, under eller til siden. Se «Notater».

## Plan

- [ ] Hev `z-index` på radetiketten fra `1` til `3`
      ([index.html:3191](../../index.html), `formationRowLabelHtml`).
      Boksene ligger på `2`, så `3` er nok. Hold deg under `5` — der ligger
      «Trykk der plassen skal flyttes»-banneret, som skal vinne.
- [ ] Rett opp følgefeilen på tooltip-en: `.tooltip`
      ([index.html:453](../../index.html)) har `z-index: 20`, men ligger
      *inne i* boksen, som har `z-index:2` og `position:absolute` og dermed
      lager sin egen stablingskontekst. Tooltip-en er derfor låst til nivå 2
      og blir dekket av en etikett på nivå 3. Navnet på musikeren må fortsatt
      kunne leses ved hover.
- [ ] Merk at boksens `z-index:2` er satt **inline**
      ([index.html:3299](../../index.html)). En CSS-regel som
      `.seat:hover { z-index: 4 }` slår derfor ikke gjennom uten
      `!important` — eller så må `z-index` flyttes ut av inline-stilen og
      inn i `.seat`-klassen.
- [ ] Sjekk at etikettens halvgjennomsiktige bakgrunn
      (`rgba(var(--farge-bakgrunn-rgb), .9)`) er lesbar oppå et foto, ikke
      bare oppå initialer på ensfarget bunn.

## Verifisering

- [ ] Plasser en musiker først i raden (`t = 0`) — radnavnet skal være lesbart
      oppå boksen
- [ ] Hold musepekeren over nettopp den musikeren — tooltip-en med fullt navn
      skal fortsatt være lesbar, ikke dekket av radetiketten
- [ ] Sjekk både med foto og med initialer
- [ ] Sjekk dra-og-slipp: etiketten har `pointer-events:none`, så den skal
      ikke stjele klikk selv når den ligger øverst
- [ ] Sjekk en `right`-justert rad spesielt — der ligger `t = 0` øverst i
      midten, ikke til venstre som i de andre radformene
- [ ] Testet på https://beitnes.net/Korpsapp-test
- [ ] Merget til `main`

## Notater

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
