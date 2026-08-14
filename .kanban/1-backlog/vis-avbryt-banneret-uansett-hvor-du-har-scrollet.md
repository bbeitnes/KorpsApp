---
title: Vis Avbryt-banneret uansett hvor du har scrollet
created: 2026-08-14
updated: 2026-08-14
---

## Mål

Når du flytter en plass i Korpsoppsett, skal banneret «↔️ Trykk der plassen
skal flyttes · Avbryt» alltid være synlig — også når du har scrollet ned i et
stort oppsett. I dag er banneret festet til toppen av selve diagrammet, ikke
til skjermen, så det havner utenfor synsfeltet og brukeren finner ikke
«Avbryt».

## Plan

- [ ] Bestem plassering: `position: fixed` nær toppen av skjermen, eller
      `sticky` innenfor scrollområdet. Fixed er enklest og virker likt på
      mobil og desktop.
- [ ] Endre banneret i `renderFormation()` — [index.html:3011](../../index.html)
- [ ] Sjekk at banneret ikke legger seg oppå topplinja (z-index) eller over
      «...»-menyen på mobil
- [ ] Sjekk at det forsvinner som før når du trykker Avbryt eller fullfører
      flyttingen

## Verifisering

- [ ] Stort oppsett, scrollet langt ned: trykk et plassert sete → «↔️ Flytt».
      Banneret skal være synlig med én gang, uten å scrolle.
- [ ] «Avbryt» avbryter flyttingen
- [ ] Testet på https://beitnes.net/Korpsapp-test på både mobil og desktop
- [ ] Merget til `main`

## Notater

Oppdaget 2026-08-14 under testing av fargerefaktoreringen (steg 4).

Var mistenkt for å være en regresjon fra fargeendringen, men er det ikke.
Undersøkt og utelukket:

- Eneste forskjell på linja er `#4f46e5` → `var(--farge-primar)` og
  `white` → `var(--farge-tekst-invers)`. Plassering og struktur er uendret.
- Begge variablene er definert og gir hvit tekst på lilla — målt i nettleser.
- Publisert fil på test er byte-identisk med lokal fil, så ikke cache/deploy.
- Banneret og «Avbryt»-lenka ligger faktisk i DOM-en — reprodusert ved å
  kalle `startMoveFormationSeat()` direkte.

Årsaken er plasseringen: banneret er `position:absolute; top:4px` inne i
`#formation-canvas`, som er `position:relative` og like høyt som hele
diagrammet ([index.html:445](../../index.html)). Det sitter altså i toppen av
diagrammet, ikke i toppen av skjermen.

Feilen er ikke ny — banneret har alltid ligget slik.
