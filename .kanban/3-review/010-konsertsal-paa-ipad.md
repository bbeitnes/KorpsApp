---
title: Konsertsal på iPad
created: 2026-08-16
updated: 2026-08-19
---

## Mål

Konsertsal skal kunne brukes fra iPad: tildele et navn til en plass, bytte
navn og fjerne en tildeling.

**Venter på piloten.** `korpsoppsett-maa-kunne-brukes-fra-ipad` går opp
trykkveien først og setter mønsteret for tilbakemelding og synlighet. Dette
kortet ruller ut det samme til konsertsalen. Ikke start dette før piloten er
i `4-done`.

Forventningen er at konsertsalen står **mye bedre** enn Korpsoppsett gjorde,
fordi `seatClick` allerede har en fullverdig reservevei: trykker man en tom
plass uten å ha valgt et navn, åpnes `showAssignDialog`
([index.html:3872](../../index.html)). Det er nettopp den veien Korpsoppsett
mangler. Kortet er derfor mest sannsynlig verifisering pluss små justeringer,
ikke en ny bug-jakt — men det er en forventning, ikke en konklusjon.

## Plan

- [x] Verifiser tildeling på enhet: trykk en tom plass uten valgt navn →
      `showAssignDialog` skal åpne og la deg velge derfra
      ([index.html:3872](../../index.html)).
      → Bekreftet i nettleser resizet til 1024×1366 (iPad Pro 12,9" i
      fullskjerm), mot ekte data på SSM - Hovedkorps / «Korpstur Garda 2026».
      Trykk på tom plass uten valg åpner «Tildel»-dialogen; avbrutt uten å
      skrive noe. Gjenstår på ekte enhet.
- [x] Verifiser den andre veien: velg navn i sidepanelet først, trykk så en
      tom plass — da skal navnet plasseres direkte uten dialog.
      → Bekreftet samme sted: valgte «Anna Gundlach Clausen» i sidepanelet,
      trykk på tom plass plasserte henne direkte uten dialog (13/28 → 14/28).
      Fjernet tildelingen igjen etterpå via «✕ Fjern tildeling» — ingen
      testdata står igjen. Gjenstår på ekte enhet.
- [x] Verifiser bytte og fjerning via `showSeatOptions`
      ([index.html:3823](../../index.html)). Merk at «↔️ Flytt» med vilje
      ikke finnes i konsertsal — plassene er faste, så det er riktig.
      → Bekreftet i samme nettleser-oppsett, samme arrangement. Trykk på
      tildelt plass viser kun «🔄 Bytt navn/instrument» og
      «✕ Fjern tildeling», ingen «↔️ Flytt». «Bytt navn/instrument» åpner
      samme Tildel-dialog som ved ny tildeling. «Fjern tildeling» ble allerede
      bekreftet i forrige steg (opprydding av testtildelingen). Gjenstår på
      ekte enhet.
- [x] Sjekk at et allerede tildelt navn i navnelista oppfører seg forståelig.
      Det kaller `locateName` ([index.html:2530](../../index.html)), som
      ruller til plassen og blinker — bekreft at blinket faktisk er synlig på
      iPad-skjermen etter rullingen.
      → Testet ved å krympe nettleservinduet til 1024×300 (tvinger plassen
      utenfor skjermbildet, siden salen på dette arrangementet er for liten
      til å trigge scroll ved normal iPad-høyde). Bekreftet via DOM-mål at
      `scrollIntoView` faktisk løser plasseringen riktig — plassen endte
      innenfor viewporten (y:116 av 300) — selv i appens lagdelte layout der
      sidepanel og hovedinnhold har hvert sitt uavhengige scroll-område.
      Selve blink-klassen (`locate-flash`) er udiskutabelt delt kode (samme
      kall, ingen modus-sjekk) og satt via en vanlig CSS-animasjon uten
      betingelser — ikke noe som kan virke i Korpsoppsett (allerede
      pilot-bekreftet) uten å virke i konsertsalen. Selve det 1,6s lange
      visuelle blinket lot seg ikke fange i et skjermbilde over
      automasjonens rundtur-forsinkelse — det gjenstår derfor å se det med
      øyet på ekte enhet, men mekanismen er kodebekreftet riktig.
      **Sidemerknad:** underveis i denne testen dukket det opp to nye
      tildelinger (Aurora Mørken, Embla Braseth) jeg ikke selv utløste — en
      reell samtidig bruker redigerte «Korpstur Garda 2026» live i appen
      mens jeg testet. Bekreftet med Bjørn Erik at det var forventet; ikke
      rørt, siden `locateName` uansett ikke skriver noe.
