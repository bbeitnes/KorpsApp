---
title: To modaler stables ved innlogging på Hovedkorps
created: 2026-08-19
updated: 2026-08-19
---

## Mål

På https://beitnes.net/Korpsapp-test viser korpset «Hovedkorps» en fastlåst,
lagdelt skjerm: Slagverksliste-modalen åpen oppå «Velg korps»-velgeren, som
selv er en modal uten lukkeknapp når den åpnes automatisk. Brukeren opplever
appen som ødelagt — ✕ på Slagverksliste gjør ingenting synlig, siden det som
avdekkes under er en annen, ikke-lukkbar modal. Når dette er ferdig skal
innlogging (uansett vei inn) til et korps aldri vise mer enn én modal om
gangen, og ✕/Ferdig skal alltid faktisk bringe brukeren tilbake til en
brukbar skjerm.

## Plan

- [ ] Reproduser med ekte innlogging — dette kortet ble skrevet uten tilgang
      til å logge inn selv, se Notater. Se feilen oppstå underveis, steg for
      steg, ikke bare i sluttilstanden
  - Uavklart: nøyaktig klikkerekkefølge som fører hit er ikke funnet. Et
    helt ferskt (inkognito) besøk ender opp her uten at noen åpenbart har
    klikket «✏️ Rediger» først — det krever forklaring
- [x] Undersøk om `showProjectPicker(false)` kan bli kalt (fra
      `onAuthStateChanged` eller fra `startKorpsSync`s «korps slettet/mistet
      tilgang»-gren) mens `#instrument-list-modal` allerede står åpent, uten
      at noen kode lukker det først
  - Bekreftet: alle tre kodeveier ([index.html:1013](../../index.html),
    [1628](../../index.html), [1663](../../index.html)) kaller
    `showProjectPicker(false)` → `showModal(...)` uten å sjekke om
    `#instrument-list-modal` står åpent fra før
- [x] Vurder en generell rettelse: la modal-åpnende funksjoner
      (`openInstrumentListModal`, `showModal`/`showProjectPicker`, og andre)
      lukke enhver ANNEN åpen modal før de åpner sin egen — i stedet for å
      punktrette akkurat denne kombinasjonen
  - Implementert: `openInstrumentListModal()` kaller nå `closeModal()` først,
    og `showModal()` kaller nå `closeInstrumentListModal()` først. Alle
    dialoger bygget på `showModal()` (inkl. `showProjectPicker`) går gjennom
    samme funksjon, så dette dekker alle kombinasjoner, ikke bare denne ene.
    Verifisert direkte i konsollen (uten innlogging, siden de to
    modal-funksjonene er globale og uavhengige av auth-tilstand): åpne den
    ene lukker alltid den andre, i begge retninger
- [ ] Rett årsaken når den er funnet, og fjern anledningen til at to modaler
      noensinne kan stables
  - Selve utløseren er fortsatt ikke funnet — se notat under. Rettelsen over
    er en sikkerhetsnett (ingen stabling kan lenger skje), ikke en fjerning
    av årsaken

## Verifisering

- [ ] Reprodusert pålitelig, med kjente steg
- [ ] Etter rettingen: samme steg fører ikke lenger til to samtidig åpne
      modaler
- [ ] ✕/Ferdig på enhver modal bringer alltid brukeren til en brukbar skjerm
- [ ] Testet på https://beitnes.net/Korpsapp-test
- [ ] Merget til `main`

## Notater

### Hvordan dette ble funnet

Oppdaget rett etter at kort #21 (Tailwind/skrifter-byggesteget) ble merget
til `test` — først mistenkt som en regresjon derfra. Det er den IKKE, og det
er bekreftet på to uavhengige måter, ikke bare antatt:

1. **Kodegjennomgang:** kort #21 sin diff er 100 % avgrenset til `<head>`
   (CDN-skript/skrifter → lokale). Den rører aldri JavaScript-logikk,
   modal-håndtering eller state.
