---
title: Instrumenttekst er for stor
created: 2026-08-14
updated: 2026-08-14
---

## Mål

Teksten på instrumentene skal være i rimelig størrelse. Meldt inn av bruker
2026-08-14 under testing.

**⚠️ Uavklart: hvilken skjerm gjelder det?** Må avklares før arbeidet starter,
ellers risikerer vi å endre feil sted.

## Plan

- [ ] Avklar med bruker hvilken av disse det gjelder:
      - navneetiketten over boksene i Korpsoppsett
        ([index.html:3043](../../index.html)) — skaleres med boksstørrelsen,
        `seatSize * 0.19` (eller `0.22` for store rader)
      - instrumentlista (Slagverkslista) i sidepanelet
      - initialene inne i selve boksen når instrumentet mangler bilde
        ([index.html:3027](../../index.html)) — `seatSize * 0.22`
- [ ] Se på skjermbilde fra bruker hvis mulig
- [ ] Finn ut om det gjelder alle oppsett eller bare tette/store rader
- [ ] Juster skaleringsfaktoren, eller sett et tak på skriftstørrelsen

## Verifisering

- [ ] Sjekk med både korte navn («Pauker») og lange («Skarptromme»)
- [ ] Sjekk et tett oppsett og et luftig oppsett — teksten skal ikke
      overlappe i det tette
- [ ] Sjekk at utskrift/PDF fortsatt ser riktig ut (egen skalering der)
- [ ] Testet på https://beitnes.net/Korpsapp-test
- [ ] Merget til `main`

## Notater

Oppdaget 2026-08-14 under testing av fargerefaktoreringen (steg 4). Ikke
forårsaket av den — fargecommitene inneholder ingen endringer i
skriftstørrelse i det hele tatt (verifisert med `git diff`).

Merk at dette er en ekte designendring, ikke en refaktorering. Den bør derfor
ikke blandes inn i fargearbeidet, som har «utseendet skal være 100 % identisk»
som krav.

Kommentaren i koden forklarer hvorfor skaleringen er som den er: etiketten er
mye bredere enn boksen, og var hovedårsaken til overlapping i tette oppsett
før den ble bundet til boksstørrelsen. En endring må ta hensyn til det.
