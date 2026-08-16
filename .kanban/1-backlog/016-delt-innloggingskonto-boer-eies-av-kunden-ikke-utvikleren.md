---
title: Delt innloggingskonto bør eies av kunden, ikke utvikleren
created: 2026-08-16
updated: 2026-08-16
---

## Mål

Den delte innloggingskontoen hos hver kunde skal være en adresse **kunden**
rår over, ikke utviklerens private Gmail. I dag er `bbeitnes@gmail.com` delt
konto for Kvinner i Kor, og Musikkforeningen Suoni settes opp på den samme
adressen fordi de ikke hadde noe alternativ klart. Etterpå skal begge stå på
hver sin adresse som overlever at utvikleren slutter å være involvert.

Oppdaget 2026-08-16 under oppsettet av Suoni: adressen ligger i klartekst i
`config.js`, som serveres til enhver besøkende.

## Plan

- [ ] Skaff en rolleadresse per kunde som kunden selv eier
      (f.eks. `korpsapp@<kundens-domene>`, eller en egen postkasse de
      administrerer). Uten en adresse kunden faktisk rår over løser ikke
      dette noe — da er det bare en annen privat konto.
- [ ] Opprett den nye brukeren i Firebase Auth i kundens eget prosjekt, med
      **samme passord** som den gamle. Da er byttet usynlig for brukerne —
      se «Byttet er billigere enn det høres ut» i Notater.
- [ ] Bytt `auth.sharedLoginEmail` i `config/<kunde>.js` og rull ut.
- [ ] Gjør det for Kvinner i Kor
      ([config/kvinner-i-kor.js](../../config/kvinner-i-kor.js)) og for
      Musikkforeningen Suoni.
- [ ] Bestem hva som skjer med den gamle `bbeitnes@gmail.com`-brukeren i hvert
      prosjekt — slettes, eller beholdes som reservevei inn.
- [ ] Skriv ned regelen for nye kunder, så neste oppsett ikke gjentar dette.
      I dag finnes den ingen steder; Suoni ble satt opp på en privat adresse
      nettopp fordi ingenting sa noe annet.

Uavklart: Har Kvinner i Kor og Suoni i det hele tatt et domene eller en
postkasse de kan eie en slik adresse i? Hvis ikke, hva er alternativet — en
gratis postkasse opprettet i korpsets navn, med passordet delt mellom to
tillitsvalgte?

Uavklart: Skal passordet byttes samtidig, eller holdes uendret? Uendret gjør
byttet usynlig for brukerne, men da lever et passord utvikleren kjenner videre
på en konto kunden nå eier.

Uavklart: Blir dette kortet overflødig av kort
`innlogging-med-personlige-brukere-i-stedet-for-delt-passord`? Det fjerner
delt konto helt. Hvis det kortet gjøres først, er dette bortkastet arbeid —
hvis det drøyer, er dette billig å gjøre nå.

Uavklart: Skal den gamle kontoen slettes eller beholdes? Sletting er ryddigst,
men fjerner samtidig utviklerens vei inn hvis kunden mister passordet sitt.

## Verifisering

- [ ] Testet på https://beitnes.net/Korpsapp-test
- [ ] Merget til `main`

## Notater

### Hva som faktisk er eksponert

`config.js` serveres til enhver besøkende. Bekreftet 2026-08-16:

```
$ curl -s https://kvinner-i-kor.web.app/config.js | grep sharedLoginEmail
    sharedLoginEmail: 'bbeitnes@gmail.com',
```

Dette er ikke en regresjon fra kort 7. Adressen lå tidligere rett i
`index.html` og var like lesbar. Men den ligger nå i en fil som heter
`config.js` med en etikett som sier hva den er, og det gjør den lettere å
finne.

Selve adressen er heller ikke hemmeligheten — den kan ikke være det, siden
klienten må kjenne den for å logge inn. Poenget er eierskapet: passordreset
for kontoen går til den som eier innboksen, og det er i dag utvikleren, ikke
korpset.

### Byttet er billigere enn det høres ut

Brukerne taster **bare passordet**. `doSharedLogin()`
([index.html:1986](../../index.html)) henter adressen fra konfigurasjonen:

```js
await signInWithEmailAndPassword(auth, SHARED_LOGIN_EMAIL, pw);
```

Beholdes passordet, merker ingen at adressen er byttet — ingen beskjed skal
ut, ingenting skal huskes. Det er derfor dette kan gjøres når som helst, og
det er også derfor det aldri har blitt gjort.

`currentUserLabel()` ([index.html:990](../../index.html)) sammenligner mot
`SHARED_LOGIN_EMAIL` fra konfigurasjonen, så etiketten «Delt konto» følger med
av seg selv. Allerede lagrede data beholder sin `updatedBy`-streng uendret.

### Beslektet

`innlogging-med-personlige-brukere-i-stedet-for-delt-passord` (kort 15) gjør
delt konto overflødig helt. Dette kortet er lappen som gjelder inntil det er
på plass.