2. **Empirisk bevis:** `test` ble midlertidig satt tilbake til koden FØR
   kort #21 (`git revert` av merge-commiten, pushet direkte til `test`),
   og feilen dukket opp identisk med den gamle koden også. Kort #21 sin
   retting ble deretter gjenopprettet (`git revert` av reverten). Se
   commit-historikken på `test` rundt 2026-08-19 08:44–09:00 UTC.

**Konklusjon: dette er en reell, uavhengig feil som fantes fra før, ikke
noe kort #21 innførte.**

### Hvor «Kari»/«Ola»/«Hovedkorps»/«juniorkorps» kommer fra

Ikke en datalekkasje eller noe Claude skrev. `IS_TEST_ENV` (satt når URL-en
inneholder «Korpsapp-test») kobler til en EGEN, navngitt Firestore-database
kalt `test`: `getFirestore(firebaseApp, 'test')`. Denne databasen deles med
vilje av alle miljøer som teller som «test» — inkludert annen lokal testing
mot samme sti. Bekreftet i Firebase Console: dokumentet `hovedkorps` i
`korpsapp`-samlingen i `test`-databasen har `updatedAt: 19. august 2026,
09:34:12 UTC+2` og et `updatedBy`-felt — begge skrives kun av en ekte,
autentisert lagring (`saveKorpsToFirestore`, som krever
`auth.currentUser`). Data er derfor ekte og forventet, ikke en bug.

### Mekanismen som er funnet (men ikke hele årsaken)

- **«Velg korps» ER en modal**, ikke en bakgrunnsskjerm. `showProjectPicker()`
  kaller `window.showModal(...)`, som fyller den generiske
  `#modal-container`. Åpnes den automatisk (`closable=false`, fra
  `onAuthStateChanged` når `currentProjectId` mangler, ELLER fra
  `startKorpsSync`s håndtering av slettet/mistet-tilgang-korps) får den
  **ingen lukkeknapp** — med vilje, siden man skal velge et korps, ikke
  avvise valget.
- **Slagverksliste er et eget, dedikert element** (`#instrument-list-modal`,
  IKKE inne i `#modal-container`), styrt av
  `openInstrumentListModal()`/`closeInstrumentListModal()` — to linjer,
  ren `classList`-veksling. Isolert sett virker denne koden helt riktig.
- Begge bruker `.modal-bg { z-index: 50 }`. `#instrument-list-modal` står
  senere i DOM-rekkefølgen (linje 857) enn `#modal-container` (linje 767),
  så den skal korrekt tegnes og motta klikk øverst når begge er åpne.
- **Arbeidshypotese:** en overgang (korpset mister tilgang, blir slettet,
  eller `currentProjectId` nullstilles) kaller `showProjectPicker(false)`
  MENS Slagverksliste-modalen allerede står åpen fra en tidligere
  handling. Ingen av kodeveiene lukker andre åpne modaler før de åpner
  sin egen. Lukker man Slagverksliste (som fungerer fint isolert), avdekkes
  «Velg korps» — som med vilje ikke har noen lukkeknapp — og det oppleves
  som at ingenting skjedde.
- **Ikke forklart:** hvorfor et helt ferskt, inkognito besøk skulle vise
  Slagverksliste allerede åpen. Det krever normalt et bevisst klikk på
  «✏️ Rediger», som ikke passer med «ingen innlogging, rett til ødelagt
  skjerm». Dette er hovedhullet som gjenstår å tette.

### Uavklart om selve innloggingen

