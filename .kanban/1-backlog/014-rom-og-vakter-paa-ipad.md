---
title: Rom og vakter på iPad
created: 2026-08-16
updated: 2026-08-16
---

## Mål

Romfordeling og vaktlister skal kunne brukes fra iPad: legge et navn i en
plass, fjerne det igjen, og låse/åpne en rad.

**Venter på piloten.** `korpsoppsett-maa-kunne-brukes-fra-ipad` setter
mønsteret for tilbakemelding og synlighet først. Ikke start dette før piloten
er i `4-done`.

Rom og vakter er **ett kort fordi de er én kodevei**: begge går gjennom
`renderGroups(kind)` ([index.html:3728](../../index.html)) og
`groupSlotClick` ([index.html:4134](../../index.html)), med `kind` som eneste
forskjell. Å dele dem i to kort ville betydd å teste den samme koden to
ganger.

Som konsertsalen er forventningen at dette **stort sett virker allerede** —
`groupSlotClick` åpner `showGroupAssignDialog` når ingenting er valgt, altså
den reserveveien Korpsoppsett mangler.

## Plan

- [ ] Verifiser på enhet i romfordeling: trykk en tom plass uten valgt navn →
      `showGroupAssignDialog` skal åpne ([index.html:4134](../../index.html)).
- [ ] Verifiser med valgt navn: velg i sidepanelet, trykk plass, navnet skal
      legges rett inn.
- [ ] Verifiser fjerning via `.remove-occ`
      ([index.html:3807](../../index.html)). Den er en liten `✕` inne i en
      plass — mål trykkmålet mot `--tap-min` på `44px`
      ([index.html:190](../../index.html)), for dette er den mest sannsynlige
      touch-fella i denne modusen.
- [ ] Verifiser låsing med `.confirm-toggle`
      ([index.html:3795](../../index.html)), og at en låst rad avviser trykk
      på en forståelig måte — i dag returnerer `groupSlotClick` tomt når
      `g.confirmed` er satt, altså nok en taus vei.
- [ ] Gjenta hele runden for vakter. Merk den ene reelle forskjellen:
      vakter er ikke-eksklusive, så `unassignExclusive` hoppes over for
      `kind === 'shift'` ([index.html:4143](../../index.html)) — samme person
      kan stå på flere vakter.
- [ ] Sjekk reiseleder-særtilfellet i romfordeling: `groupSlotClick` bruker
      `selectedReiseleder` som reserve når ingen navn er valgt
      ([index.html:4141](../../index.html)). To ulike lister mater samme
      plass, så det er verdt et eget trykk-gjennomløp.
- [ ] Rull ut tilbakemeldings- og synlighetsmønsteret fra piloten.
- [ ] Test både i fullskjerm (≥1024px) og i Split View (<1024px).

Uavklart: Hvilket tilbakemeldingsmønster som skal kopieres — avgjøres i
piloten. Fjernes når piloten er ferdig.

## Verifisering

- [ ] Testet på https://beitnes.net/Korpsapp-test
- [ ] Merget til `main`

## Notater

**Hvorfor rom og vakter er slått sammen:** `groupsFor(kind)`
([index.html:3727](../../index.html)) velger bare hvilken tilstandsliste som
brukes; rendering og klikkhåndtering er identisk. Gruppeinndeling deler
riktignok `renderGroups` med dem, men greiner av i sin egen rendering inne i
funksjonen ([index.html:3745](../../index.html)) og har egne handlere —
derfor er *den* et eget kort.

**Den viktige forskjellen fra Korpsoppsett**, funnet under grillingen
2026-08-16: `groupSlotClick` faller tilbake til `showGroupAssignDialog` når
ingenting er valgt. `formationCanvasClick`
([index.html:3464](../../index.html)) har ingen slik gren. Det er trolig
grunnen til at Korpsoppsett er den eneste modusen som er rapportert ødelagt
på iPad.

**Mistenkt touch-svakhet allerede nå:** `.remove-occ` er en liten `✕` plassert
inne i en plass, og den har `e.stopPropagation()` slik at den ikke utløser
`groupSlotClick`. Med finger i stedet for mus er det lett å bomme på grensa
mellom «fjern» og «åpne plassen». Det er den ene tingen i denne modusen jeg
ville testet først.

**Opphav:** skilt ut fra `korpsoppsett-maa-kunne-brukes-fra-ipad` etter
grillingen 2026-08-16.
