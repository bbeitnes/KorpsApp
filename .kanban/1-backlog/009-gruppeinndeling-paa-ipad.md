---
title: Gruppeinndeling på iPad
created: 2026-08-16
updated: 2026-08-16
---

## Mål

Gruppeinndeling skal kunne brukes fra iPad: sette en gruppeleder, legge til og
fjerne deltakere, og låse en gruppe.

**Venter på piloten.** `korpsoppsett-maa-kunne-brukes-fra-ipad` setter
mønsteret først. Ikke start dette før piloten er i `4-done`.

Dette er det **svakeste kortet av de tre oppfølgerne** når det gjelder touch,
og det bør tas sist. Gruppeinndeling har to ulike slipp-mål på samme kort —
lederfeltet og selve kortet — som skiller mellom hverandre utelukkende ved
hjelp av `dataTransfer`-nøkkelen `application/x-gruppeleder`
([index.html:3919](../../index.html)). Den nøkkelen finnes bare i en
dra-og-slipp-hendelse. Det finnes ingen tilsvarende trykk-vei som skiller
«dette navnet skal bli leder» fra «dette navnet skal bli deltaker».

## Plan

- [ ] Kartlegg om det i det hele tatt går an å sette en **gruppeleder** med
      trykk. `assignTeamLeader` ([index.html:3924](../../index.html)) kalles
      i dag bare fra `drop`-handleren på `.team-leader-slot`. Finn ut om det
      finnes noen trykk-vei dit — hvis ikke, er dette funksjonalitet som
      mangler på touch, ikke en bug.
- [ ] Verifiser å legge til **deltaker** med trykk via `teamAddSlotClick`
      ([index.html:3957](../../index.html)), som er koblet på
      `.room-slot.add-team-participant`
      ([index.html:3854](../../index.html)). Denne veien finnes, og er
      sannsynligvis den som allerede virker.
- [ ] Sjekk hva som skjer når et navn slippes/trykkes på kortet mens det
      finnes gruppeledere. `drop`-handleren avviser vanlige navn på
      lederfeltet når `state.groupLeaders.length > 0`
      ([index.html:3921](../../index.html)) — nok en taus `return`.
- [ ] Verifiser fjerning av deltaker og låsing av gruppe, som for rom/vakter.
- [ ] Bestem hvordan leder-vs-deltaker skal skilles med trykk. Det er den
      egentlige designoppgaven i dette kortet, og den kan ikke løses ved å
      kopiere piloten — Korpsoppsett har ikke to konkurrerende slipp-mål.
- [ ] Test i fullskjerm (≥1024px) og i Split View (<1024px).

Uavklart: Hvordan gruppeleder settes med trykk. Dette er en reell designbeslutning
— egen knapp på lederfeltet, et valg i en dialog, eller en modus-bryter — og
den bør trolig grilles for seg når kortet skal startes.

Uavklart: Tilbakemeldingsmønsteret fra piloten. Fjernes når piloten er ferdig.

## Verifisering

- [ ] Testet på https://beitnes.net/Korpsapp-test
- [ ] Merget til `main`

## Notater

**Hvorfor dette er et eget kort selv om det deler `renderGroups` med rom og
vakter:** funksjonen greiner av på `kind === 'team'`
([index.html:3745](../../index.html)) og bygger sin egen kortstruktur med
lederfelt og deltakerliste, med egne handlere
([index.html:3912–3937](../../index.html)). Rom og vakter deler kodevei fullt
ut med hverandre; gruppeinndeling gjør det ikke.

**Hvorfor det er verst stilt:** de andre modusene har én ting et trykk kan
bety per mål. Gruppeinndeling har to mål på samme kort, og skiller dem på
data som bare finnes i en dra-hendelse. Det er den eneste modusen der
touch-støtte krever en *ny* interaksjonsidé i stedet for å synliggjøre en som
allerede finnes.

**Opphav:** skilt ut fra `korpsoppsett-maa-kunne-brukes-fra-ipad` etter
grillingen 2026-08-16. Rekkefølgen mellom oppfølgerne bør være
konsertsal → rom og vakter → gruppeinndeling, altså lettest først.
