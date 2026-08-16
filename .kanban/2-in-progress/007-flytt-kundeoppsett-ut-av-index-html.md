---
title: Flytt kundeoppsett ut av index.html og dropp kundegrenene
created: 2026-08-15
updated: 2026-08-16
---

## Mål

Å sette opp en ny kunde skal være å skrive én liten konfigurasjonsfil — ikke å
opprette en git-gren som må holdes i takt med `main` for alltid. Etter dette
finnes kundeoppsettet (Firebase-nøkler, innlogging og modulvalg) i en egen fil
per kunde, `index.html` er identisk for alle, og `customer/kvinner-i-kor` er
avviklet.

Bestillingen var opprinnelig «en adminvisning der jeg kan velge moduler».
Grillingen 2026-08-15 endret den: modulvalget er bare ~7 linjer av
kundeoppsettet, og en skjerm inne i appen kan uansett ikke sette
Firebase-nøklene — de trengs før appen når Firestore. Se «Notater».

## Plan

- [ ] Lag `config.js` som setter `window.KORPSAPP_CONFIG` med tre bolker:
      `firebase` (nøklene), `auth` (delt e-post, Google-domene, av/på) og
      `modules` (de fem flaggene).
- [ ] Last den som vanlig `<script src="config.js">` **før**
      `<script type="module">` ([index.html:876](../../index.html)).
      Vanlige skript kjører ferdig før modulskript, så
      `window.KORPSAPP_CONFIG` er satt i god tid — ingen byggesteg trengs.
- [ ] Bytt ut `firebaseConfig` ([index.html:887](../../index.html)) med et
      oppslag i `KORPSAPP_CONFIG.firebase`.
- [ ] Bytt ut `SHARED_LOGIN_EMAIL` og `ALLOWED_GOOGLE_DOMAIN`
      ([index.html:896](../../index.html)) med oppslag i
      `KORPSAPP_CONFIG.auth`, og ta med `GOOGLE_LOGIN_ENABLED` fra kundegrenen.
- [ ] Hent `<div id="google-login-block">`-innpakningen fra
      `customer/kvinner-i-kor` inn i `main`. Den er den eneste ekte
      kodeendringen på kundegrenen, og den er generell — uten den kan ikke
      Google-knappen skjules av konfigurasjon.
- [ ] Bytt ut `ENABLED_MODULES` ([index.html:1982](../../index.html)) med
      oppslag i `KORPSAPP_CONFIG.modules`. Behold alle fem som `true` når
      konfigurasjonen mangler, så en glemt fil ikke gjør appen tom.
- [ ] Legg kundeoppsettene i repoet (f.eks. `config/skolekorps.js` og
      `config/kvinner-i-kor.js`) og la utrullingen kopiere riktig fil til
      `config.js`. Web-API-nøkler fra Firebase er offentlige av design, så de
      kan ligge i repoet — tilgangen styres av sikkerhetsreglene, ikke av
      nøkkelen.
- [ ] Håndter at de to kundene rulles ut på hver sin måte: `main` og `test`
      går via SFTP til beitnes.net (`deploy.yml`, `deploy-test.yml`), mens
      Kvinner-i-Kor går via Firebase Hosting
      (`firebase-hosting-merge.yml` på kundegrenen). Begge må kunne kjøres fra
      én gren.
- [ ] Ta stilling til `firestore.rules` per prosjekt før noe rulles ut.
      Standarddatabasen deles med Bestillingsportal og skal ikke få KorpsApps
      regelsett alene; Kvinner-i-Kor har eget prosjekt med egne regler.
- [ ] Få regelsettet med i utrullingen for Kvinner-i-Kor. I dag ruller
      `firebase-hosting-merge.yml` ut kun hosting, så reglene må deployes for
      hånd — se «Regler følger ikke med utrullingen» i Notater.
- [ ] Avvikle `customer/kvinner-i-kor` når oppsettet er flyttet, og bekreft at
      kunden fortsatt peker på sitt eget Firebase-prosjekt.

## Verifisering

- [ ] Kvinner-i-Kor-oppsettet viser bare Romfordeling, og appen starter i den
      modusen i stedet for å falle tilbake til Billettfordeling
- [ ] Google-knappen er skjult i Kvinner-i-Kor-oppsettet og synlig i
      skolekorps-oppsettet
- [ ] Skolekorps-oppsettet ser nøyaktig ut som i dag, med alle fem modulene
- [ ] Hjelpeteksten viser bare avsnittene for påslåtte moduler
      ([index.html:4838](../../index.html) filtrerer allerede på dette)
- [ ] `index.html` er tegn for tegn lik mellom de to utrullingene — bare
      `config.js` skiller dem
- [ ] En manglende eller ødelagt `config.js` gir en forståelig feil, ikke en
      blank side
- [ ] En endring som krever nye Firestore-regler når kundens eget prosjekt via
      utrullingen — eller kortet slår fast at reglene fortsatt deployes for
      hånd, og hvor det står beskrevet
- [ ] Testet på https://beitnes.net/Korpsapp-test
- [ ] Merget til `main`

## Notater

Grillet 2026-08-15. Kartleggingen under er gjort før og under grillingen.

### Mekanismen for moduler finnes allerede