Brukeren rapporterte «ingen innlogging» før den ødelagte skjermen vises, på
tvers av inkognito og flere enheter (også mobil på mobildata) — men ekte
Firestore-data laster inn, noe som krever ekte autentisering. Ingen
`signInAnonymously` eller Credential Management API finnes i koden, så en
eventuell stille innlogging skjer i så fall via nettleserens egen
passordhåndtering (f.eks. iCloud-nøkkelring delt mellom brukerens enheter),
ikke via noe appen selv gjør. Et forsøk på å lese `localStorage`-nøkkelen
`firebase:authUser...` ga `undefined` — men dette beviser trolig ingenting,
siden Firebase sin v9+ modul-SDK (10.13.0, som appen bruker) lagrer
innloggingsstatus i IndexedDB, ikke `localStorage`. Diagnosen var
sannsynligvis feil verktøy, ikke et reelt «ikke innlogget»-funn.

To diagnostikk-øyeblikksbilder fra brukeren sprikte også:
`authGateHidden: true` (innlogget-tilstand) i ett, mot tomme
`current-user-label`/`current-project-label` og `currentProjectIdStored:
null` i et annet. Kan være en race condition i `onAuthStateChanged` (den
fyres flere ganger — først med `user: null` under oppstart, så på nytt når
ekte tilstand er avklart), eller det kan rett og slett være to forskjellige
sideinnlastinger som ble sammenlignet. Ikke avklart.

### Hvorfor dette ikke ble løst i denne runden

All undersøkelse over ble gjort UTEN egen innlogging — ingen ekte
brukerkontotilgang var tilgjengelig for å reprodusere levende og teste en
retting. Neste steg krever noen med ekte innlogging som kan gå steg for
steg gjennom akkurat hvordan man havner her, ideelt med
utviklerverktøyets Network/Console-faner åpne underveis.

### Oppfølging (2026-08-19): utløseren er fortsatt ukjent, sikkerhetsnett er på plass

Gjennomgikk hele kodebasen for kall til `openInstrumentListModal()`: den har
**nøyaktig ett** kallsted i hele `index.html` — knappen «✏️ Rediger»
([index.html:603](../../index.html)). Ingen automatisk kode — ikke
`window.onload`, `seedDefaultInstrumentPhotos`, `applyKorpsData`,
`onAuthStateChanged` — kaller den noensinne. Markupen starter også korrekt
skjult (`class="modal-bg hidden"`). Det finnes altså **ingen kodevei i dagens
kildekode** som åpner Slagverksliste uten et bevisst klikk på Rediger.

Det gjør ikke gåten mindre — det skjerper den. Hovedhullet fra først i kortet
står fortsatt helt åpent: hvorfor en fersk, ukklikket økt noen gang endte opp
med Slagverksliste allerede åpen.

**Ny arbeidshypotese, verdt å teste:** to reelle, uavhengige cache-relaterte
feil i `sw.js` ble funnet og rettet i `test` samme dag (stale
`cdn.tailwindcss.com`-oppføring i `ASSETS`, og en race i
`fetch`-handleren der `res.clone()` kjørte etter at responsen allerede var
returnert — se `sw.js`-historikken på `test`). Gitt det mønsteret er det
fullt mulig at den rapporterende enheten kjører en **gammel, cachet
`index.html`** fra en service worker som aldri har oppdatert seg — en versjon
der en siden fjernet kodevei kanskje åpnet modalen automatisk. Det ville
forklare «ingen klikk, flere enheter, reproduserbart» uten at det trenger å
være en feil i dagens kode i det hele tatt. Ikke bekreftet — krever å se
hvilken versjon som faktisk kjører på et rammet apparat (DevTools →
Application → Service Workers / Cache Storage).

**Sikkerhetsnett lagt til uansett:** `openInstrumentListModal()` kaller nå
`closeModal()` først, og `showModal()` (som `showProjectPicker` og alle andre
dialoger går gjennom) kaller nå `closeInstrumentListModal()` først. De to
modal-systemene kan ikke lenger stables, uansett hva som utløser dem —
verifisert direkte i konsollen i begge retninger. Dette fjerner ikke årsaken,
men gjør at symptomet (fastlåst skjerm) ikke kan oppstå igjen selv om
utløseren aldri blir funnet.
