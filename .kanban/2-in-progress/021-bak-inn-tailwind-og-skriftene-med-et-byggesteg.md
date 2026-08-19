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

**Firebase-SDK-en er bevisst utenfor** — se grilling. Bare Tailwind og
skriftene bakes inn.

## Plan

- [x] Skriv et ordentlig `package.json` og commit det. Det ligger allerede
      en **usporet** `package.json` i repoet med feil Firebase-versjon
      (`^12.16.0`, appen bruker `10.13.0` via CDN) og ingen Tailwind-oppføring
      — den skal **erstattes**, ikke bygges videre på. Se grilling
- [x] Sett opp Tailwind CLI (ikke PostCSS-plugin — ingen annen byggekjede
      finnes i repoet fra før, CLI er det minste tillegget) som byggesteg i
      stedet for CDN-skriptet på [index.html:16](../../index.html) — pinnet
      til en konkret versjon
  - Fargekartet i `tailwind.config` (linje 35–101) må flyttes til
    byggoppsettet, men skal peke på de samme `--farge-*`-variablene
  - `rounded-*`- og `fontFamily`-overstyringene må bli med
- [x] Last ned Source Serif 4 og legg skriftfilene i repoet. De hentes i dag
      fra `fonts.googleapis.com` og `fonts.gstatic.com`, begge uversjonert —
      og hele Broadsheet-uttrykket **er** serifen
- [x] Legg byggesteget inn i **alle fire** deploy-workflowene før
      SFTP-steget — de tre kunde-workflowene **og** `deploy-test.yml`. Se
      grilling for hvorfor test ikke kan utelates
  - **Pass på kopier-så-slett-mønsteret for `config/`** — se CLAUDE.md; det
    må stå igjen intakt
- [x] Rett `cache.addAll(ASSETS)` i [sw.js](../../sw.js): i dag er den
      alt-eller-ingenting, så feiler ett kall ved installasjon blir
      **ingenting** cachet — heller ikke `index.html`
- [x] Bump cachenavnet `fordeling-v1`, som aldri har vært endret

## Verifisering

- [x] Appen ser helt lik ut før og etter — dette skal ikke endre utseendet
- [x] Ingen forespørsler til `cdn.tailwindcss.com` eller `fonts.g*.com` i
      nettverksfanen etter endringen
- [x] Konsollvarselet «cdn.tailwindcss.com should not be used in production»
      er borte
- [ ] Alle tre kunder får riktig `config.js` — sjekk at deployen fortsatt
      skiller dem
- [ ] Byggesteget kjører og feiler synlig i GitHub Actions dersom noe er
      galt — ikke stille, ikke bare på develop-maskinen
- [ ] Testet på https://beitnes.net/Korpsapp-test — **med byggesteget aktivt
      på test**, ikke bare på main
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

### Avklart i grilling (2026-08-18)

**Firebase bakes ikke inn.** Den er den eneste av de fire avhengighetene som
allerede er versjonert (`10.13.0`), så den konkrete risikoen dette kortet
finnes for å fjerne — at innholdet kan endre seg under oss uten varsel —
gjelder ikke den. Å ta den med ville lagt til kompleksitet (Firebase sin
modulære SDK og tre-shaking) for noe som ikke faktisk er ødelagt. Scope er
derfor strengt: Tailwind og skriftene, ikke Firebase.

**Bygget kjører i CI, på hver deploy — ikke lokalt med commitet utdata.**
Dette var allerede underforstått i kort #1 sin grilling («fila på serveren
blir maskingenerert»), og ble bekreftet eksplisitt her: GitHub Actions kjører
byggesteget rett før SFTP-opplasting, hver gang. Kildekoden i repoet
(`index.html`) forblir vanlig, redigerbar tekst — det er bare det som faktisk
havner på serveren som blir generert. Alternativet (bygg lokalt, commit
resultatet) ble avvist: det krever disiplin til å alltid bygge før commit, og
git og det deployede kan stille gli fra hverandre uten at noen merker det.

**Byggesteget må inn i `deploy-test.yml`, ikke bare de tre
kunde-workflowene.** Uten det kan denne endringen aldri faktisk verifiseres
på test — man ville bare sett den gamle CDN-baserte versjonen kjøre der, og
stole på at byggesteget virker uten å ha sett det kjøre. Det bryter hele
poenget med test-steget for akkurat denne endringen. Alle fire workflows
(tre kunder + test) får byggesteget.

**Den usporede `package.json` skal erstattes, ikke bygges videre på.** Den
har feil Firebase-versjon (`^12.16.0` mot appens faktiske `10.13.0`) og
ingen Tailwind-oppføring — trolig rester fra et tidligere `npm install`-
eksperiment, aldri commitet. Siden kort #21 er det første kortet som
faktisk trenger et fungerende `package.json`, skriver dette kortet et nytt
og commiter det, i stedet for å la det usporede filet ligge og vente på
kort #8 (generell git-opprydding).

### Underveis (2026-08-18/19)

Arbeidet ligger i PR #20, mot `test`.

**Et reelt miljøproblem underveis, verdt å nevne:** de fire
workflow-filene (`deploy.yml`, `deploy-test.yml`,
`deploy-kvinner-i-kor.yml`, `deploy-musikkforeningen-suoni.yml`) ble
uleselige i over 30 minutter — selv rå blokklesing (`dd`) tidsavbrøt. Alt
annet arbeid (package.json, tailwind.config.js, skriftene, index.html,
sw.js) ble fullført og committet i mellomtiden. Løste seg av seg selv;
årsaken ble aldri identifisert.

**Tailwind pinnet til `3.4.17`** — undersøkt direkte: `cdn.tailwindcss.com`
omdirigerer i dag til `/3.4.17`. Bygget bruker altså nøyaktig den versjonen
appen allerede kjørte på, ikke en nyere (Tailwind v4 har en helt annen
konfigurasjonsmodell og ville vært en unødvendig risiko for et kort som
skal være usynlig for brukeren).

**Skriftene: kun `latin`-delmengden vendoret**, ikke alle seks Google
tilbyr. Norsk (æøå) ligger fullt innenfor `latin` (U+0000-00FF); de andre
delmengdene (kyrillisk, gresk, vietnamesisk …) ble aldri lastet av
nettlesere som viser norsk tekst uansett. Et lite scope-valg tatt underveis,
ikke i grillingen — verdt å nevne siden det avviker fra «last ned alt Google
serverer».

**Normal-varianten (400/600/700) er én delt fil.** Undersøkt: Google
serverer samme URL for alle tre vektene i `latin`-delmengden. Kopierte det
mønsteret rett av i stedet for å anta tre separate filer trengtes.

**Byggefiler ryddes bort i eget steg**, samme mønster som config/. Verifisert
med en full lokal simulering av begge utrullingsveiene (kopierte det en
checkout ville hatt til et rent scratch-katalog, kjørte `npm ci`,
`npm run build:css`, kundeoppsett-kopiering og opprydding i nøyaktig samme
rekkefølge workflow-filene nå gjør) — det som står igjen er nøyaktig det
som skal ut, ingen byggefiler lekker til noen kundes host.

**Gjenstår:** selve GitHub Actions-kjøringen har aldri kjørt. Simuleringen
gir høy tillit, men er ikke det samme som å se CI faktisk bygge og deploye.
De tre siste verifiseringspunktene (alle kunder får riktig config.js,
byggesteget feiler synlig ved feil, testet med byggesteget aktivt på test)
krever at PR #20 merges til `test` først.

