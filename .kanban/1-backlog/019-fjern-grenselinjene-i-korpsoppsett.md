---
title: Fjern grenselinjene i Korpsoppsett
created: 2026-08-18
updated: 2026-08-18
---

## Mål

Grenselinjene i Korpsoppsett skal slutte å stjele oppmerksomhet fra
midtlinjene. Kortet skal avgjøre **hvilken av to veier** som gir det, og gjøre
den ene:

- **A — fjern dem.** Kartet viser bare radens egen midtlinje, den man sikter
  mot, og forklaringen over kartet krymper til én linje. Begrunnelsen er at
  midtlinjene i dag er tydelige nok alene; grenselinjene ble laget da de ikke
  var det.
- **B — la dem alltid følge formen til raden foran.** Grensa blir da en
  dempet gjenklang av raden den hører til i stedet for en egen figur, og flere
  eksisterende inkonsekvenser forsvinner på kjøpet (se Notater).

Uavklart: A eller B. Det er kortets hovedspørsmål, ikke en detalj.

## Plan

Stegene under er delt: først det som må gjøres uansett, så ett sett per vei.
Bare ett av settene skal gjennomføres.

### Uansett

- [ ] Avgjør A eller B. Alt annet henger på dette.
- [ ] Sjekk om noe annet leser grensegeometrien. `formationSampledPath` brukes
      både til midtlinjen og til den syntetiske grense-sonen — den skal
      bestå uansett vei. `resolveFormationDrop` regner ut radbytte helt
      uavhengig av SVG-en, så selve treffelogikken endres ikke av noen av
      alternativene.

### Vei A — fjern dem

- [ ] Fjern grenselinje-løkka i `formationGuidesSvg`
      ([index.html:3330](../../index.html)) — hele `for`-løkka som regner ut
      `boundaryRadius`, `bowKs` og `boundaryGeom`. Midtlinje-løkka rett under
      blir stående uendret.
- [ ] Fjern «Grense mot naborad» fra forklaringen over kartet
      ([index.html:745](../../index.html)). Da står bare «Plasser her» igjen —
      vurder om én enslig forklaring fortsatt gir mening, eller om den også
      kan gå. Uavklart: skal «Plasser her» bli stående alene?
- [ ] Rydd kommentaren over `formationGuidesSvg`. Den forklarer i dag hvorfor
      det er *to* linjespråk («midtlinjen er heltrukket … grenselinjen er en
      svak, tynn stiplet bakgrunnsreferanse»). Med ett språk igjen er halve
      forklaringen feil, ikke bare overflødig.
- [ ] Se på kartet med 4–6 rader og sjekk at radene fortsatt lar seg skille
      fra hverandre uten grenselinjene — særlig der to rader ligger tett.
      Uavklart: hva er testen på at de «lar seg skille»? Ren øyemåling, eller
      et konkret oppsett som må se riktig ut?

### Vei B — grensa arver formen til raden foran

- [ ] Bytt ut `bowKs`-snittet i `formationGuidesSvg`
      ([index.html:3330](../../index.html)) med å kopiere formen til
      `rowGeoms[i]` — raden foran — og bare sette radien til `boundaryRadius`.
      `rowGeoms` er sortert innenfra og ut (`radius = baseRadius + r*rowGap`),
      så `rowGeoms[i]` *er* raden nærmest dirigenten i hvert par.
- [ ] Dekk alle fire radformene, ikke bare bue og slak bue. `center` og
      `left`/`right` skiller seg i `startDeg`/`spanDeg`, og `flat` bruker
      `leftX`/`width` i stedet. Grensa skal arve alle tre variantene.
- [ ] Behold den dempede strekingen (`stroke-dasharray`, opasitet). Vei B
      handler om form, ikke om å gjøre linjene mer synlige — de har allerede
      vært gjennom én runde med «litt tydeligere», og det var den runden som
      startet konkurransen med midtlinja.
- [ ] Se på kartet med en `flat` rad og en `left`/`right` rad i oppsettet.
      Det er der dagens grense er mest på viddene, og altså der vei B skal
      vise seg.

## Verifisering

- [ ] Testet på https://beitnes.net/Korpsapp-test
- [ ] Merget til `main`

## Notater

### Hva som faktisk fjernes

Grenselinjen er den stiplede rav-/amberfargede buen midt mellom to rader. Den
tegnes i `formationGuidesSvg`, som kun brukes på skjerm — utskriften
(`buildFormationPrintHtml`) tegner ingen linjer i det hele tatt, så
**utskrift/PDF er uberørt** av dette kortet.

