// Kundeoppsett: Skiens skolemusikk (beitnes.net/Korpsapp og /Korpsapp-test).
//
// Utrullingen kopierer denne filen til `config.js` i rota. Alt som skiller én
// kunde fra en annen står her — `index.html` er tegn for tegn lik for alle.
//
// API-nøkkelen står IKKE her: repoet er offentlig. Utrullingen bytter ut
// plassholderen i `apiKey` med nøkkelen fra en GitHub-secret; lokalt setter du
// den inn selv i `config.js` (som ikke er sporet). Se CLAUDE.md. Nettleseren
// må uansett få nøkkelen, så tilgangen styres av Firestore-reglene og av
// begrensningene på nøkkelen i Google Cloud — ikke av at den er skjult.
window.KORPSAPP_CONFIG = {
  firebase: {
    apiKey: "__FIREBASE_API_KEY__",
    authDomain: "skiensskolemusikk-b5cbc.firebaseapp.com",
    projectId: "skiensskolemusikk-b5cbc",
    storageBucket: "skiensskolemusikk-b5cbc.firebasestorage.app",
    messagingSenderId: "125188360972",
    appId: "1:125188360972:web:4d7c61a2155353e0b79729"
  },

  // Fast delt konto (e-post/passord) + Google-kontoer begrenset til korpsets
  // Workspace-domene.
  auth: {
    googleLoginEnabled: true,
    sharedLoginEmail: 'korpsapp@skiens-skolemusikk.no',
    googleDomain: 'skiens-skolemusikk.no'
  },

  // Hvilke av de fem modulene som er tilgjengelige. Appen tilpasser seg selv:
  // skjuler faner, hopper aldri inn i en avslått modus, og filtrerer
  // hjelpeteksten.
  modules: {
    concert: true,   // 🎵 Billettfordeling konserter
    formation: true, // 🎺 Korpsoppsett
    room: true,      // 🏨 Romfordeling
    shift: true,     // 🕐 Vaktlister
    team: true       // 👥 Gruppeinndeling
  }
};
