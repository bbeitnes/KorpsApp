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

- [ ] Rett den direkte feilen: `selectName` må nullstille
      `selectedGroupLeader` og kalle `renderGroupLeaders()`, slik
      `selectReiseleder` allerede gjør
- [ ] Rett samme mangel i `selectInstrument` (mangler gruppeleder) og
      `selectGroupLeader` (mangler reiseleder) — de er ufullstendige på hver
      sin måte
- [ ] Sjekk at `setMode` fortsatt nullstiller alt ved modusbytte

## Verifisering

- [ ] Korps med registrerte gruppeledere: velg en gruppeleder, deretter et
      navn fra Navnelista — gruppeleder-markeringen forsvinner, og navnet
      blir stående alene som valgt
- [ ] Trykk lederfeltet etterpå — navnet du valgte *sist* settes inn, ikke
      gruppelederen
- [ ] Bare ett navn/én person er markert om gangen, i alle fem moduler
- [ ] Testet på https://beitnes.net/Korpsapp-test
- [ ] Merget til `main`

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
