---
title: Rom og vakter på iPad
created: 2026-08-16
updated: 2026-08-19
---

## Mål

Romfordeling og vaktlister skal kunne brukes fra iPad: legge et navn i en
plass, fjerne det igjen, og låse/åpne en rad.

**Venter på piloten.** `korpsoppsett-maa-kunne-brukes-fra-ipad` setter
mønsteret for tilbakemelding og synlighet først. Ikke start dette før piloten
er i `4-done`.

Rom og vakter er **ett kort fordi de er én kodevei**: begge går gjennom
`renderGroups(kind)` ([index.html:4012](../../index.html)) og
`groupSlotClick` ([index.html:4418](../../index.html)), med `kind` som eneste
forskjell. Å dele dem i to kort ville betydd å teste den samme koden to
ganger.

Som konsertsalen er forventningen at dette **stort sett virker allerede** —
`groupSlotClick` åpner `showGroupAssignDialog` når ingenting er valgt, altså
den reserveveien Korpsoppsett mangler.

## Plan

- [ ] Verifiser på enhet i romfordeling: trykk en tom plass uten valgt navn →
      `showGroupAssignDialog` skal åpne ([index.html:4418](../../index.html)).
- [ ] Verifiser med valgt navn: velg i sidepanelet, trykk plass, navnet skal
      legges rett inn.
- [ ] Verifiser fjerning via `.remove-occ`
      ([index.html:4091](../../index.html)). Den er en liten `✕` inne i en
      plass, uten egen CSS-regel for størrelse (arver kun `text-lg
      leading-none`, ingen padding) — mål trykkmålet mot `--tap-min` på
      `44px` ([index.html:177](../../index.html)) på ekte enhet, for dette er
      den mest sannsynlige touch-fella i denne modusen.
- [ ] Legg til `showFlash`-melding når en låst rad trykkes —
      `groupSlotClick` returnerer i dag tomt når `g.confirmed` er satt
      ([index.html:4421](../../index.html)), uten et ord til brukeren.
- [ ] Legg til `showFlash`-melding når en FYLT plass trykkes andre steder enn
      selve `✕`-en — `groupSlotClick` returnerer i dag tomt når
      `g.occupants[slotIdx]` finnes ([index.html:4422](../../index.html)).
      **Merk:** dette er ikke en iPad-spesifikk feil (musepekere rammes
      likt), men avgjort i grillingen at det tas med her siden koden
      uansett røres — meldingsvarianten, ikke en full bytte-dialog (se
      Notater).
- [ ] Gjenta hele runden for vakter. Merk den ene reelle forskjellen:
      vakter er ikke-eksklusive, så `unassignExclusive` hoppes over for
      `kind === 'shift'` ([index.html:4429](../../index.html)) — samme person
      kan stå på flere vakter.
- [ ] Sjekk reiseleder-særtilfellet i romfordeling: `groupSlotClick` bruker
      `selectedReiseleder` som reserve når ingen navn er valgt
      ([index.html:4426](../../index.html)). To ulike lister mater samme
      plass, så det er verdt et eget trykk-gjennomløp.
- [ ] Legg til banneret («👇 Trykk der X skal stå»,
      `selectionBannerHtml` — generalisert fra piloten under kort 010,
      [index.html:3735](../../index.html)) i `renderGroups`
      ([index.html:4012](../../index.html)) når et navn/reiseleder er valgt.
      Samme avgjørelse som i konsertsalen: legges til for konsistens, selv om
      `showGroupAssignDialog` gjør det strengt tatt valgfritt.
- [ ] Test både i fullskjerm (≥1024px) og i Split View (<1024px).

## Verifisering

- [ ] Testet på https://beitnes.net/Korpsapp-test
- [ ] Merget til `main`

## Notater

**Hvorfor rom og vakter er slått sammen:** `groupsFor(kind)`
([index.html:4011](../../index.html)) velger bare hvilken tilstandsliste som
brukes; rendering og klikkhåndtering er identisk. Gruppeinndeling deler
riktignok `renderGroups` med dem, men greiner av i sin egen rendering inne i
funksjonen ([index.html:4029](../../index.html)) og har egne handlere —
derfor er *den* et eget kort.

**Den viktige forskjellen fra Korpsoppsett**, funnet under grillingen
2026-08-16: `groupSlotClick` faller tilbake til `showGroupAssignDialog` når
ingenting er valgt. `formationCanvasClick`
([index.html:3692](../../index.html)) har ingen slik gren. Det er trolig
grunnen til at Korpsoppsett er den eneste modusen som er rapportert ødelagt
på iPad.

**Mistenkt touch-svakhet allerede nå:** `.remove-occ` er en liten `✕` plassert
inne i en plass, og den har `e.stopPropagation()` slik at den ikke utløser
`groupSlotClick`. Med finger i stedet for mus er det lett å bomme på grensa
mellom «fjern» og «åpne plassen». Det er den ene tingen i denne modusen jeg
ville testet først.

**Opphav:** skilt ut fra `korpsoppsett-maa-kunne-brukes-fra-ipad` etter
grillingen 2026-08-16.

### Tilbakemeldingsmønster og banner (grillet 2026-08-19)

Alle tre spørsmål besvart likt: følg kort 010 sin presedens.

- **Låst rad:** legg til `showFlash`-melding. Samme begrunnelse som resten av
  piloten — en taus `return` er alltid verdt å fikse når koden uansett røres.
- **Trykk på fylt plass:** legg til en `showFlash`-melding (ikke en full
  bytte-dialog). Viktig funn underveis: dette er *ikke* en iPad-spesifikk
  feil — `groupSlotClick` sin tause `return` når `g.occupants[slotIdx]`
  finnes rammer museklikk akkurat like mye som trykk, siden rom/vakter aldri
  har vært avhengig av dra-og-slipp slik Korpsoppsett var. Vurdert å skille
  det ut som eget kort, men landet på å ta det med her siden det er billig og
  koden uansett skal endres i denne modusen.
- **Banner:** legges til, samme avveining som konsertsalen (kort 010) —
  ikke strengt nødvendig siden `showGroupAssignDialog` er en fullverdig
  reservevei, men holder trykkveien synlig og konsekvent på tvers av
  modusene.
