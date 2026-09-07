---
title: Skill manglende tilgang fra manglende nett i feilmeldinger
created: 2026-09-07
updated: 2026-09-07
---

## Mål

Når Firestore svarer `permission-denied`, sier appen «Sjekk nettforbindelsen og
prøv igjen». Det er feil årsak, og det sender brukeren — og den som feilsøker —
i motsatt retning av problemet. Når dette er ferdig skal en tilgangsfeil si at
det er en tilgangsfeil, og en nettverksfeil skal fortsatt si nettverk.

## Plan

- [ ] Gå gjennom alle stedene som i dag skylder på nettet uansett årsak:
      [1129](../../index.html), [1168](../../index.html),
      [1225](../../index.html), [1286](../../index.html),
      [1317](../../index.html), [1480](../../index.html),
      [1827](../../index.html), [1912](../../index.html)
  - `createProject` ([1127](../../index.html)) gjør allerede det riktige og
    skiller ut `permission-denied` — bruk den som mønster, ikke finn opp noe
    nytt
- [ ] Lag én felles hjelpefunksjon som oversetter en Firestore-feil til
      brukertekst, i stedet for å gjenta `e.code === 'permission-denied'` på
      åtte steder
  - Minst tre tilfeller er verdt å skille: `permission-denied` (tilgang),
    `unavailable`/`failed-precondition` (nett eller offline), og alt annet
    (ukjent — si det, ikke gjett)
- [ ] Skriv tekstene så de sier hva brukeren faktisk kan gjøre. «Du har ikke
      tilgang» er riktig, men blindvei hvis årsaken er at reglene er borte;
      teksten bør peke videre til den som drifter appen
- [ ] Logg alltid `e.code` til konsollen ved siden av meldingen, også der
      brukerteksten er generisk — det var mangelen på nettopp dette som gjorde
      utfallet 2026-09-07 tregere å finne enn det trengte å være
- [ ] Vurder samme skille i `showAuthError` ([973](../../index.html)):
      «Innlogging med Google feilet. Prøv igjen» ([1978](../../index.html))
      dekker i dag alt fra blokkert popup til feil domene til nede-tjeneste
  - `auth/popup-blocked` er verdt sin egen tekst — den er brukerens egen
    nettleser, ikke appen, og «prøv igjen» hjelper ikke uten at man skrur av
    popup-blokkering

## Verifisering

- [ ] Fremkalt `permission-denied` gir en tilgangsmelding, ikke en
      nettverksmelding
  - Kan fremkalles trygt ved å lese en samling appen ikke har regler for,
    f.eks. `getDocs(collection(db, 'finnes-ikke'))` fra konsollen
- [ ] Ekte offline (DevTools → Network → Offline) gir fortsatt
      nettverksmeldingen
- [ ] `e.code` står i konsollen i begge tilfeller
- [ ] Testet på https://beitnes.net/Korpsapp-test
- [ ] Merget til `main`

## Notater

### Hvorfor dette kortet finnes

Under utfallet 2026-09-07 (se kort #25) meldte appen «Kunne ikke hente listen
over korps. Sjekk nettforbindelsen og prøv igjen». Nettet var helt i orden;
Firestore-reglene for `korpsIndex` var slettet. Feilmeldingen pekte aktivt bort
fra årsaken, og den ekte feilkoden ble bare synlig ved å kjøre spørringen for
hånd i konsollen.

Meldingen er dessuten den samme enten man er innlogget eller ikke, noe som
gjorde at feilen først ble rapportert som et påloggingsproblem — den delen
virket hele tiden.
