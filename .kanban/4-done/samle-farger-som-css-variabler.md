---
title: Samle farger som CSS-variabler
created: 2026-08-14
updated: 2026-08-14
---

## Mål

Forberede filen for et kommende redesign ved å samle alle farger ett sted.
Før dette lå fargene spredt: dels hardkodet i CSS-en og i JavaScript-koden,
dels i Tailwind-klasser — to systemer som måtte endres hver for seg.

Etter dette styrer én blokk (`:root`) hele utseendet. Endrer du én verdi der,
følger både den håndskrevne CSS-en og alle Tailwind-klassene etter.

**Kravet gjennom hele arbeidet: utseendet skal være 100 % identisk.**

## Plan

- [x] Steg 1 — `:root`-blokk med navngitte variabler (rent tillegg)
- [x] Steg 2 — 70 farger i hoved-CSS-blokken
- [x] Steg 3 — 7 gjennomsiktige farger (skygger, bakteppe, pulsering)
- [x] Steg 4 — 13 farger inne i JavaScript-koden
- [x] Steg 5 — 10 farger i utskrift/PDF
- [x] Steg 6 — Tailwind henter fargene fra paletten (309 klassebruk, 0 endret)

## Verifisering

- [x] Steg 1–5 verifisert ved å regne baklengs: hver `var(...)` byttet tilbake
      til verdien den peker på gir en fil som er tegn for tegn lik originalen
- [x] Steg 6 verifisert ved måling i nettleser: 39 av 39 fargetoner riktige,
      inkludert 3 kontrolltoner appen ikke bruker
- [x] Steg 1–5 testet på https://beitnes.net/Korpsapp-test
- [x] Steg 6 testet på https://beitnes.net/Korpsapp-test
- [x] Merget til `main`

## Notater

**Resultat:** 44 variabler, alle i bruk. Eneste hardkodede farger igjen er
Google-logoens fire merkefarger, som bevisst er latt urørt.

**Commits:** `b269828` (steg 1–2), `7ad04cd` (steg 3), `e78f418` (steg 4),
`96e1b46` (steg 5), `417bfbf` (steg 6).

**Verifiseringsmetoden** er verdt å gjenbruke: for steg 1–5 lot det seg gjøre
å bevise at ingenting endret seg, ved å bytte hver variabel tilbake til
verdien sin og sammenligne med originalen. For steg 6 gjaldt ikke den metoden
— der endres måten Tailwind lager farger på, ikke selve verdiene — så i stedet
ble hver enkelt fargetone målt i nettleser.

### Ting som gjenstår / er verdt å vite

- **`theme-color`-metataggen** ([index.html:12](../../index.html)) har fortsatt
  en hardkodet lilla. Den styrer fargen på nettleserens topplinje på mobil,
  ligger utenfor CSS-en og kan ikke bruke variabler. Må endres for hånd ved
  redesignet.
- **To «avvikere»:** `--farge-ok-bakgrunn-avvik` og `--farge-ok-tekst-avvik`
  brukes ett sted hver og er nesten identiske med sine grønne naboer. Beholdt
  uendret for å bevare utseendet, men gode kandidater for opprydding.
- **Tailwinds nedtoning med skråstrek** (`bg-white/50`) virker ikke på farger
  som kommer fra variabler. Appen bruker den ingen steder i dag; det er
  dokumentert med en advarsel i konfigurasjonen.
- **To hvite ikoner** på logofeltene ble flyttet fra `text-white` til
  `--farge-tekst-invers`, fordi Tailwind bare har én «white». Ellers ville de
  fulgt flatefargen og blitt usynlige hvis kortbakgrunnen mørknes senere.
- **Ingen død kode:** underveis ble det mistenkt at det gamle rutenettet for
  plasser var ubrukt. Det stemte ikke — `renderConcert()` er
  Billettfordeling og `renderFormation()` er Korpsoppsett, to ulike moduler
  som begge er aktive.

Tre funn fra testingen ligger som egne kort i backlog og er ikke en del av
dette arbeidet.