- [x] Legg til banneret fra piloten (`formationBannerHtml`,
      [index.html:3719](../../index.html)) i `renderConcert`
      ([index.html:3076](../../index.html)): når et navn er valgt i
      sidepanelet, vis «👇 Trykk der *X* skal stå · Avbryt» på samme måte som
      i Korpsoppsett, selv om assign-dialogen gjør banneret strengt tatt
      valgfritt her (se «Notater»).
      → `formationBannerHtml` er omdøpt til `selectionBannerHtml` og tar nå
      en valgfri `{static:true}` for flyt-plassering (konsertsalen er en
      flex-kolonne uten reservert overleggsplass, i motsetning til
      korpsoppsettets faste kart). `renderConcert` setter banneret foran
      radene når `selectedName` er satt; ny `clearConcertSelection` speiler
      `clearFormationSelection`. `selectName` kaller nå `renderConcert()` i
      tillegg til `renderFormation()` så banneret dukker opp med en gang.
      Verifisert i nettleser (1024×1366) på SSM - Hovedkorps: banner vises
      ved navnevalg, «Avbryt» rydder valget, plassering fjerner banneret
      igjen. Ingen regresjon i Korpsoppsett — testet flytt-banneret der også.
      Ingen testdata står igjen.
- [x] Test både i fullskjerm (≥1024px) og i Split View (<1024px) på iPad Pro
      12,9" (5. gen).
      → Fullskjerm (1024×1366) allerede dekket i tidligere steg. Split View
      testet ved 768×1024 (samme bredde piloten brukte som referanse for
      «under 1024px»): sidepanelet blir et overlegg med hamburger-meny,
      navnevalg lukker det automatisk og banneret vises riktig plassert
      under «— SCENE —»-linjen, plassering fungerer og fjerner banneret,
      Tildel- og Fjern-dialogene ser riktige ut. Regresjonstestet
      Korpsoppsett på samme bredde — flytt-banneret virker uendret der også
      (fant en forhåndseksisterende, ufarlig detalj: Avbryt-lenken bobler opp
      til kartets egen klikk-handler siden den ligger inni kartet, så en
      ekstra «velg navn først»-melding dukker opp etter avbrytelsen — samme
      mønster fantes allerede i piloten, ikke noe denne endringen innførte,
      og ingen tilstand endres av det). Ekte enhet (iPad Pro 12,9", 5. gen)
      gjenstår.

## Verifisering

- [ ] Testet på https://beitnes.net/Korpsapp-test
- [ ] Merget til `main`

## Notater

**Hvorfor dette er et eget kort:** `renderConcert`
([index.html:3022](../../index.html)) er sin egen renderingsvei, atskilt fra
både Korpsoppsett og gruppekortene. Plassene er faste båser med `data-seat`,
ikke fri plassering på et lerret.

**Den viktige forskjellen fra Korpsoppsett**, funnet under grillingen
2026-08-16: `seatClick` faller tilbake til `showAssignDialog` når ingenting er
valgt. `formationCanvasClick` ([index.html:3464](../../index.html)) har ingen
tilsvarende gren — i Korpsoppsett finnes et sete bare når det har et navn, så
det er ingen tom plass å trykke på, og et trykk på tomt lerret uten valgt navn
gjør bokstavelig talt ingenting. Det er sannsynlig at nettopp dette er grunnen
til at Korpsoppsett feilet på iPad mens de andre modusene ikke har vært
rapportert.

**Opphav:** skilt ut fra `korpsoppsett-maa-kunne-brukes-fra-ipad` etter
grillingen 2026-08-16, der det ble slått fast at trykkveien allerede er koblet
opp i alle modusene og at oppgaven er å verifisere og synliggjøre den, ikke å
bygge den.

### Hvilket mønster som skal kopieres (grillet 2026-08-19)

Lest opp mot piloten sin ferdige kode før spørsmålet ble stilt: tre av fire
deler av «tilbakemeldings- og synlighetsmønsteret» viste seg å allerede være
delt kode, ikke noe formation-spesifikt som må rulles ut:

- `showFlash`-beskjeden i `locateName` har allerede en egen tekst for
  `kind === 'concert'` ([index.html:2530](../../index.html)) — ikke bare
  `formation`.
- `closeSidebar()` ved navnevalg skjer i `selectName` selv
  ([index.html:2495](../../index.html)), ikke bak en `mode === 'formation'`-
  sjekk.
- Meldingen om at man fortsatt har et navn valgt når man trykker en opptatt
  plass ligger i `showSeatOptions` ([index.html:3823](../../index.html)),
  felles for alle kinds.

Den eneste delen som faktisk er formation-only er banneret
(`formationBannerHtml`, kalt bare fra `renderFormation`,
[index.html:3387–3391](../../index.html)) — konsertsalen har ingen tilsvarende
påminnelse når et navn er valgt.

**Avgjørelse:** legg banneret til i konsertsalen likevel, selv om det ikke er
strengt nødvendig — trykker man en tom plass uten å ha valgt noe, åpner
`showAssignDialog` uansett. Begrunnelse: konsistens med piloten og de andre
modusene veier tyngre enn at banneret teknisk sett er overflødig for en
sekundær vei.
