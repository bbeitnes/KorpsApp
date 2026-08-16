---
title: Innlogging med personlige brukere i stedet for delt passord
created: 2026-08-16
updated: 2026-08-16
---

## Mål

Hvem som har tilgang til en KorpsApp-installasjon skal være en liste over
e-postadresser, ikke ett delt passord alle kjenner. Folk logger inn som seg
selv, og lista håndheves i Firestore-reglene — ikke bare i nettleseren.

Bestilt 2026-08-16 da en ny kunde skulle settes opp: «jeg vil fylle inn
e-postadresser til de som skal ha tilgang, slik som Bestillingsportal».
Kunden ble satt opp med delt passord i mellomtiden, så dette kortet haster
ikke — men det står i veien for enhver kunde som ikke har et Workspace-domene.

## Plan

- [ ] Avklar hvilken innloggingsmodell det skal være (se «Uavklart» under) —
      alt annet i planen henger på det svaret.
- [ ] Gjør Google-innlogging mulig **uten** Workspace-domene.
      [index.html:1977](../../index.html) avviser i dag alt som ikke ender på
      `@` + `ALLOWED_GOOGLE_DOMAIN`. Med tomt domene blir sjekken
      `email.endsWith('@')`, som er usann for enhver adresse — altså avvises
      alle. Det er derfor «Google-innlogging uten domene» ikke finnes i dag,
      ikke et bevisst valg.
- [ ] Flytt tilgangslista dit reglene kan lese den. Reglene kan ikke se
      `config.js`, så en liste i konfigurasjonsfila er kun kosmetikk.
      Alternativene er en Firestore-samling reglene kan `get()`, eller
      custom claims på brukeren — se «Uavklart».
- [ ] Stram inn `isSignedIn()`. I dag er den eneste porten for et ulåst korps
      at du er innlogget ([firestore.rules:43](../../firestore.rules)). Det er
      trygt så lenge innlogging betyr delt passord eller eget Workspace-domene.
      Åpnes innlogging for enhver Google-konto, betyr `isSignedIn()` «hvem som
      helst med en Gmail-adresse».
- [ ] Se på `korpsIndex` spesielt: den er
      `allow read, write: if isSignedIn()` ([firestore.rules:39](../../firestore.rules))
      uten noen `korpsAllowed`-sjekk, fordi et ufiltrert `list`-kall feiler i
      sin helhet hvis ett eneste dokument ville brutt reglene. Samme fella
      venter på en installasjonsliste.
- [ ] Bestem hva som skjer med `accessMode`/`allowedEmails` per korps
      ([firestore.rules:26](../../firestore.rules)). Mønsteret finnes allerede
      og virker — spørsmålet er om en installasjonsliste kommer i tillegg til
      det, eller erstatter det.
- [ ] Håndter avviklingen av den delte kontoen. `SHARED_LOGIN_EMAIL` brukes
      også som identitet i `currentUserLabel()`
      ([index.html:960](../../index.html)), og eksisterende data er lagret med
      `updatedBy: 'Delt konto'`.
- [ ] Lag en vei å administrere lista på. I dag redigeres `allowedEmails` per
      korps i en modal ([index.html:1189](../../index.html)) — en
      installasjonsliste trenger noe tilsvarende, eller en bevisst beslutning
      om at den settes i Firebase-konsollet.
- [ ] Rull ut per kunde, ikke som flaggdag. Begge dagens kunder kjører delt
      passord og skal fortsette å virke mens dette bygges.

Uavklart: Hvordan gjør Bestillingsportal det egentlig? Logger folk inn med
Google og adressen står på en liste, eller opprettes det en konto med
e-post/passord per person, slik at det å ha en konto *er* tilgangen? De to
gir helt ulike bygg — den andre trenger ingen liste, men betyr at noen må
opprette brukere og nullstille passord.

Uavklart: Hvor bor lista? En Firestore-samling reglene kan `get()` er enkel og
krever ingen server, men koster en ekstra lesning per regelevaluering. Custom
claims er raskere og ligger i tokenet, men krever Admin SDK — altså en
backend. KorpsApp er i dag en ren statisk side uten noe serverledd, så det er
en arkitekturendring, ikke en detalj.

Uavklart: Er tilgang per installasjon eller per korps? Kvinner i Kor har ett
korps og trenger neppe to nivåer. Skiens skolemusikk har flere korps og bruker
allerede `accessMode: 'restricted'` per korps.

Uavklart: Hvem administrerer lista — utvikleren i konsollet, eller en
innlogget bruker inne i appen? Hvis det siste: hvem har lov til å legge til
andre, og hva hindrer den siste administratoren i å låse seg selv ute?

Uavklart: Skal delt passord fortsatt finnes som alternativ for kunder som
foretrekker det, eller skal alle over på personlige brukere til slutt?

## Verifisering

- [ ] Testet på https://beitnes.net/Korpsapp-test
- [ ] Merget til `main`

## Notater

### Kartlagt 2026-08-16, før grilling

Funnene under er lest ut av koden mens kort 7 ble rullet ut, ikke antatt.

**Google-innlogging krever et Workspace-domene i dag.**
[index.html:1977](../../index.html) gjør `provider.setCustomParameters({ hd:
ALLOWED_GOOGLE_DOMAIN })` og avviser deretter alt som ikke ender på domenet.
Tomt domene avviser alle. Ingen har lagt merke til det fordi den ene kunden med
tomt domene også har Google-innlogging avslått
([config/kvinner-i-kor.js](../../config/kvinner-i-kor.js)).

**En liste i `config.js` ville ikke vært håndhevelse.** Klienten kan logge
brukeren ut etter innlogging, men Firebase har da allerede utstedt et gyldig
token. Alt som betyr noe må stå i `firestore.rules`, og reglene ser aldri
`config.js`.

**Mønsteret finnes allerede, men bare per korps.** `korpsAllowed()`
([firestore.rules:26](../../firestore.rules)) sjekker
`request.auth.token.email in korps.allowedEmails`. Det virker, og det er
sannsynligvis formen en installasjonsliste også skal ha. Men den delte kontoen
er bevisst utestengt fra låste korps, så mekanismen er utilgjengelig for alle
som logger inn med delt passord — som i dag er alle.

**`korpsIndex` er den advarselen som allerede er betalt for.** Kommentaren over
[firestore.rules:39](../../firestore.rules) forteller at Firestore avviser et
helt `list`-kall dersom ett eneste dokument i svaret ville brutt reglene — det
var derfor hele korpslisten forsvant for alle da ett korps ble låst. En
installasjonsomfattende tilgangsliste kan gå i nøyaktig samme felle.

### Beslektet

Kort 7 (`flytt-kundeoppsett-ut-av-index-html`) flyttet `auth`-bolken til
`config.js` med `googleLoginEnabled`, `sharedLoginEmail` og `googleDomain`.
Dette kortet vil sannsynligvis utvide den bolken — men altså ikke la den bære
selve tilgangslista.
