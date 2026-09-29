---
title: Ta ned kunden Kvinner i Kor
created: 2026-09-29
updated: 2026-09-30
---

## Mål

Kvinner i Kor bruker ikke lenger KorpsApp. Repoet skal slutte å bygge og rulle
ut til dem, og alt som fortsatt omtaler dem som en kunde i drift skal rettes.
Etterpå har KorpsApp to kunder: Skiens skolemusikk (SFTP til beitnes.net) og
Musikkforeningen Suoni (Firebase Hosting).

## Plan

I repoet (går rett til `main` — ingenting her kan verifiseres på test-siden):

- [x] Slett `.github/workflows/deploy-kvinner-i-kor.yml`, så ingen push til
      `main` lenger rører prosjektet `kvinner-i-kor`.
- [x] Slett `config/kvinner-i-kor.js`. Nøklene der er offentlige av design,
      så det er ikke en sikkerhetsrydding — filen er bare død.
- [x] Fjern aliaset `kvinner-i-kor` fra `.firebaserc`.
- [x] Rett tabellen i `CLAUDE.md` og kommentaren øverst i
      `deploy-musikkforeningen-suoni.yml`, som viste til den slettede filen.
- [x] Rett backlog-kortene 15 og 16, som begge regnet Kvinner i Kor som en
      kunde det skulle gjøres noe for.

Utenfor repoet (må gjøres av den som eier kontoene, i denne rekkefølgen):

- [ ] Ta ned nettstedet: `firebase hosting:disable --project kvinner-i-kor`.
      Reverserbart — en ny `firebase deploy` setter det opp igjen.
- [ ] Slett GitHub-hemmeligheten `FIREBASE_SERVICE_ACCOUNT_KVINNER_I_KOR`.
      Ingen arbeidsflyt bruker den lenger.
- [ ] Slett tjenestekontoen `github-action-*@kvinner-i-kor.iam.gserviceaccount.com`
      i Google Cloud IAM, eller hopp over hvis hele prosjektet slettes.
- [ ] Bestem om Firebase-prosjektet `kvinner-i-kor` skal slettes. Det tar med
      seg Firestore-dataene (romfordelingene deres) og Auth-brukeren. Google
      holder prosjektet i 30 dager før det er borte for godt.

## Verifisering

- [ ] Testet på https://beitnes.net/Korpsapp-test — ikke aktuelt, endringen
      er bare arbeidsflyt, kundeoppsett og dokumentasjon.
- [x] Merget til `main`
- [ ] `https://kvinner-i-kor.web.app` svarer ikke lenger med appen.
- [ ] Neste push til `main` kjører bare `deploy.yml` og
      `deploy-musikkforeningen-suoni.yml` under Actions.

## Notater

### Hva som ble kartlagt 2026-09-29

`grep -ril kvinner` over repoet (uten `node_modules` og `.git`) traff ni
filer. De som er rettet står i planen. De som er latt stå:

- Kort 7, 17 (`4-done`/`2-in-progress`): historikk over hvordan kunden ble
  satt opp og flyttet fra egen gren til `config/`. Notatene der beskriver
  hva som skjedde, og skal ikke skrives om.
- `firestore.rules`: nevner ikke Kvinner i Kor. Regelsettet var kundens hele
  bilde i deres eget prosjekt, og trenger ingen endring for de to som er
  igjen.

Kundegrenen `customer/kvinner-i-kor` ble allerede slettet under kort 7, så
det er ingen grener å rydde.

### Hvorfor den delen utenfor repoet er skilt ut

Alt utenfor repoet er enten uopprettelig (hemmeligheten, prosjektet med data)
eller synlig utad (nettstedet forsvinner). Det gjøres derfor bevisst, ett
steg om gangen, og ikke som del av en commit.

### Sjekklisten for neste gang en kunde legges ned

1. Slett arbeidsflyten før noe annet, ellers ruller neste push til `main`
   ut til et prosjekt som er på vei bort.
2. Slett `config/<kunde>.js` og aliaset i `.firebaserc` i samme commit.
3. Søk etter kundenavnet i `.kanban/1-backlog` og `2-in-progress` — det er
   der kunden fortsatt kan stå som «noe å gjøre». `4-done` er historikk.
4. Så hemmeligheten, så hostingen, så prosjektet.
