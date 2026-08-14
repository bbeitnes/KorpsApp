---
title: Fjern unødvendige 404-er ved lasting av instrumentbilder
created: 2026-08-14
updated: 2026-08-14
---

## Mål

Slutte å be om filer som ikke finnes. I dag gir hver lasting av
standardbildene 12 mislykkede forespørsler i nettleserkonsollen. Bildene
vises riktig, så dette er kun støy — men støy som skjuler ekte feil når man
først åpner konsollen.

## Plan

- [ ] Bytt rekkefølgen i `INSTRUMENT_PHOTO_EXTS` slik at `jpeg` kommer først
      — [index.html:2473](../../index.html)
- [ ] Vurder om lista fortsatt trenger alle fire endelsene, eller om den kan
      kortes ned til de som faktisk brukes

## Verifisering

- [ ] Åpne konsollen, last appen, gå til Slagverkslista: ingen 404-er
- [ ] Alle 12 instrumentbildene vises fortsatt
- [ ] Legg inn et eget bilde manuelt og sjekk at det fortsatt virker
- [ ] Testet på https://beitnes.net/Korpsapp-test
- [ ] Merget til `main`

## Notater

Oppdaget 2026-08-14 under testing av fargerefaktoreringen (steg 4). Ikke
relatert til den — feilen er der fra før.

Årsak: `INSTRUMENT_PHOTO_EXTS = ['jpg', 'jpeg', 'png', 'webp']` prøver
endelsene i rekkefølge, og alle 12 filene i `instrument-photos/` er `.jpeg`.
Første forsøk (`.jpg`) feiler alltid, andre forsøk (`.jpeg`) lykkes alltid.
`loadDefaultInstrumentPhoto()` er skrevet for å tåle det — den fanger feilen
og prøver neste endelse — så bildene kommer opp som de skal.

Én ordbytte fikser alle 12. Lav risiko, men det ER en oppførselsendring, så
den bør ligge i sin egen commit.
