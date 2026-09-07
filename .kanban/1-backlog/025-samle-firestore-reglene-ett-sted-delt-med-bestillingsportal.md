---
title: Samle Firestore-reglene ett sted, delt med Bestillingsportal
created: 2026-09-07
updated: 2026-09-07
---

## Mål

Begge databasene i `skiensskolemusikk-b5cbc` deles med Bestillingsportal, og
Firestore har bare ÉTT regelsett per database. I dag finnes de to halvdelene i
hvert sitt repo, og hver utrulling fra én av dem sletter den andres regler.
Det har slått ut produksjon tre ganger (2026-08-10 to ganger, 2026-09-07).
Når dette er ferdig skal det finnes én kilde til sannhet for hver database, og
det skal ikke lenger være mulig å slette den andre appens regler ved å rulle ut
sine egne.

## Plan

- [ ] Rett opp dagens utfall FØRST — dette kortet er den varige fiksen, ikke
      strakstiltaket. Se kort-notatene for målt status per blokk
  - Blokkene som manglet 2026-09-07: `korpsIndex` på `(default)`, og både
    `korpsapp` og `korpsIndex` på `test`
- [ ] Hent det som FAKTISK ligger aktivt på begge databasene (Firebase Console
      → Firestore → Regler, eller Rules REST API) — ikke anta at repo-kopiene
      er hele bildet. Bestillingsportals `firebase.json` har ingen
      `firestore`-seksjon og repoet har ingen `.firebaserc`, så reglene der
      publiseres trolig for hånd i Console og kan ha drevet fra repo-fila
- [ ] Bestem hvor den samlede kilden skal bo. Alternativene, med den åpenbare
      ulempen ved hver:
  - Ett av de to repoene eier hele fila, det andre slutter å ha en
    `firestore.rules` → enkelt, men den andre appens utviklere mister
    oversikten over sine egne regler
  - Et eget lite repo som begge peker på → ryddigst, men én ting til å
    vedlikeholde
  - Behold to filer, men bygg den samlede fila av dem i et steg før utrulling
    → ingen flytting, men krever at begge repoene faktisk kjører det steget
  - Uavklart: hvem som eier Bestillingsportal-repoet til daglig, og om de er
    med på et felles oppsett. Må avklares før valget tas
- [ ] Del databasene i stedet, hvis det viser seg billigere enn å dele
      regelsettet: gi KorpsApp sitt eget Firebase-prosjekt eller sin egen
      navngitte database, så forsvinner hele problemklassen
  - Vurder migreringskostnad: data må flyttes, `config/`-filene peker på
    prosjekt-ID, og delt innlogging (samme Auth) må fortsatt virke
- [ ] Gjør utrulling utrygg å gjøre feil: fjern eller vokt
      `firebase deploy --only firestore:rules` slik at den ikke kan kjøres med
      bare den ene halvdelen. Advarselen i toppen av `firestore.rules` er ikke
      nok — den har vært der siden 10. august og feilen skjedde likevel igjen
- [ ] Skriv ned gjenopprettingsoppskriften der den finnes når det haster:
      hvordan hente forrige regelsett fra ruleset-historikken og flette inn
      igjen

## Verifisering

- [ ] Begge databasene svarer riktig på probe-testen under, for både KorpsApps
      og Bestillingsportals blokker
- [ ] En utrulling fra KorpsApp-siden lar Bestillingsportals regler stå
- [ ] En utrulling fra Bestillingsportal-siden lar KorpsApps regler stå
- [ ] Testet på https://beitnes.net/Korpsapp-test
- [ ] Merget til `main`

## Notater

### Hvordan dette ble funnet (2026-09-07)

Rapportert som «pålogging feiler igjen, får ikke tilgang til korps».
Påloggingen virket hele tiden — brukeren var autentisert som
`nestleder@skiens-skolemusikk.no`. Det som feilet var Firestore:
`permission-denied` på alle korps-lesninger, som appen viser som «Kunne ikke
hente listen over korps. Sjekk nettforbindelsen og prøv igjen» (derav kort
#26).

### Målt status per regelblokk

Målt fra nettleseren med ekte innlogging. Begge regelsettene har en
`resource == null`-gren i lesereglene, så et `getDoc` på en gyldig, men
ikke-eksisterende dokument-ID svarer «finnes ikke» dersom blokken er utrullet,
og `permission-denied` dersom den mangler. Rører ingen data.

| Blokk | `(default)` (produksjon) | `test` |
|---|---|---|
| `korpsapp` | finnes | **mangler** |
| `korpsIndex` | **mangler** | **mangler** |
| Bestillingsportals blokker | finnes | finnes |

Kjør per database med `getFirestore(app, 'test')` mot `getFirestore(app)`.

### Hvorfor produksjon bare delvis var nede

`korpsapp`-blokken overlevde på `(default)`, så brukere med et korps allerede
lagret i `localStorage` fikk fortsatt synket det korpset. Men `korpsIndex` var
borte, så korpsvelgeren feilet — altså var «Bytt korps» og enhver fersk
innlogging ødelagt, mens de som sto midt i noe ikke merket det. Det forklarer
hvorfor feilen så ut til å ramme bare noen.

Data var uskadd hele tiden. Kun reglene var feil.

### Utkast til sammenslått regelsett

Et utkast (Bestillingsportals fil + KorpsApps to blokker, med den doble
`isSignedIn()` slått sammen til én) ble laget 2026-09-07, men **ikke rullet
ut** — det må først sammenlignes mot det som er aktivt i Console, ellers
gjentar man nøyaktig samme feil. Utkastet lå i sesjonens scratchpad og er
trolig borte; det gjenskapes lett fra de to repo-filene.

### Verktøybegrensninger som er verdt å vite neste gang

`firebase-tools` har **ingen** kommando for å lese ut det aktive regelsettet —
bare for å rulle ut. Å hente det krever Rules REST API
(`GET .../rulesets/{id}`, ID-er fra `GET .../rulesets`) eller Console. Et
forsøk på å kalle API-et med CLI-ens lagrede token ble blokkert av
tillatelsessystemet, så i praksis må et menneske hente det fra Console.
