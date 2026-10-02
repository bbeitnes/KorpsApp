---
title: Firebase API-nøklene ut av repoet
created: 2026-10-01
updated: 2026-10-02
---

## Mål

Ingen API-nøkler i repoet, som er offentlig. Kundeoppsettene i `config/` får
en plassholder, og utrullingen setter inn nøkkelen fra en GitHub-secret.
Skiens skolemusikk bytter samtidig til den nye nøkkelen som Søknadsportal og
Bestillingsportal allerede bruker, så den gamle kan slettes i Google Cloud.

## Plan

- [x] `config/skolekorps.js` og `config/musikkforeningen-suoni.js`: `apiKey`
      blir `__FIREBASE_API_KEY__`
- [x] `deploy-test.yml` og `deploy.yml`: bytt plassholderen med secreten
      `FIREBASE_API_KEY`, stopp hvis secreten mangler eller plassholderen står igjen
- [x] `deploy-musikkforeningen-suoni.yml`: det samme med
      `FIREBASE_API_KEY_MUSIKKFORENINGEN_SUONI`
- [x] `index.html`: en `apiKey` som fortsatt er plassholderen gir
      «Kundeoppsettet mangler», med oppskrift for lokal kjøring
- [x] `CLAUDE.md`: regelen og tabellen over secrets
- [x] Secretene lagt inn i GitHub (gjøres av eier)

## Verifisering

- [x] Lokalt: `config.js` laget med samme `sed` som utrullingen, appen laster
      til innlogging med ren konsoll
- [x] Lokalt: `config.js` med plassholderen gir «Kundeoppsettet mangler»
- [x] Testet på https://beitnes.net/Korpsapp-test (innlogging, åpne et korps)
- [x] Merget til `main`
- [x] Sjekket prod: beitnes.net/Korpsapp og Musikkforeningen Suoni laster og
      logger inn

## Notater

- Grenen er laget fra `main`, ikke `test`: da kan endringen slippes til prod
  uten å ta med kortene som står i review på `test` (014, 020, 022, 027).
  Den merges først inn i `test` for verifisering.
- Skiens skolemusikk-nøkkelen deles med Bestillingsportal og Søknadsportal.
  Den lå i Søknadsportals og dette offentlige repoet, og byttes i alle tre.
  Bytte og begrensninger: Søknadsportals `OPPSETT.md` §8.
- Suoni har eget Firebase-prosjekt og egen nøkkel. Den ligger i historikken
  til dette repoet og bør byttes i det prosjektet for seg; dette kortet
  flytter den bare ut av filene.
- Historikken inneholder også nøkkelen til Kvinner i Kor (nedlagt, kort 27).
- GitHub Pages publiserer `main` rått, inkludert `config/`. Etter dette
  kortet ligger bare plassholderen der.
- Nettleseren må ha nøkkelen, så den er alltid lesbar på den utrullede siden.
  Beskyttelsen er Firestore-reglene og begrensningene på nøkkelen.
- 2026-10-01: Første utrulling til prod la Skiens-nøkkelen ut på Suoni-siden,
  fordi secreten `FIREBASE_API_KEY_MUSIKKFORENINGEN_SUONI` hadde fått feil
  verdi. Jobben ble grønn likevel — den sjekker bare at secreten finnes, ikke
  at nøkkelen hører til riktig prosjekt. Innloggingen hos Suoni var nede til
  secreten ble rettet 2026-10-02 og jobben kjørt på nytt.
- 2026-10-02: Suoni-nøkkelen ble byttet. Den gamle ble slettet før
  utrullingen med den nye var kjørt, så innloggingen falt ut én gang til. En
  secret tas ikke i bruk før jobben kjøres (Actions → «Run workflow»).
  Rekkefølgen er: ny nøkkel → secret → utrulling → sjekk → slett den gamle.
- Kontroll etter utrulling: kall `getProjectConfig` med nøkkelen fra den
  utrullede `config.js` og se at prosjektnummeret stemmer (Suoni:
  987449247681, Skiens skolemusikk: 125188360972).
