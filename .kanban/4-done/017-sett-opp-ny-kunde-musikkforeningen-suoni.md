---
title: Sett opp ny kunde: Musikkforeningen Suoni
created: 2026-08-16
updated: 2026-08-18
---

## Mål

Musikkforeningen Suoni skal kjøre KorpsApp på `musikkforeningen-suoni.web.app`
med sitt eget Firebase-prosjekt, kun Korpsoppsett-modulen, og innlogging med
delt passord. Første kunde satt opp etter kort 7 — altså uten kundegren, kun
en fil i `config/`.

Kortet er også **oppskriften**: rekkefølgen under er den som faktisk virket, og
neste kunde skal kunne følge den uten å finne den opp på nytt.

## Plan

### I Firebase-konsollet (kan ikke gjøres fra repoet)

- [x] Opprett prosjektet. Prosjekt-ID-en er **permanent, global og kan ikke
      gjenbrukes** — trykk blyanten og sett den selv i stedet for å ta imot
      den auto-genererte med tilfeldig suffiks. Slå av Google Analytics.
- [x] Opprett Firestore i **europe-north1**. Plasseringen kan aldri endres, og
      basen holder navn og portrettbilder av medlemmer, altså
      personopplysninger. Velg **produksjonsmodus** (låst) — testmodus er åpen
      for hele verden til første utrulling legger inn `firestore.rules`.
- [x] Skru på **E-post/passord** under Authentication (ikke «Email link»), og
      opprett den delte brukeren.
- [x] Registrer en **web-app** og hent `firebaseConfig`. Ignorer
      `npm install firebase` som konsollet foreslår — appen laster Firebase
      fra CDN og har ingen byggesteg.
- [x] Lag tjenestekontoen for GitHub. `firebase init hosting:github` gjør det
      enkleste, men **skriver over `firebase.json`, `.firebaserc` og lager
      egne arbeidsflytfiler** — se Notater før du kjører den.
- [x] Gi tjenestekontoen rollen **Firebase Rules Admin**
      (`roles/firebaserules.admin`), og vent noen minutter på at IAM forplanter
      seg før første utrulling.

### I repoet

- [x] `config/musikkforeningen-suoni.js` med nøkler, `auth` og `modules`.
- [x] Oppføring i `.firebaserc` (fortsatt uten `default`).
- [x] `.github/workflows/deploy-musikkforeningen-suoni.yml`.
- [x] Verifisert lokalt med kundens egen `config.js`: starter i Korpsoppsett,
      `setMode('room')` faller tilbake til `formation`, kun én fane,
      hjelpeteksten viser bare Korpsmodus og Slagverksliste,
      Google-blokken skjult.
- [x] Push til `main` — først når tjenestekontoen og rollen finnes, ellers
      feiler jobben.
- [x] Bekreft at `musikkforeningen-suoni.web.app` svarer, at `config.js`
      serveres med riktig prosjekt, og at `config/` ikke ligger ute.
- [x] Logg inn og opprett ett korps, som røyktest av regelsettet CI la ut.

## Verifisering

- [x] Testet på https://beitnes.net/Korpsapp-test — gjelder ikke dette kortet.
      Testsiden kjører `skolekorps`-oppsettet, så et Suoni-kundeoppsett kan
      ikke vises der i det hele tatt. Verifisert direkte mot
      `musikkforeningen-suoni.web.app` i stedet, se Notater.
- [x] Merget til `main`

## Notater

### Røyktesten, 2026-08-18

Bekreftet av Bjørn Erik: innlogging og oppretting av korps virker mot kundens
eget prosjekt. Dermed er regelsettet CI la ut faktisk i bruk, ikke bare rullet
ut uten feilmelding — det var hele poenget med å ha punktet stående åpent.

Kontrollert samme dag rett mot `musikkforeningen-suoni.web.app`, uten
innlogging:

| sjekk | resultat |
|---|---|
| `/` | 200 |
| `/config.js` | 200, `projectId: "musikkforeningen-suoni"`, `googleLoginEnabled: false`, kun `formation: true` |
| `/config/skolekorps.js` | 404 |
| `/config/kvinner-i-kor.js` | 404 |
| SHA-256 på `index.html` | identisk med `git show main:index.html` |

At `config/` gir 404 er den viktigste av dem: det er kopier-så-slett-steget i
arbeidsflyten som holder én kundes oppsett unna en annen kundes vert. SHA-summen
viser samtidig at kunden lå på siste `main` samme dag, altså at kort 18 kom med.

