---
title: Fjern grenselinjene i Korpsoppsett
created: 2026-08-18
updated: 2026-08-18
---

## Mål

Kartet i Korpsoppsett skal vise **én** type linje: radens egen midtlinje, den
man sikter mot. De stiplede grenselinjene mellom radene forsvinner, og
forklaringen over kartet krymper til én linje i stedet for to.

Begrunnelsen er at midtlinjene i dag er tydelige nok alene. Grenselinjene ble
laget da de ikke var det.

## Plan

- [ ] Fjern grenselinje-løkka i `formationGuidesSvg`
      ([index.html:3330](../../index.html)) — hele `for`-løkka som regner ut
      `boundaryRadius`, `bowKs` og `boundaryGeom`. Midtlinje-løkka rett under
      blir stående uendret.
- [ ] Fjern «Grense mot naborad» fra forklaringen over kartet
      ([index.html:745](../../index.html)). Da står bare «Plasser her» igjen —
      vurder om én enslig forklaring fortsatt gir mening, eller om den også
      kan gå. Uavklart: skal «Plasser her» bli stående alene?
- [ ] Rydd kommentaren over `formationGuidesSvg`. Den forklarer i dag hvorfor
      det er *to* linjespråk («midtlinjen er heltrukket … grenselinjen er en
      svak, tynn stiplet bakgrunnsreferanse»). Med ett språk igjen er halve
      forklaringen feil, ikke bare overflødig.
- [ ] Sjekk om noe annet leser grensegeometrien. `formationSampledPath` brukes
      både til midtlinjen og til den syntetiske grense-sonen — den skal
      bestå. `resolveFormationDrop` regner ut radbytte helt uavhengig av
      SVG-en, så selve treffelogikken endres ikke av dette.
- [ ] Se på kartet med 4–6 rader og sjekk at radene fortsatt lar seg skille
      fra hverandre uten grenselinjene — særlig der to rader ligger tett.
      Uavklart: hva er testen på at de «lar seg skille»? Ren øyemåling, eller
      et konkret oppsett som må se riktig ut?

## Verifisering

- [ ] Testet på https://beitnes.net/Korpsapp-test
- [ ] Merget til `main`

## Notater

### Hva som faktisk fjernes

Grenselinjen er den stiplede rav-/amberfargede buen midt mellom to rader. Den
tegnes i `formationGuidesSvg`, som kun brukes på skjerm — utskriften
(`buildFormationPrintHtml`) tegner ingen linjer i det hele tatt, så
**utskrift/PDF er uberørt** av dette kortet.

Kartet har i dag tre lag: grenselinjene, radenes midtlinjer, og boksene med
navn. Dette kortet fjerner det første laget.

### Linjene ble bygget over fem runder

De er ikke noe som havnet der ved et uhell — de ble laget, og så justert fire
ganger til:

| dato | commit |
|---|---|
| 2026-07-31 | Vis grenselinjer mellom rader på kartet |
| 2026-07-31 | Tydeligere farger for midtlinje vs. grenselinje |
| 2026-07-31 | Grenselinjer mot en slak rad følger samme buform |
| 2026-08-01 | Gjør grenselinjen litt tydeligere (tykkere, tettere prikker, høyere opasitet) |
| 2026-08-01 | Tydeligere skille mellom plasseringslinje og grenselinje |

Rekkefølgen er verdt å lese: linjene ble først gjort **tydeligere**, og
deretter måtte midtlinjen gjøres tydeligere igjen for å vinne tilbake
oppmerksomheten. Det er mønsteret til to elementer som konkurrerer. At
midtlinjen «er tydelig nok alene» i dag kan altså like gjerne være resultatet
av den siste runden som et argument for at den første var unødvendig.

Kommentaren i koden sier hva grenselinjen var *til*: den viser «hvor nærmeste
rad faktisk bytter» — altså hvilken rad et trykk lander i. Det er en reell
funksjon, ikke pynt. Spørsmålet kortet må svare på er om den funksjonen
fortsatt trengs, ikke om linjene er pene.

### Uavklart, til grillingen

1. **Har grenselinjene noen gang hindret en feilplassering?** De ble laget for
   å vise hvilken rad et slipp havner i. Har det skjedd at et navn havnet i
   feil rad, og linjen viste hvorfor? Uten et slikt tilfelle er de pynt, og da
   er kortet enkelt. Med et slikt tilfelle fjerner vi en sikring.
2. **Er det tettheten som har endret seg?** Kort 18 gjorde nettopp navnene
   lesbare på store oppstillinger. Hvis grenselinjene føles overflødige *nå*,
   er det verdt å vite om det er fordi kartet ble roligere av kort 18 — for da
   gjelder vurderingen kanskje bare de tette oppstillingene, og ikke de små.
3. **Skal «Plasser her» bli stående alene?** En forklaring med ett punkt
   forklarer lite. Enten går den også, eller så er den fortsatt verdt plassen
   fordi den sier hva den heltrukne linja *betyr*.
4. **Alt eller ingenting?** Alternativet til å fjerne dem er å dempe dem
   kraftig (de er allerede blitt tydeligere én gang — veien tilbake finnes).
   Skal kortet vurdere det, eller er beslutningen tatt?
