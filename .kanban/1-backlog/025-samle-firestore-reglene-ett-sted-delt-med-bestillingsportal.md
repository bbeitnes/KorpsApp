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

- [x] Rett opp dagens utfall FØRST — dette kortet er den varige fiksen, ikke
      strakstiltaket. Se kort-notatene for målt status per blokk
  - Gjort 2026-09-07: begge databasene verifisert grønne, korpsvelgeren lister
    korps igjen på både produksjon og test. Se notatene for hva som FAKTISK var
    galt (ikke det som først ble antatt)
- [ ] Hent det som FAKTISK ligger aktivt på begge databasene (Firebase Console
      → Firestore → Regler, eller Rules REST API) — ikke anta at repo-kopiene
      er hele bildet. Bestillingsportals `firebase.json` har ingen
      `firestore`-seksjon og repoet har ingen `.firebaserc`, så reglene der
      publiseres trolig for hånd i Console og kan ha drevet fra repo-fila
- [ ] Finn og rydd opp i ALLE kopiene av regelsettet før du velger én kilde —
      det er minst fire i omløp i dag, og det er selve problemet:
  - `Korpsapp/firestore.rules` i dette repoet (kun KorpsApp-delen)
  - `~/Claude/Bestillingsportal/firestore.rules` (kun Bestillingsportal-delen)
  - `/Documents/KorpsApp/KorpsApp/firestore.rules` — en TREDJE kopi, oppdaget
    2026-09-07 fordi den er oppgitt som kilde i toppkommentaren til det som
    ligger utrullet på `(default)`. Uavklart hva den inneholder og om den er
    ajour med dette repoet
  - Det som er utrullet i Console på hver av de to databasene — den eneste
    kopien som faktisk håndhever noe
- [ ] Rett toppkommentaren i det utrullede regelsettet på `(default)` samtidig:
      den sier at «test»-databasen har sitt eget regelsett «uten
      KorpsApp-delen». Det er ikke lenger sant — KorpsApp-blokkene ble lagt inn
      på `test` 2026-09-07. En kommentar som beskriver virkeligheten feil er
      farlig akkurat her, siden den leses rett før noen publiserer
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

To forbehold ved denne probe-metoden, begge lært den harde veien samme dag:

1. **«Mangler» betyr «ingen regel gjaldt denne stien»**, ikke nødvendigvis at
   blokken er borte fra fila. På `(default)` LÅ `korpsIndex`-blokken der — bare
   på feil nivå (se under).
2. **Den virker kun på samlinger med en `resource == null`-gren** i leseregelen
   (`korpsapp`, `korpsIndex`, `organisasjoner`, `prosjekter`). Samlinger som
   `soknader`, `bestillinger`, `kjop` og `aktivitetslogg` leser
   `resource.data.organisasjonId` direkte, så de svarer `permission-denied` på
   et ikke-eksisterende dokument selv når reglene er helt i orden. De ble tatt
   med i en probe-runde og ga fire falske «mangler» som kortvarig så ut som at
   Bestillingsportal også var nede.

Dokument-ID-er pakket i doble understreker (`__x__`) er reservert i Firestore
og gir `invalid-argument` — bruk en vanlig ID som `diagnose-finnes-ikke-9f2a`.

### Hvorfor produksjon bare delvis var nede

`korpsapp`-blokken overlevde på `(default)`, så brukere med et korps allerede
lagret i `localStorage` fikk fortsatt synket det korpset. Men `korpsIndex` var
borte, så korpsvelgeren feilet — altså var «Bytt korps» og enhver fersk
innlogging ødelagt, mens de som sto midt i noe ikke merket det. Det forklarer
hvorfor feilen så ut til å ramme bare noen.

Data var uskadd hele tiden. Kun reglene var feil.

### Hva som FAKTISK var galt — ikke det som først ble antatt

Førstediagnosen var «Bestillingsportals regelsett ble publisert over det
sammenslåtte, tredje gang». Det stemte for `test`, men **ikke** for
`(default)`. Der var ingenting overskrevet: `korpsIndex`-blokken lå der hele
tiden, men **én krøllparentes for dypt** — limt inn inne i
`match /arrangementer/{arrangementId}`, etter at `checkpoints` var lukket. Den
ga altså tilgang til stien
`korpsapp/{korpsId}/arrangementer/{arrangementId}/korpsIndex/{korpsId}`, som
ingen kode noensinne spør etter, mens toppnivå-samlingen appen faktisk lister
sto uten regel.

Dette er gyldig syntaks. Console publiserer det uten å klage, og det ser helt
riktig ut når man leter etter «finnes blokken?». **Sjekk nivået, ikke bare at
blokken er der.** Alle `match`-blokker som gjelder toppnivå-samlinger skal ligge
på samme dybde som `match /korpsapp/...` og `match /organisasjoner/...`, rett
inne i `match /databases/{database}/documents`.

Rettelsen ble gjort ved at brukeren limte inn det aktive regelsettet fra
Console, blokken ble flyttet ut, og resten av fila stod urørt tegn for tegn
(verifisert med `diff`: eneste endring var flyttingen pluss én blank linje).
**Den arbeidsmåten — rediger det som faktisk ligger der, ikke gjenskap en
sammenslått fil fra repo-kopiene — er den som bør brukes neste gang.** En
gjenskapt fil kan aldri inneholde mer enn repoene vet om.

### Ikke et sikkerhetshull likevel

Underveis ble det mistenkt at `korpsapp`-regelen på `(default)` var en eldre,
mer åpen variant uten `korpsAllowed(...)`-sjekken, altså at låste korps ikke
var beskyttet i produksjon. **Det var feil** — det utrullede regelsettet hadde
den riktige, håndhevende regelen hele tiden. Ingenting å stramme.

### Verktøybegrensninger som er verdt å vite neste gang

`firebase-tools` har **ingen** kommando for å lese ut det aktive regelsettet —
bare for å rulle ut. Å hente det krever Rules REST API
(`GET .../rulesets/{id}`, ID-er fra `GET .../rulesets`) eller Console. Et
forsøk på å kalle API-et med CLI-ens lagrede token ble blokkert av
tillatelsessystemet, så i praksis må et menneske hente det fra Console.