### Hvorfor «Testet på Korpsapp-test» ikke gjaldt her

Linja står i malen for alle kort og er riktig for kodeendringer, men den passer
ikke på et kundeoppsett: testmiljøet bygges med `skolekorps`-oppsettet, så en ny
kundes `config/`-fil er per definisjon usynlig der. Verifiseringen måtte skje på
kundens egen vert, og gjorde det. Neste kunde får samme situasjon — det er en
egenskap ved oppskriften, ikke en forglemmelse her.

### Utrullingen 2026-08-17

Alle tre jobbene grønne på første forsøk — inkludert regelsteget, som for
Kvinner i Kor krevde tre forsøk fordi rollen manglet. Rekkefølgen «rolle først,
vent, rull ut etterpå» er altså det som gjorde forskjellen.

Tjenestekontoen `firebase init hosting:github` lager, heter
`github-action-<GitHub-repoets numeriske ID>@<prosjekt>.iam.gserviceaccount.com`.
For dette repoet er ID-en `1285859995`. Nyttig neste gang, siden kontoen ikke
dukker opp i IAM-lista før den har en rolle — bruk «GRANT ACCESS» og lim inn
adressen i stedet for å lete.

Ryddet bort etter `init`: den la inn `"default": "musikkforeningen-suoni"` i
`.firebaserc` (nettopp det kort 7 unngikk — et løst `firebase deploy` ville da
truffet en levende kunde) og lagde
`.github/workflows/firebase-hosting-pull-request.yml`. `firebase.json` slapp
unna. Hemmeligheten på GitHub overlevde oppryddingen, som var hele poenget.

Bekreftet live: `musikkforeningen-suoni.web.app` starter i Korpsoppsett, kun
den ene fanen, `setMode('room')` faller tilbake til `formation`, Google-blokken
skjult, og `config/` gir 404. `index.html` har samme SHA-256 på alle tre
utrullingene som `git show main:index.html`.

### Hva som faktisk koster tid

Kort 7 lovet at en ny kunde er «én liten konfigurasjonsfil». Det stemmer for
repoet — tre små filer, ingen endring i `index.html`. Det stemmer ikke for
resten: prosjekt, database, innlogging, web-app, tjenestekonto og IAM-rolle er
seks konsolloperasjoner, og fire av dem har et valg som ikke kan gjøres om.

### `firebase init hosting:github` er en felle i dette repoet

Den gjør tre nyttige ting — oppretter tjenestekontoen, lager nøkkelen, legger
hemmeligheten i GitHub med riktig navn — og tre skadelige: skriver over
`firebase.json`, `.firebaserc` og lager sine egne arbeidsflytfiler, altså
nøyaktig det kort 7 bygget.

Det som er verdt å vite: **alt det nyttige skjer eksternt** (tjenestekontoen
hos Google, hemmeligheten hos GitHub), og alt det skadelige er lokalt og kan
kastes. Så kjør den, kjør `git status`, og tilbakestill filene den rørte. Ikke
commit noe imellom.

### Rekkefølgen på IAM-rollen

Ved oppsettet av Kvinner i Kor samme dag feilet første utrulling fordi
tjenestekontoen kun hadde hosting-rettigheter og ikke kunne røre
Firestore-reglene. To forsøk til feilet også — IAM-endringer bruker noen
minutter på å forplante seg. Gi rollen først, vent, og rull ut etterpå.

### Valg tatt for denne kunden

- **Kun Korpsoppsett.** Verdt å merke seg at det er nettopp den modulen kort 11
  sier er ødelagt på iPad — å velge et navn og trykke på lerretet gjør
  ingenting. Blir Suoni en iPad-kunde, har de en app med én modul som ikke
  virker der.
- **Delt passord, ikke personlige brukere.** Kort 15 gjør om på dette senere.
- **`bbeitnes@gmail.com` som delt konto**, fordi kunden ikke hadde en
  rolleadresse klar. Skal byttes — kort 16.

### Prosjektgrensen

Tre Firebase-prosjekter i bruk ved dette oppsettet. Spørsmålet om én kunde per
prosjekt skalerer ble tatt opp og utsatt: alternativet er navngitte
Firestore-databaser i ett prosjekt (mekanismen brukes allerede for `test`), men
det multipliserer nøyaktig den feilen som slettet Bestillingsportals regler to
ganger 2026-08-10. Tas opp igjen ved åtte-ti kunder.
