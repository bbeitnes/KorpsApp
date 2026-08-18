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
- [ ] Vurder å erstatte de fire `selected*`-variablene med **én** variabel
      som bærer både hva og hvilken liste, f.eks.
      `{ liste: 'gruppeleder', navn: 'Kari' }`. Da kan ikke to være valgt
      samtidig, og feilen kan ikke oppstå igjen
  - Uavklart: er det verdt å gjøre nå, eller holder det å rette de tre
    funksjonene? Sammenslåingen berører flere steder enn feilen selv
- [ ] Sjekk at `setMode` fortsatt nullstiller alt ved modusbytte

## Verifisering

- [ ] Reproduser først: korps med registrerte gruppeledere → velg
      gruppeleder → velg navn → trykk lederfeltet. Feil person settes inn
- [ ] Etter rettingen: samme klikkrekke setter inn navnet du valgte sist
- [ ] Bare ett navn er markert om gangen, i alle fem moduler
- [ ] Testet på https://beitnes.net/Korpsapp-test
- [ ] Merget til `main`

## Notater

Funnet i arkitekturgjennomgangen (kort #1, funn 4). Full utredning med
tabell over hvilken funksjon som nullstiller hva ligger i det kortet.

De fire `selected*`-variablene skal være gjensidig utelukkende, men hver
`select*`-funksjon nullstiller de andre for hånd — og de gjør det ikke likt.
Bare `selectReiseleder` er komplett. Det er en kopiert-kode-feil: fire
sidepanellister med nesten samme kode som har sklidd fra hverandre.

Feilen er sporet gjennom hver gren i koden, men **ikke reprodusert i
nettleseren** — det krever et korps med registrerte gruppeledere. Reproduksjon
er derfor første punkt under Verifisering.

`setMode` nullstiller alle fire, så feilen lekker ikke mellom moduler — den
er begrenset til Gruppeinndeling.
