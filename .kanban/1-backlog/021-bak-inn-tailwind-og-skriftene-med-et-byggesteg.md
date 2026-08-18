---
title: Bak inn Tailwind og skriftene med et byggesteg
created: 2026-08-18
updated: 2026-08-18
---

## Mål

Appen henter i dag utseendet sitt fra servere vi ikke eier, uten
versjonsnummer. Faller `cdn.tailwindcss.com` bort eller endrer innhold, vises
appen som ustylet tekst for alle tre kunder — på en dag ingen har rørt koden.
Når dette er ferdig er både Tailwind og skriftene bakt permanent inn i det som
deployes, og utseendet kan ikke lenger endres utenfra.

## Plan

- [ ] Sett opp Tailwind som byggesteg i stedet for CDN-skriptet på
      [index.html:16](../../index.html) — pinnet til en konkret versjon
  - Fargekartet i `tailwind.config` (linje 35–101) må flyttes til
    byggoppsettet, men skal peke på de samme `--farge-*`-variablene
  - `rounded-*`- og `fontFamily`-overstyringene må bli med
- [ ] Last ned Source Serif 4 og legg skriftfilene i repoet. De hentes i dag
      fra `fonts.googleapis.com` og `fonts.gstatic.com`, begge uversjonert —
      og hele Broadsheet-uttrykket **er** serifen
- [ ] Legg byggesteget inn i alle tre deploy-workflowene før SFTP-steget.
      **Pass på kopier-så-slett-mønsteret for `config/`** — se CLAUDE.md; det
      må stå igjen intakt
- [ ] Rett `cache.addAll(ASSETS)` i [sw.js](../../sw.js): i dag er den
      alt-eller-ingenting, så feiler ett kall ved installasjon blir
      **ingenting** cachet — heller ikke `index.html`
- [ ] Bump cachenavnet `fordeling-v1`, som aldri har vært endret
- [ ] Vurder om Firebase-SDK-en (pinnet til 10.13.0) også skal bakes inn,
      eller om pinningen er beskyttelse nok
  - Uavklart: Firebase er den eneste av de fire som er versjonert. Er det
    verdt å ta den også, eller øker det bare størrelsen på bygget?

## Verifisering

- [ ] Appen ser helt lik ut før og etter — dette skal ikke endre utseendet
- [ ] Ingen forespørsler til `cdn.tailwindcss.com` eller `fonts.g*.com` i
      nettverksfanen etter endringen
- [ ] Konsollvarselet «cdn.tailwindcss.com should not be used in production»
      er borte
- [ ] Alle tre kunder får riktig `config.js` — sjekk at deployen fortsatt
      skiller dem
- [ ] Testet på https://beitnes.net/Korpsapp-test
- [ ] Merget til `main`

## Notater

Fra arkitekturgjennomgangen (kort #1, funn 1 og 2). Grillingen på kort #1
avgjorde allerede **at** dette skal gjøres: «CDN-risikoen skal fjernes, ikke
bare dokumenteres», og byggesteget er «akseptert med åpne øyne».

Prisen er forstått og godtatt: fila på serveren blir maskingenerert og kan
ikke lenger rettes for hånd — alt må gå via GitHub. Brekker bygget,
oppdateres ikke appen før noen teknisk har fikset det.

**Gjennomgangen fant at risikoen er bredere enn kort #1 antok.** Det er fire
eksterne avhengigheter, ikke én:

| Adresse | Versjon | Hva som ryker |
|---|---|---|
| `cdn.tailwindcss.com` | ingen | Alt utseende |
| `fonts.googleapis.com` | ingen | Source Serif 4 |
| `fonts.gstatic.com` | ingen | Samme |
| `gstatic.com/firebasejs/10.13.0` | pinnet | Innlogging og lagring |

Skriftene var ikke nevnt i kort #1, og de er like uversjonerte som Tailwind.

Service workeren cacher **kun** Tailwind — ikke skriftene, ikke Firebase. Og
beskyttelsen forutsetter at CDN-en var oppe da service workeren ble
installert, på grunn av `addAll`-oppførselen over.

Advarselen er bekreftet live på testsiden 2026-08-18: konsollen sier selv at
`cdn.tailwindcss.com` ikke er ment for drift.