`ENABLED_MODULES` ([index.html:1982](../../index.html)) virker som den skal, og
alle tre bruksstedene finnes: `firstEnabledMode()` velger oppstartsmodus,
`setMode()` avviser en avslått modus og skjuler fanene
([index.html:2188](../../index.html)), og hjelpeteksten filtreres
([index.html:4838](../../index.html)). Dette arbeidet flytter *hvor verdiene
kommer fra*. Appen kan allerede skjule moduler.

### Kundegrenen inneholder ingen egen funksjonalitet

Alt som skiller `customer/kvinner-i-kor` fra utgangspunktet er oppsett:

- Firebase-nøkler (eget prosjekt `kvinner-i-kor`)
- Innlogging: `GOOGLE_LOGIN_ENABLED = false`, egen delt e-post, tomt
  Google-domene
- `ENABLED_MODULES`: kun `room: true`
- én `<div id="google-login-block">` rundt Google-knappen så den kan skjules

Ingen kundespesifikk forretningslogikk. Grenen bærer altså ikke en tilpasset
app — den bærer en konfigurasjonsfil som tilfeldigvis ligger inne i en
5000-linjers `index.html`. Det er dét som gjør fletting vondt, ikke modulvalget.

### Hvor ille driften er

| | |
|---|---|
| Felles utgangspunkt | 2026-08-01 |
| `main` foran med | 31 commits |
| kundegrenen foran med | 7 commits (3 modulvalg, 3 oppsett, 1 fletting) |

Kvinner-i-Kor mangler ~2 uker: hele Broadsheet-redesignet, fargevariablene og
rettelsene i Korpsoppsett. Med «jeg lager kanskje flere» blir det N grener per
rettelse. Når oppsettet ligger i en egen fil, forsvinner grenene — og dermed
driften — helt.

Grenen ble flettet opp igjen 2026-08-16 (`a63169a`) og er nå i takt med `main`.
Selve flettingen kostet ingenting — 36 commits uten én konflikt, og alle fire
oppsettspunktene overlevde. Det som kostet, var regelsettet. Se under.

### Regler følger ikke med utrullingen

`firebase-hosting-merge.yml` kjører `action-hosting-deploy` med `channelId:
live`. Den ruller ut *hosting* og ingenting annet, selv om `firebase.json` på
kundegrenen også peker på `firestore.rules`. Reglene må derfor deployes
separat:

```
firebase deploy --only firestore:rules --project kvinner-i-kor
```

Det er ikke en teoretisk mangel. `main` tok i bruk `korpsIndex`-samlingen
(`b13892c`), og `listProjects()` ([index.html:1026](../../index.html)) leser
den uten reservevariant. Uten regelen for `korpsIndex` i kundens prosjekt ville
flettingen 2026-08-16 gitt kunden «Kunne ikke hente listen over korps» i stedet
for korpslisten. Reglene ble deployet først, så det skjedde ikke — men
rekkefølgen var det ingenting som håndhevet.

Poenget for dette kortet: å samle kundene på én gren fjerner git-driften, men
ikke denne. Så lenge hver kunde har sitt eget Firebase-prosjekt, har hver kunde
sitt eget regelsett som må ut når reglene endres. Da må utrullingen gjøre det,
ikke et menneske som husker det.

### Valg tatt i grillingen

- **Eget Firebase-prosjekt per kunde beholdes.** Dataskillet er fysisk, og en
  kunde kan slettes eller overleveres rent. Konsekvensen er at hver kunde må ha
  sin egen utrulling, og at nøklene derfor alltid blir per utrulling.
- **Adminvisningen er droppet.** Den skulle bare være for utvikleren, og da
  trenger den verken tilgangsstyring eller å ligge inne i appen. En skjerm ville
  dessuten bare dekket modulvalget — nøkler og innlogging er resten av
  oppsettet, og dem kan den ikke sette.
- **Modulvalg i korpsdokumentet i Firestore ble vurdert og forkastet** for nå.
  Mønsteret finnes (`accessMode`/`allowedEmails` lagres allerede per korps med
  `setDoc(..., { merge: true })`, [index.html:1121](../../index.html)), så det
  er en åpen dør senere hvis én utrulling skal betjene flere korps med ulike
  moduler. Det løser bare ikke problemet denne saken handler om.

### Verdt å vite

- Modulene henger sammen med hver sine navnelister: Vaktlister bruker
  `parents`, Gruppeinndeling `groupLeaders`, Romfordeling `reiseledere`
  ([index.html:2004-2007](../../index.html)). Å skru av en modul skjuler bare
  fanen — listene blir stående i kundens egen database, og skrus modulen på
  igjen, er dataene der fortsatt. Ingenting slettes.
- Korps opprettet før `korpsIndex` fantes får ingen indeksoppføring før de
  lagres én gang — speilingen skjer ved hver lagring
  ([index.html:1726](../../index.html)). Etter flettingen 2026-08-16 kan
  korpslisten hos Kvinner-i-Kor derfor se tom ut til hvert korps er åpnet og
  lagret én gang. Ingenting er borte; det er bare indeksen som er tom.
- Tailwind lastes fra CDN ([index.html:16](../../index.html)). Det er urørt av
  denne saken, men står som egen risiko på kortet
  `arkitekturgjennomgang-struktur-tokens-og-cdn-risiko`.
