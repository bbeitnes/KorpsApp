// Kundeoppsett: Musikkforeningen Suoni (Firebase Hosting, prosjekt
// `musikkforeningen-suoni`).
//
// Utrullingen kopierer denne filen til `config.js` i rota. Alt som skiller én
// kunde fra en annen står her — `index.html` er tegn for tegn lik for alle.
//
// Web-API-nøklene under er offentlige av design (de ligger i klienten uansett).
// Tilgangen styres av Firestore-reglene, ikke av nøkkelen.
window.KORPSAPP_CONFIG = {
  firebase: {
    apiKey: "AIzaSyAQCB7OzgdOy6SkcWeJZLvmXnXjxe5l9dk",
    authDomain: "musikkforeningen-suoni.firebaseapp.com",
    projectId: "musikkforeningen-suoni",
    storageBucket: "musikkforeningen-suoni.firebasestorage.app",
    messagingSenderId: "987449247681",
    appId: "1:987449247681:web:9482a02f4e8142bef85140"
  },

  // Ingen Google Workspace-domene å begrense til, så Google-innlogging er
  // skrudd av (knappen skjules) og kun delt e-post/passord brukes.
  //
  // `sharedLoginEmail` er utviklerens private adresse fordi kunden ikke hadde
  // en rolleadresse klar ved oppsettet 2026-08-16. Det skal byttes — se kortet
  // `delt-innloggingskonto-boer-eies-av-kunden-ikke-utvikleren`.
  auth: {
    googleLoginEnabled: false,
    sharedLoginEmail: 'bbeitnes@gmail.com',
    googleDomain: ''
  },

  // Bare Korpsoppsett.
  modules: {
    concert: false,  // 🎵 Billettfordeling konserter
    formation: true, // 🎺 Korpsoppsett
    room: false,     // 🏨 Romfordeling
    shift: false,    // 🕐 Vaktlister
    team: false      // 👥 Gruppeinndeling
  }
};
