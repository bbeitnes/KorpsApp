// Kundeoppsett: Skiens skolemusikk (beitnes.net/Korpsapp og /Korpsapp-test).
//
// Utrullingen kopierer denne filen til `config.js` i rota. Alt som skiller én
// kunde fra en annen står her — `index.html` er tegn for tegn lik for alle.
//
// Web-API-nøklene under er offentlige av design (de ligger i klienten uansett).
// Tilgangen styres av Firestore-reglene, ikke av nøkkelen.
window.KORPSAPP_CONFIG = {
  firebase: {
    apiKey: "AIzaSyDQA3CmYameS10cjuiqAaxAk4UpB8Lg1GI",
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
