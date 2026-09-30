---
title: Feil gruppeleder settes inn i Gruppeinndeling
created: 2026-08-18
updated: 2026-08-18
---

## Mål

I Gruppeinndeling kan appen sette inn en annen person enn den du valgte sist.
Velger du først en gruppeleder og deretter et navn fra Navnelista, står begge
markert samtidig — og trykker du på lederfeltet, settes den *første* inn.
Når dette er ferdig skal sist valgte alltid vinne, og aldri mer enn ett navn
være markert om gangen.

## Plan

- [x] Rett den direkte feilen: `selectName` må nullstille
      `selectedGroupLeader` og kalle `renderGroupLeaders()`, slik
      `selectReiseleder` allerede gjør
- [x] Rett samme mangel i `selectInstrument` (mangler gruppeleder) og
      `selectGroupLeader` (mangler reiseleder) — de er ufullstendige på hver
      sin måte
- [x] Sjekk at `setMode` fortsatt nullstiller alt ved modusbytte

## Verifisering

- [x] Korps med registrerte gruppeledere: velg en gruppeleder, deretter et
      navn fra Navnelista — gruppeleder-markeringen forsvinner, og navnet
      blir stående alene som valgt
- [x] Trykk lederfeltet etterpå — den gamle gruppeleder-markeringen settes
      **ikke** automatisk inn. Siden Navneliste-navnet ikke er en gyldig
      lederkandidat når korpset har egen gruppeledere-liste, åpnes i stedet
      dialogen for å velge blant registrerte gruppeledere
- [x] Bare ett navn/én person er markert om gangen, i alle fem moduler
- [x] Testet på https://beitnes.net/Korpsapp-test
- [x] Merget til `main`

## Notater

Funnet i arkitekturgjennomgangen (kort #1, funn 4). Full utredning med
tabell over hvilken funksjon som nullstiller hva ligger i det kortet.

De fire `selected*`-variablene skal være gjensidig utelukkende, men hver
`select*`-funksjon nullstiller de andre for hånd — og de gjør det ikke likt.
Bare `selectReiseleder` er komplett. Det er en kopiert-kode-feil: fire
sidepanellister med nesten samme kode som har sklidd fra hverandre.

`setMode` nullstiller alle fire, så feilen lekker ikke mellom moduler — den
er begrenset til Gruppeinndeling.

### Avklart i grilling (2026-08-18)

**Bare den direkte rettingen, ikke sammenslåingen.** Utkastet foreslo å
erstatte de fire `selected*`-variablene med én variabel som strukturelt
ikke kan representere to valg samtidig — det ville gjort hele feilklassen
umulig, ikke bare rettet det ene tilfellet. Vurdert og lagt til side: den
berører alle fire render-funksjonene og kallstedene deres, mens den direkte
rettingen er tre linjer kopiert fra `selectReiseleder`, som allerede er
riktig. Konsekvens: dukker det opp en femte utvalgsliste senere, må noen
huske å kopiere nullstillingen riktig igjen — samme felle som ga denne
feilen. Det er en bevisst avveining, ikke en glemt en.

**Ingen levende reproduksjon som portvakt.** Utkastet satte «reproduser
først i nettleseren» som første steg under Verifisering, før koden røres.
Vurdert og lagt til side: fire-funksjoners sammenligningstabellen i
arkitekturrapporten er overbevisende nok i seg selv — bare
`selectReiseleder` nullstiller alle tre andre, de tre resten mangler hver
sin. Verifisering skjer i stedet *etter* rettingen: sett opp et korps med
gruppeledere, og bekreft at valgrekkefølgen oppfører seg riktig.

### Underveis (2026-08-18)

Arbeidet ligger i PR #19, mot `test`.

**Rettet nøyaktig som planlagt:** kopierte mønsteret fra `selectReiseleder`
inn i `selectName`, `selectInstrument` og `selectGroupLeader`. Hver
funksjon nullstiller nå alle tre søsknene sine og re-render alle listene
som kan ha mistet markeringen.

**Verifisert med negativ kontroll**, ikke bare lest koden: samme
reproduksjon kjørt både mot koden før og etter endringen, direkte mot
in-memory `state` i nettleseren (uten innlogging — se PR for hvorfor det er
trygt, ingen skriving til Firestore skjer uten `auth.currentUser`).

- **Før:** velg gruppeleder «Kari» → velg navn «Ola» → `selectedGroupLeader`
  forble `'Kari'` → trykk lederfeltet → **Kari** ble satt inn som leder.
  Bekrefter feilen slik kortet beskriver den.
- **Etter:** samme rekkefølge → `selectedGroupLeader` blir `null` etter
  steg 2, markeringen forsvinner fra DOM-en → trykk lederfeltet → **ingen**
  blir satt inn automatisk. Dialogen for å velge blant registrerte
  gruppeledere åpnes i stedet.

**Et presiseringspunkt fra `## Mål`:** formuleringen «sist valgte vinner»
antydet at Ola skulle blitt satt inn som leder. Det stemmer ikke med
hvordan appen er designet — har korpset en egen gruppeledere-liste, skal
ledere velges *kun* derfra, ikke fra Navnelista (se kommentaren over
`showTeamLeaderDialog` i koden). Riktig oppførsel er derfor at *ingen*
automatisk settes inn, ikke at Ola gjør det. Verifiseringspunktet i kortet
er justert til å beskrive dette presist.

Testet også: `selectInstrument` nullstiller gruppeleder-valget riktig, og
alle fire utvalg forblir gjensidig utelukkende gjennom en full kjede
(Navn → Instrument → Gruppeleder → Reiseleder → kun siste står valgt).

**Gjenstår:** den faktiske appen, innlogget, på
https://beitnes.net/Korpsapp-test — testen over gikk direkte mot
JavaScript-state uten innlogging, som er riktig for å isolere logikken,
men ikke en erstatning for å se det virke i den ekte appen.

### Verifisert på test av Bjørn Erik (2026-08-18)

Bekreftet logget inn, med korps som har registrerte gruppeledere: samme
klikkrekke som var buggy før — velg gruppeleder, velg navn, trykk
lederfeltet — oppfører seg nå riktig.

