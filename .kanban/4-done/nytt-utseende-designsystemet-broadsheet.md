---
title: Nytt utseende: designsystemet Broadsheet
created: 2026-08-16
updated: 2026-08-16
---

## Mål

Bytte appens utseende til designsystemet «Broadsheet»: papirhvit bunn,
nesten-svart trykksverte, Source Serif 4 i hele grensesnittet, og to
aksentfarger i stedet for fem. Ingen funksjonalitet endres.

**Dette kortet er skrevet i ettertid, 2026-08-16.** Arbeidet ble gjort
14. august (`0fc39de`) uten kort, og gikk i produksjon 16. august uten at
noe sted forklarte hva Broadsheet er. Kortet finnes for at ikke hele
begrunnelsen skal ligge i én commit-melding.

## Plan

- [x] Systemlag i `:root` — 48 tokens (`--color-*`, `--space-*`,
      `--radius-*`, `--shadow-*`, `--font-*`, `--tap-min`)
- [x] Appens 44 gamle `--farge-*`-navn beholdt, men peker nå på tokenene,
      så all eksisterende markup fulgte med uendret
- [x] `tailwind.config` remapper hjørneradius og skrifttype, slik farger
      allerede var remappet. `rounded-full` (12 bruk) med vilje urørt
- [x] Komponent-CSS: knapper, felt, stolplasser, romkort, romfelt, faner,
      modaler, tooltip
- [x] Nye komponenter fra systemet: `.chip` med fire varianter
      ([index.html:433](../../index.html)), `.empty-state`, `.skeleton`
- [x] Løst fargekollisjon i Romfordeling og på stolplasser — se `## Notater`
- [x] Løst linjebrekk i mobil-headeren fra den bredere serifen

## Verifisering

- [x] Testet i nettleser på desktop og mobil: innlogging, Billettfordeling,
      Korpsoppsett, Romfordeling, sidemeny og modal
- [x] Testet på https://beitnes.net/Korpsapp-test — lå på testsiden fra
      14. august til 16. august, altså to døgn før produksjon
- [x] Merget til `main` 2026-08-16 (`a3ce731`), sammen med de to
      Korpsoppsett-rettelsene

## Notater

### Hva Broadsheet er

Navnet er avislingo: en *broadsheet* er storformatavisen, i motsetning til
tabloiden. Utseendet er bygget for å ligne **trykksak** framfor en typisk
nettapp.

| | Broadsheet | Det som var før |
|---|---|---|
| Bunn | Papirhvit `#f3f2f2` | Kjølig blågrå |
| Tekst | Nesten-svart trykksverte `#201e1d` | Skifergrå |
| Skrift | Source Serif 4 — en **serif**, også i knapper og menyer | Sans-serif |
| Hjørner | Nesten rette, 1–4 px | Runde, 8–16 px |
| Aksenter | To: cyan for handling, magenta for fare | Fem farger |

### To ting krevde vurdering, ikke bare fargebytte

- **Systemet har to aksenter, ikke fem.** Grønn «ok» ble derfor cyan, samme
  familie som primærfargen. Det gjorde at «kan fylles» (hover) og «er fylt»
  kolliderte i romfeltene. Løst slik designforslaget viser: ledig seng er
  stiplet og dempet, fylt seng er en rolig solid flate, og cyan er reservert
  for hover. Samme grep på stolplasser.
- **Serifen er bredere enn Segoe UI**, så korps- og arrangementsnavn brøt
  over flere linjer i mobil-headeren. De kuttes med ellipse nå.

### Hvorfor det gikk så smertefritt

Kortet `samle-farger-som-css-variabler` var forarbeidet. Det samlet alle
farger ett sted uten å endre utseendet i det hele tatt — nettopp for at et
utseendebytte senere skulle kunne skje i token-laget. Det virket: hele
redesignet er 274 linjer lagt til og 96 fjernet i én fil, og **ingen markup
måtte endres**.

### Opprinnelsen er ikke dokumentert noe sted

Designet ble laget sammen med Claude i en **annen økt**, og «designforslaget»
som commit-meldingen viser til finnes derfor i den samtalen — ikke som fil i
repoet, ikke i noe designverktøy. Bjørn Erik bekreftet dette 16. august, og
husket heller ikke selv navnet på designet før det ble slått opp.

Det betyr i praksis at **begrunnelsen bak de enkelte valgene er tapt** —
hvorfor akkurat denne cyanen, hvorfor 1–4 px hjørner, hvilke alternativer som
ble vurdert. Det som finnes er resultatet: tokenene i `:root`, kommentarene
rundt dem, og commit-meldingen til `0fc39de`.

Lærdommen er verdt å ta med: det største visuelle grepet i appens historie
har det tynneste sporet etter seg, mens to små etikettrettelser samme uke har
sider med begrunnelse. Legg kort på store endringer, ikke bare på små feil.

### Beslektet

- `samle-farger-som-css-variabler` — forarbeidet som gjorde dette mulig
- `arkitekturgjennomgang-struktur-tokens-og-cdn-risiko` — skal blant annet se
  på om mellomlaget `--farge-*` fortsatt gjør en jobb etter dette
- `radetiketten-forsvinner-bak-plassen` og `instrumenttekst-er-for-stor` —
  begge funnet under testing av Broadsheet, men ingen av dem forårsaket av det