Kartet har i dag tre lag: grenselinjene, radenes midtlinjer, og boksene med
navn. Dette kortet fjerner det første laget.

### Linjene ble bygget over fem runder

De er ikke noe som havnet der ved et uhell — de ble laget, og så justert fire
ganger til:

| dato | commit |
|---|---|
| 2026-07-31 | Vis grenselinjer mellom rader på kartet |
| 2026-07-31 | Tydeligere farger for midtlinje vs. grenselinje |
| 2026-07-31 | Grenselinjer mot en slak rad følger samme buform |
| 2026-08-01 | Gjør grenselinjen litt tydeligere (tykkere, tettere prikker, høyere opasitet) |
| 2026-08-01 | Tydeligere skille mellom plasseringslinje og grenselinje |

Rekkefølgen er verdt å lese: linjene ble først gjort **tydeligere**, og
deretter måtte midtlinjen gjøres tydeligere igjen for å vinne tilbake
oppmerksomheten. Det er mønsteret til to elementer som konkurrerer. At
midtlinjen «er tydelig nok alene» i dag kan altså like gjerne være resultatet
av den siste runden som et argument for at den første var unødvendig.

Kommentaren i koden sier hva grenselinjen var *til*: den viser «hvor nærmeste
rad faktisk bytter» — altså hvilken rad et trykk lander i. Det er en reell
funksjon, ikke pynt. Spørsmålet kortet må svare på er om den funksjonen
fortsatt trengs, ikke om linjene er pene.

### Vei B: hva den faktisk retter opp

Forslaget kom opp som «kanskje enklere å implementere enn å fjerne dem». Det
er ikke opplagt riktig — vei A sletter kode, vei B skriver ny — men vei B
retter tre ting dagens grenselinje gjør feil, og det er en bedre grunn:

1. **`flat`-rader.** En grense ved siden av en rett rad tegnes likevel som en
   bue. `boundaryGeom` settes aldri med `isFlat`, så `formationSampledPath`
   får en bue å sample. Raden er en strek, grensa er en bue.
2. **`left`/`right`-rader.** Disse spenner 90°, men grensa settes alltid til
   `startDeg: 180, spanDeg: 180`. Grensa er altså dobbelt så lang som raden
   den hører til, og stikker ut i tomrommet ved siden av.
3. **Slake rader.** Her gjør dagens kode allerede halve jobben, men med
   *snittet* av naboenes bow-faktorer. Snittet av to former er ingen av dem —
   mot en slak og en rund nabo blir grensa en tredje figur som ikke matcher
   noen av radene.

Med vei B blir grensa en dempet kopi av raden foran i alle tre tilfellene, og
`bowKs`-snittet forsvinner. Det er trolig grunnen til at den vil oppleves som
roligere: den slutter å være en egen figur på kartet.

Verdt å merke seg at dette peker på et mulig tredje svar — at problemet aldri
var at grenselinjene fantes, men at de hadde feil form. Det bør grillingen
prøve å skille.

### Uavklart, til grillingen

1. **Har grenselinjene noen gang hindret en feilplassering?** De ble laget for
   å vise hvilken rad et slipp havner i. Har det skjedd at et navn havnet i
   feil rad, og linjen viste hvorfor? Uten et slikt tilfelle er de pynt, og da
   er kortet enkelt. Med et slikt tilfelle fjerner vi en sikring.
2. **Er det tettheten som har endret seg?** Kort 18 gjorde nettopp navnene
   lesbare på store oppstillinger. Hvis grenselinjene føles overflødige *nå*,
   er det verdt å vite om det er fordi kartet ble roligere av kort 18 — for da
   gjelder vurderingen kanskje bare de tette oppstillingene, og ikke de små.
3. **Skal «Plasser her» bli stående alene?** En forklaring med ett punkt
   forklarer lite. Enten går den også, eller så er den fortsatt verdt plassen
   fordi den sier hva den heltrukne linja *betyr*.
4. **A, B eller dempe?** Tre veier, ikke to: fjern dem, la dem arve formen til
   raden foran, eller bare dempe dem kraftig igjen (de er allerede blitt
   tydeligere én gang — veien tilbake finnes). Hvilken?
5. **Er det formen eller eksistensen som irriterer?** Vei B finnes fordi
   dagens grenselinje har feil form ved `flat`- og `left`/`right`-rader. Har
   oppstillingene som føltes rotete hatt slike rader i seg? I så fall kan det
   som ser ut som «for mange linjer» egentlig være «én linje som ikke passer
   inn».
