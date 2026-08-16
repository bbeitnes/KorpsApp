---
title: Konsertsal på iPad
created: 2026-08-16
updated: 2026-08-16
---

## Mål

Konsertsal skal kunne brukes fra iPad: tildele et navn til en plass, bytte
navn og fjerne en tildeling.

**Venter på piloten.** `korpsoppsett-maa-kunne-brukes-fra-ipad` går opp
trykkveien først og setter mønsteret for tilbakemelding og synlighet. Dette
kortet ruller ut det samme til konsertsalen. Ikke start dette før piloten er
i `4-done`.

Forventningen er at konsertsalen står **mye bedre** enn Korpsoppsett gjorde,
fordi `seatClick` allerede har en fullverdig reservevei: trykker man en tom
plass uten å ha valgt et navn, åpnes `showAssignDialog`
([index.html:3548](../../index.html)). Det er nettopp den veien Korpsoppsett
mangler. Kortet er derfor mest sannsynlig verifisering pluss små justeringer,
ikke en ny bug-jakt — men det er en forventning, ikke en konklusjon.

## Plan

- [ ] Verifiser tildeling på enhet: trykk en tom plass uten valgt navn →
      `showAssignDialog` skal åpne og la deg velge derfra
      ([index.html:3548](../../index.html)).
- [ ] Verifiser den andre veien: velg navn i sidepanelet først, trykk så en
      tom plass — da skal navnet plasseres direkte uten dialog.
- [ ] Verifiser bytte og fjerning via `showSeatOptions`
      ([index.html:3573](../../index.html)). Merk at «↔️ Flytt» med vilje
      ikke finnes i konsertsal — plassene er faste, så det er riktig.
- [ ] Sjekk at et allerede tildelt navn i navnelista oppfører seg forståelig.
      Det kaller `locateName` ([index.html:2411](../../index.html)), som
      ruller til plassen og blinker — bekreft at blinket faktisk er synlig på
      iPad-skjermen etter rullingen.
- [ ] Rull ut tilbakemeldings- og synlighetsmønsteret fra piloten, slik at et
      trykk som ikke fører fram sier fra.
- [ ] Test både i fullskjerm (≥1024px) og i Split View (<1024px) på iPad Pro
      12,9" (5. gen).

Uavklart: Nøyaktig hvilket tilbakemeldings- og synlighetsmønster som skal
kopieres — det avgjøres i piloten. Denne linja skal fjernes når piloten er
ferdig, ikke før.

## Verifisering

- [ ] Testet på https://beitnes.net/Korpsapp-test
- [ ] Merget til `main`

## Notater

**Hvorfor dette er et eget kort:** `renderConcert`
([index.html:3022](../../index.html)) er sin egen renderingsvei, atskilt fra
både Korpsoppsett og gruppekortene. Plassene er faste båser med `data-seat`,
ikke fri plassering på et lerret.

**Den viktige forskjellen fra Korpsoppsett**, funnet under grillingen
2026-08-16: `seatClick` faller tilbake til `showAssignDialog` når ingenting er
valgt. `formationCanvasClick` ([index.html:3464](../../index.html)) har ingen
tilsvarende gren — i Korpsoppsett finnes et sete bare når det har et navn, så
det er ingen tom plass å trykke på, og et trykk på tomt lerret uten valgt navn
gjør bokstavelig talt ingenting. Det er sannsynlig at nettopp dette er grunnen
til at Korpsoppsett feilet på iPad mens de andre modusene ikke har vært
rapportert.

**Opphav:** skilt ut fra `korpsoppsett-maa-kunne-brukes-fra-ipad` etter
grillingen 2026-08-16, der det ble slått fast at trykkveien allerede er koblet
opp i alle modusene og at oppgaven er å verifisere og synliggjøre den, ikke å
bygge den.
