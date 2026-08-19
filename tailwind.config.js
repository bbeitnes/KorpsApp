// ==========================================================================
// TAILWIND-FARGER -> FARGEPALETTEN
// Byggesteg-versjonen av det som før lå som et inline <script> i index.html
// (tailwind.config = {...} for cdn.tailwindcss.com). Samme innhold, flyttet
// hit fordi CLI-en leser konfig fra en fil, ikke fra en global variabel i
// nettleseren.
//
// Her får Tailwind beskjed om å hente fargene sine fra variablene i :root
// i index.html, i stedet for sine egne innebygde farger.
//
// INGEN klassenavn er endret. "text-slate-400" virker akkurat som før - den
// henter bare fargen fra --farge-tekst-svak nå. Det betyr at ETT sted
// (:root i index.html) styrer hele utseendet.
//
// Kun fargetonene appen faktisk bruker er listet opp. Resten av Tailwinds
// farger er urørt, så nye klasser virker som normalt.
//
// ⚠️ MERK: Tailwind kan tone ned en farge med skråstrek, f.eks. "bg-white/50".
// Den skrivemåten virker IKKE på fargene under, fordi de kommer fra
// variabler. Appen bruker den ingen steder i dag. Trenger du gjennomsiktighet,
// bruk en rgba-variabel slik som --farge-skygge-rgb.
// ==========================================================================
module.exports = {
  content: ['./index.html'],
  theme: {
    extend: {
      colors: {
        white: 'var(--farge-flate)',
        slate: {
          50:  'var(--farge-bakgrunn)',
          100: 'var(--farge-bakgrunn-dempet)',
          200: 'var(--farge-kant)',
          300: 'var(--farge-kant-sterk)',
          400: 'var(--farge-tekst-svak)',
          500: 'var(--farge-tekst-dempet)',
          600: 'var(--farge-tekst-dempet-mork)',
          700: 'var(--farge-tekst-sekundar)',
          800: 'var(--farge-tekst)'
        },
        indigo: {
          300: 'var(--farge-primar-svakere)',
          400: 'var(--farge-primar-svak)',
          600: 'var(--farge-primar)',
          800: 'var(--farge-primar-mork)'
        },
        red: {
          100: 'var(--farge-fare-bakgrunn)',
          400: 'var(--farge-fare-lys)',
          500: 'var(--farge-fare)',
          600: 'var(--farge-fare-mork)',
          700: 'var(--farge-fare-morkere)'
        },
        amber: {
          100: 'var(--farge-varsel-bakgrunn)',
          700: 'var(--farge-varsel-tekst)'
        },
        emerald: {
          100: 'var(--farge-ok-bakgrunn-sterk)',
          200: 'var(--farge-ok-kant-svak)',
          600: 'var(--farge-ok-mork)',
          700: 'var(--farge-ok-morkere)',
          800: 'var(--farge-ok-tekst)'
        }
      },

      // ------------------------------------------------------------------
      // HJØRNERADIUS -> DESIGNSYSTEMET
      // Broadsheet-systemet er trykksak: nesten rette hjørner (1-4 px) i
      // stedet for Tailwinds runde 8-16 px. Klassenavnene i appen er
      // uendret - "rounded-lg" virker som før, den er bare skarpere nå.
      // "rounded-full" er med vilje IKKE endret: avatarer, merkelapper og
      // fremdriftslinjer skal fortsatt være helt runde.
      // ------------------------------------------------------------------
      borderRadius: {
        DEFAULT: 'var(--radius-md)',
        sm:      'var(--radius-sm)',
        md:      'var(--radius-md)',
        lg:      'var(--radius-md)',
        xl:      'var(--radius-lg)',
        '2xl':   'var(--radius-lg)',
        '3xl':   'var(--radius-lg)'
      },

      // Skrifttypen hentes fra samme sted som resten (--font-body).
      fontFamily: {
        sans:  ['var(--font-body)'],
        serif: ['var(--font-heading)']
      }
    }
  }
};
