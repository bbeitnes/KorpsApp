---
title: Trykkflatene på kartet er for små
created: 2026-08-17
updated: 2026-08-17
---

## Mål

En plass på korpskartet skal kunne treffes med en finger uten å bomme, også i
et korps av vanlig størrelse. I dag er en plass 43px allerede ved 30
musikanter på et 1000px lerret, mot `--tap-min: 44px`
([index.html:190](../../index.html)) — og under 30px for alt som er større.

Målingene under viser at dette **ikke kan løses ved å heve gulvet**. Buen har
rett og slett ikke plass til 44px-bokser for et korps på 40. Kortet skal
derfor velge mellom å gjøre *treffet* mer tilgivende, å gi lerretet mer plass,
eller å akseptere små bokser og sørge for at det finnes en annen vei til
samme handling.

## Plan

- [ ] **Bestem hva som faktisk skal fikses: treffet eller boksen.** Dette er
      hele avgjørelsen, og resten av planen henger på den. Se «Målingene» —
      alternativene er skissert der, ingen av dem er gratis.
      Uavklart: hvilken vei går vi?
- [ ] Kartlegg hva man faktisk *må* kunne gjøre ved å treffe en plass. I dag:
      flytte, bytte navn, fjerne — alle via `seatClick` → `showSeatOptions`
      ([index.html:3607](../../index.html)). Finnes det allerede en annen vei
      til hver av dem? `locateName` finner en person fra navnelista uten å
      treffe kartet i det hele tatt.
      Uavklart: er «treff plassen» den eneste veien til noen av handlingene?
- [ ] Sjekk om overlappende trykkflater blir et nytt problem. Å utvide
      treffområdet rundt en 20px-boks til 44px betyr at nabobokser i en tett
      rad får *overlappende* treffområder — da bommer man like mye, bare på
      en ny måte.
- [ ] Se på `computeAutoSeatSize`-gulvet ([index.html:3339](../../index.html)),
      som i dag er `20`. Uansett valgt retning bør tallet ha en begrunnelse
      knyttet til `--tap-min`, ikke være et løsrevet magisk tall.
- [ ] Ta med `.avatar` i navnelista: målt **26×26px**, og den er en ekte
      trykkflate (åpner bildevelgeren). Samme defekt, samme fiks-familie.
      `.name-item` selv er 263×44 og går klar.
- [ ] Vurder om `--tap-min` skal håndheves et sted som gjelder bredere enn
      `.btn` ([index.html:419](../../index.html)) — en delt klasse eller en
      util, slik at neste trykkflate ikke må oppdage dette på nytt.
- [ ] Test på ekte iPad, ikke bare i nettleser med musepeker. En muspeker er
      1px; det er nettopp derfor denne feilen har fått stå.

## Verifisering

- [ ] En plass kan treffes med finger på første forsøk i et korps på 40, på
      iPad i fullskjerm
- [ ] Man treffer riktig nabo i en tett rad — ikke bare «en eller annen plass»
- [ ] Oppstillingen ser fortsatt ryddig ut i utskrift/PDF (samme geometri,
      se `buildFormationPrintHtml`)
- [ ] Testet på https://beitnes.net/Korpsapp-test
- [ ] Merget til `main`

## Notater

### Hvor funnet kom fra

Målt under kort 11 (`korpsoppsett-maa-kunne-brukes-fra-ipad`, i `4-done`) og
bevisst lagt igjen der: å heve gulvet endrer layouten for alle store
oppstillinger, og det er en egen avgjørelse.

### Målingene (2026-08-17)

`computeAutoSeatSize(rader, bredde, {seatSize:54}, 20)`, boksstørrelse i px.
Lerretet har `max-width: 1000px` ([index.html:725](../../index.html)), så
1000-kolonnen er taket — det finnes ingen bredere skjerm å redde seg på.

| musikanter | 1000px | 944px | 700px | 500px | 380px |
|---|---|---|---|---|---|
| 20 (4 rader) | 54 | 54 | 54 | 32 | 30 |
| 30 (4 rader) | 54 | **43** | 30 | 20 | 20 |
| 40 (4 rader) | **37** | 34 | 24 | 20 | 20 |
| 50 (4 rader) | **28** | 26 | 20 | 20 | 20 |
| 60 (5 rader) | 30 | 28 | 20 | 20 | 20 |
| 80 (5 rader) | 23 | 21 | 20 | 20 | 20 |
| 100 (6 rader) | 21 | 20 | 20 | 20 | 20 |

**Dette er ikke en kant-sak.** Et helt vanlig korps på 30–40 er allerede under
44px på den bredeste skjermen som finnes. På telefon er nesten alt 20–30px.

### Hvorfor «hev gulvet til 44» ikke er svaret

Gulvet brukes bare når buen er for trang til noe større. Setter man det til 44
uten annet, får man 44px-bokser som *overlapper hverandre* i en tett rad —
oppstillingen blir uleselig, og man bommer fortsatt, bare på en nabo i stedet
for på tomrommet. Buelengden er den harde grensen, ikke gulvet.

### Retninger som er skissert, ikke valgt

Ingen av disse er utredet — de står her for at grillingen skal ha noe å ta
tak i, ikke som en anbefaling.

1. **Større treffområde enn tegnet boks.** En usynlig padding rundt hver
    plass. Billigst, men kolliderer med nabo-plasser i tette rader — se
    plansteget om overlapp.
2. **Zoom/panorering på lerretet.** Løser det ordentlig og skalerer til korps
    av alle størrelser, men er en ny interaksjonsmodell, og knipe-zoom mot
    trykk-for-å-plassere må da holdes fra hverandre (jf. det åpne punktet om
    rulling/zoom fra kort 11).
3. **La kartet bli større enn 1000px / høyere.** Enkelt, men flytter bare
    grensen litt, og gjør utskriften vanskeligere.
4. **Godta små bokser, og sørg for at hver handling har en vei utenom kartet.**
    `locateName` finnes allerede. Da er kartet for oversikt og grovplassering,
    og navnelista for presisjon.

### Beslektet

Kort 11 la inn `showFlash` og et synlig «Trykk der X skal stå»-banner. Den
trykkveien virker, men den plasserer *på buen* — den krever ikke at man
treffer en eksisterende boks. Det er derfor kort 11 kunne lukkes uten at
dette var løst: å plassere noen er lett, å treffe noen som allerede står der
er det som er vanskelig.

Oppfølgingskortene for de andre modusene (#9 gruppeinndeling, #10 konsertsal,
#14 rom og vakter) har faste båser i stedet for fri plassering på en bue.
Sjekk om de har det samme problemet før løsningen her antas å gjelde dem òg.
