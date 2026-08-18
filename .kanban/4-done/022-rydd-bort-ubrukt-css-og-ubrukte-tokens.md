---
title: Rydd bort ubrukt CSS og ubrukte tokens
created: 2026-08-18
updated: 2026-08-18
---

## Mål

Designsystemet fra Broadsheet-redesignet kom med flere byggeklosser enn appen
faktisk bruker. Fire CSS-klasser, tolv tokens og en hel fargeblokk i
Tailwind-oppsettet er definert uten å bli brukt noe sted. Når dette er ferdig
inneholder `:root` og CSS-blokken bare ting som faktisk maler noe — så neste
person som leter etter riktig farge, slipper å ta stilling til alternativer
som ikke er i bruk.

## Plan

- [x] Slett de fire ubrukte klassene med tilhørende regler:
      `.chip-assigned`, `.chip-free`, `.empty-state` (+ `.empty-state h3`),
      `.skeleton` (+ `@keyframes skeleton-pulse`)
- [x] Slett de tolv ubrukte tokenene: `--color-accent-2`,
      `--color-accent-2-400`, `--color-accent-900`, `--color-divider`,
      `--color-neutral-600`, `--farge-ok`, `--farge-ok-bakgrunn`,
      `--farge-ok-kant`, `--farge-svart-rgb`, `--farge-tekst-graa`,
      `--space-2`, `--space-6`
- [x] Fjern `green`-blokken i `tailwind.config` sammen med
      `--farge-ok-bakgrunn-avvik` og `--farge-ok-tekst-avvik`. De to er nå
      rene duplikater av `--farge-ok-bakgrunn`/`--farge-ok-tekst`, og nås
      bare via `green-100`/`green-700` — som ikke brukes noe sted
- [x] Rett kommentaren som lyver: `--farge-svart-rgb` står beskrevet som
      «bakteppe bak modaler», men brukes ikke. Finn ut hva bakteppet faktisk
      bruker nå, og la kommentaren si det
- [x] Kjør samme opptelling på nytt etterpå og sjekk at ingen referanse peker
      i løse lufta

## Verifisering

- [x] Appen ser helt lik ut før og etter — ingenting av dette males i dag
- [x] Ingen `var(--...)` peker på noe som ikke er definert (var 0 av 80 før)
- [x] Gå gjennom alle fem moduler visuelt, inkludert PDF-visning og
      oppstillingsdiagram, som har egne små `<style>`-blokker
- [x] Testet på https://beitnes.net/Korpsapp-test
- [x] Merget til `main`

## Notater

Fra arkitekturgjennomgangen (kort #1, funn 6 og 7).

Tellingen er gjort mot hele repoet, også mot dynamisk sammensatte klassenavn,
og mot de to små `<style>`-blokkene inne i JavaScript
([index.html:4931](../../index.html) og [index.html:5006](../../index.html)).

**92 tokens er definert, 80 er i bruk.** Ingen token blir brukt uten å være
definert — systemet er helt, bare litt for stort.

Et pussig funn verdt å ta med: det *kanoniske* navnet `--farge-ok-bakgrunn`
er dødt, mens *avviker*-navnet `--farge-ok-bakgrunn-avvik` lever — via en
Tailwind-klasse (`green-100`) som ingen bruker. Fargekortet ryddet i
avvikerne ved å la dem peke samme sted, men fjernet dem ikke.

Merk fella fra kort #1: første forsøk på å telle ubrukte tokens meldte at
**alle 92** var ubrukte, fordi skallet tolket søkemønsteret feil. Riktig tall
er 12. Verifiser tellingen før du sletter.

### Underveis (2026-08-18)

Arbeidet ligger i PR #18, mot `test`.

**Tellingen holdt.** De 12 tokenene og de 4 klassene var riktige, bekreftet
med to uavhengige metoder før sletting. Ingen referanse pekte i løse lufta,
verken før eller etter.

**Men slettingen utløste en andre runde kortet ikke forutså.** Da den døde
CSS-en forsvant, ble fire tokens til foreldreløse — de ble bare brukt av
reglene som nettopp gikk (`--color-neutral-100` av `.chip-free`,
`--space-1/4/8` av `.empty-state`).

Det avdekket noe større: **hele `--space-*`-skalaen sto igjen med én eneste
bruk.** Appen spacer med Tailwind-klasser, ikke med tokens — skalaen ble
aldri tatt i bruk. Valget ble å fjerne den helt og skrive den ene bruken
(`.btn`) som `15px`, framfor å la en «skala» på ett token bli stående.
Kommentaren øverst i `:root` sier fra, så ingen gjenoppliver den for ett
tilfelle. Til sammenlikning er `--radius-*` (17 bruk), `--font-*` (7) og
`--shadow-*` (3) reelt i bruk.

Sluttilstand: **73 tokens definert, 73 refererte.** Null ubrukte, null
danglende.

**Verifisering så langt:** innloggingsskjermen er pikselidentisk mot
testsiden, og computed styles for knapper, felt og bakgrunn er byte for byte
like — inkludert `padding` på `.btn`, den ene regelen som faktisk ble endret.
Resten av appen krever innlogging og gjenstår til endringen ligger på `test`.

En bommert verdt å notere: jeg overskrev `.claude/launch.json` ved å sjekke
om den fantes og skrive til den i samme kommando. Den lå i git og ble
gjenopprettet uendret — men sjekk før du skriver, ikke samtidig.

