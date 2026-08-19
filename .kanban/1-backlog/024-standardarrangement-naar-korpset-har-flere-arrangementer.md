---
title: Standardarrangement når korpset har flere arrangementer
created: 2026-08-19
updated: 2026-08-19
---

## Mål

Når et korps har mer enn ett arrangement, skal det være mulig å utpeke ett av
dem som **standardarrangement** — det arrangementet en ny eller «glemt» enhet
(uten lagret preferanse i `localStorage`) automatisk åpnes i, i stedet for
dagens reelt tilfeldige `list[0]`.

`ensureArrangementSelected` ([index.html:1445](../../index.html)) har i dag
denne fallback-rekkefølgen: sist brukt på DENNE enheten (`localStorage`-nøkkel
`korpsapp-current-arrangement-${currentProjectId}`, satt i
[index.html:1432](../../index.html)) → `list[0]` → opprett et nytt
«Standard»-arrangement hvis ingen finnes. `listArrangements`
([index.html:1378](../../index.html)) kaller `getDocs` uten `orderBy`, så
`list[0]` er i praksis alfabetisk på den sluggede dokument-IDen — ikke et
bevisst valg. Siden korpset bruker delt innlogging (se korpsminne om delt
konto), betyr det at en ny enhet/bruker kan lande på et vilkårlig gammelt
arrangement i stedet for det som faktisk er aktuelt akkurat nå (f.eks. en
pågående tur).

## Plan

- [ ] Bekreft antakelsen over ved å lese `ensureArrangementSelected`
      ([index.html:1445](../../index.html)) og `listArrangements`
      ([index.html:1378](../../index.html)) i detalj — at `list[0]` virkelig
      er usortert/alfabetisk og ikke f.eks. opprettelsesrekkefølge.
- [ ] Legg til et felt som markerer hvilket arrangement som er standard (se
      Uavklart for hvor det skal lagres).
- [ ] Legg til en måte å sette/endre standarden på i `showArrangementPicker`
      ([index.html:1474](../../index.html)) — se Uavklart for hvordan.
- [ ] Endre fallback-rekkefølgen i `ensureArrangementSelected`
      ([index.html:1469–1470](../../index.html)) til: sist brukt på denne
      enheten (uendret) → standardarrangementet, hvis satt → `list[0]` som
      siste utvei.
- [ ] Rydd opp standard-markøren når arrangementet den peker på slettes, i
      `deleteArrangement` ([index.html:1412](../../index.html)).
- [ ] Vis i `showArrangementPicker` ([index.html:1474](../../index.html))
      hvilket arrangement som er standard, slik at det ikke er usynlig.
- [ ] Test med to+ arrangementer: sett en standard, tøm `localStorage` (eller
      åpne i en ny enhet/inkognitovindu), bekreft at appen åpner standarden —
      ikke `list[0]`.

Uavklart: Hvor skal standard-markøren lagres — som et felt på hvert
arrangement-dokument (`isDefault: true`, må ryddes ett-om-gangen ved bytte),
eller som én referanse på korps-dokumentet (`defaultArrangementId`, krever et
ekstra oppslag men enklere å bytte atomisk)?

Uavklart: Hvem skal kunne sette standarden — alle med tilgang til korpset,
eller bare de med redigeringstilgang (jf. lås-ikonet i korpsvelgeren,
[index.html:1305](../../index.html))? Uklart om «hvem» i det hele tatt er
meningsfullt å skille når korpset bruker delt innlogging.

Uavklart: Skal standardarrangementet override den lokale `localStorage`-
hukommelsen («sist brukt»)? Antakelsen i planen over er nei — standarden er
bare fallback nummer to — men dette er selve poenget med kortet og bør
bekreftes eksplisitt i grillingen.

Uavklart: Skal det være mulig å nullstille standarden (ingen valgt), eller
skal ett arrangement alltid være standard så snart det finnes mer enn ett?

## Verifisering

<!-- Hvordan vet vi at det virker? F.eks.: pushet til `test`, sjekket på
     https://beitnes.net/Korpsapp-test på mobil og desktop. -->

- [ ] Testet på https://beitnes.net/Korpsapp-test
- [ ] Merget til `main`

## Notater

<!-- Filer, funn, blindveier, lenker. Skriv underveis. -->
