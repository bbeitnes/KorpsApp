// Kundeoppsett: Kvinner i Kor (Firebase Hosting, prosjekt `kvinner-i-kor`).
//
// Utrullingen kopierer denne filen til `config.js` i rota. Alt som skiller én
// kunde fra en annen står her — `index.html` er tegn for tegn lik for alle.
//
// Web-API-nøklene under er offentlige av design (de ligger i klienten uansett).
// Tilgangen styres av Firestore-reglene, ikke av nøkkelen.
window.KORPSAPP_CONFIG = {
  firebase: {
    apiKey: "AIzaSyAFG7bBdm9FtMPtAIQaQ_d5ks1ka7ldcsQ",
    authDomain: "kvinner-i-kor.firebaseapp.com",
    projectId: "kvinner-i-kor",
    storageBucket: "kvinner-i-kor.firebasestorage.app",
    messagingSenderId: "722343508936",
    appId: "1:722343508936:web:14294915b3a37c97461efd"
  },

  // Denne installasjonen har ingen Google Workspace-domene å begrense til, så
  // Google-innlogging er skrudd av (knappen skjules) og kun delt
  // e-post/passord brukes.
  auth: {
    googleLoginEnabled: false,
    sharedLoginEmail: 'bbeitnes@gmail.com',
    googleDomain: ''
  },

  // Bare Romfordeling. Korpsoppsett er skrevet for korps-oppstilling og
  // slagverk og er ikke relevant her.
  modules: {
    concert: false,   // 🎵 Billettfordeling konserter
    formation: false, // 🎺 Korpsoppsett
    room: true,       // 🏨 Romfordeling
    shift: false,     // 🕐 Vaktlister
    team: false       // 👥 Gruppeinndeling
  }
};
