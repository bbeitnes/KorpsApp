---
title: Arkitekturgjennomgang: struktur, tokens og CDN-risiko
created: 2026-08-14
updated: 2026-08-14
---

## Mål

Gå gjennom hvordan appen er bygget opp, med ett spørsmål som målestokk:
**hva gjør neste endring dyr?** To ting peker seg ut — at all koden ligger i
én fil på 4912 linjer, og at navnene på farger og mål ikke lenger stemmer
etter Broadsheet-redesignet. I tillegg skal én konkret risiko vurderes:
appens utseende hentes fra en server utenfor vår kontroll.

**Dette kortet handler ikke om fart.** Grillingen slo fast at det ikke finnes
noe fartsproblem å løse: en håndfull brukere, alltid på godt nett, og
lastetiden oppleves som helt grei. Måling av lastetid, skrifter og
Firestore-bruk er derfor bevisst holdt utenfor.

**Kortet endrer ikke appen.** Det leverer en rapport i `## Notater`, og hvert
funn som er verdt å gjøre blir sitt eget kort i backlog. Samme framgangsmåte
som fargekortet, som endte med tre nye kort.

## Plan

- [ ] Steg 1 — Kartlegg filstrukturen
  - 4912 linjer i én fil: to script-blokker på ca. 1100 og 2900 linjer, én
    CSS-blokk på ca. 370, pluss to små `<style>`-blokker inne i JavaScript
    ([index.html:4601](../../index.html), [index.html:4676](../../index.html))
  - Tegn opp hvor hver av de fem modulene begynner og slutter:
    Billettfordeling, Korpsoppsett, Romfordeling, Vaktlister, Gruppeinndeling
  - Let etter samme logikk skrevet flere ganger — det er dette som koster når
    en ny funksjon skal inn i en modul som finnes fra før
  - Let etter død kode. Merk: fargekortet mistenkte død kode og tok feil, så
    her må hver mistanke bekreftes før den skrives ned som funn
- [ ] Steg 2 — Gjennomgå token-taksonomien
  - Tre navnelag oppå hverandre: systemtokens (`--color-*`, 53 stk), appens
    palett (`--farge-*`, 45 stk) og Tailwind-klassene i markupen
  - **Klassenavnene lyver:** `bg-indigo-600` maler cyan, `text-red-500` maler
    magenta. 292 slike bruk. Den som leser koden blir aktivt villedet
  - Vurder om mellomlaget `--farge-*` fortsatt gjør en jobb, eller om det nå
    bare er et ekstra ledd å slå opp i
  - 45 `style="..."` rett i markupen omgår systemet helt — kartlegg hva de
    gjør og om de burde vært tokens
  - Finnes det tokens for avstand og typografi som burde vært brukt, men ikke
    er det? `--space-*` og `--font-*` er definert; sjekk hvor mye de brukes
  - Ta med de to «avvikerne» fra fargekortet
    (`--farge-ok-bakgrunn-avvik`, `--farge-ok-tekst-avvik`)
- [ ] Steg 3 — Vurder byggesteg som felles løsning
  - Tailwind hentes i dag fra `https://cdn.tailwindcss.com`
    ([index.html:16](../../index.html)) — **uten versjonsnummer**. Det er
    Tailwinds utviklingsversjon, som selv sier den ikke er ment for drift
  - 545 `class=`-attributter og 114 ulike klasser avhenger av den. Faller
    adressen bort eller endrer innhold, vises appen som ustylet tekst for
    alle, på en dag ingenting er endret
  - Service workeren ([sw.js](../../sw.js)) cacher adressen, så
    gjengangere er delvis beskyttet — men ikke førstegangsbesøkende. Vurder
    hvor mye den beskyttelsen egentlig er verdt
  - Et byggesteg løser tre ting samtidig: Tailwind bakes permanent inn,
    kildekoden kan splittes i flere lesbare filer, og serveren får fortsatt
    én selvstendig fil. Vurder om det holder det det lover
  - Merk: `deploy.yml` kopierer `./*` med SFTP uten bygg i dag. Et byggesteg
    må inn her, og det er denne filen som må endres
- [ ] Steg 4 — Skriv rapporten i `## Notater`
  - Hvert funn med: hva det koster i dag, hva det koster å fikse, og hvor
    stor risikoen er for at utseendet endrer seg
  - Sortert etter nytte delt på risiko, ikke etter hvor interessant det er
- [ ] Steg 5 — Opprett oppfølgingskort i backlog for funnene som er verdt å gjøre

## Verifisering

- [ ] Rapporten er lesbar for en ikke-teknisk leser: hvert funn forklarer
      konsekvensen i praksis, ikke bare hva som er teknisk galt
- [ ] Hvert funn om død kode eller duplisert logikk er bekreftet, ikke antatt
- [ ] Testet på https://beitnes.net/Korpsapp-test — kortet endrer ingen kode,
      så kravet her er at appen er uendret etter at rapporten er lagt til
- [ ] Merget til `main`

## Notater

### Avklart i grilling (2026-08-14)

**Fartsarbeidet ble kuttet, og det var grillingens viktigste resultat.**
Utkastet startet med to steg om måling og lasteoptimalisering. Fire svar
avlivet dem: ingen konkret utløsende hendelse, en håndfull brukere, appen
oppleves som helt grei, og den brukes aldri uten nett. Å optimalisere
lastetid her ville vært arbeid uten mottaker. Bjørn Erik sin opprinnelige
formulering — «særlig taksonomi for tokens» — traff bedre enn utkastet.

**Firestore-bruk er utenfor.** Samme begrunnelse: ingen symptomer, ingen
klage. Å ta det med ville vært scope-vekst forkledd som grundighet.

**Rapporten skal ligge i `## Notater`, ikke i egen fil i repoet.** Det er
mønsteret fra fargekortet, og en egen fil er én ting til som kan bli
utdatert.

**CDN-risikoen skal fjernes, ikke bare dokumenteres.** Argumentet som
overlevde er robusthet, ikke fart: en uversjonert avhengighet utenfra kan
ta ned utseendet på appen uten at noen har rørt koden.

**Byggesteg er akseptert med åpne øyne.** Prisen er forstått og godtatt:
filen på serveren blir maskingenerert, så den kan ikke lenger rettes for
hånd — alt må gå via GitHub. Brekker bygget, oppdateres ikke appen før noen
teknisk har fikset det. Gevinsten er at tre problemer løses av én endring.

**Struktur og tokens skal ha lik vekt.** Her ble en anbefaling overstyrt, og
det er verdt å vite hvorfor: siden neste arbeid er *nye funksjoner i
eksisterende moduler* og ikke flere utseende-endringer, ble det anbefalt å
legge mest kraft på filstrukturen — det er den som koster når en funksjon
skal inn. Bjørn Erik valgte lik vekt likevel. **Konsekvens: kortet blir
større enn det ellers ville vært.** Sprer arbeidet seg, er steg 2 det som
skal nedskaleres først, siden det er det med svakest dokumentert gevinst.

### Grunnlag samlet før grillingen

- 4912 linjer, 245 kB, én fil
- 53 systemtokens, 45 palett-variabler, 292 Tailwind-fargeklasser i bruk
- 545 `class=`-attributter, 114 ulike klasser
- 45 `style="..."` rett i markupen
- Deploy er ren SFTP-kopi av `./*`, uten byggesteg, til
  `Korpsapp` (main) og `Korpsapp-test` (test)
