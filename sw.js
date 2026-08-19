const CACHE = 'fordeling-v2';
const ASSETS = [
  './index.html',
  './config.js',
  './manifest.json',
  './icon-192.png',
  './icon-512.png',
  './tailwind.css',
  './fonts/source-serif-4-normal.woff2',
  './fonts/source-serif-4-italic-400.woff2'
];

self.addEventListener('install', e => {
  // c.addAll er alt-eller-ingenting: feiler ETT kall (f.eks. brukeren er
  // offline akkurat idet appen installeres første gang), caches INGENTING —
  // heller ikke index.html. Promise.allSettled cacher det som lar seg cache
  // og lar resten være; installasjonen fullfører uansett.
  e.waitUntil(
    caches.open(CACHE)
      .then(c => Promise.allSettled(ASSETS.map(a => c.add(a))))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', e => {
  // Network-first for index.html OG config.js, så brukeren alltid får
  // oppdateringer når hen er på nett; cache-first for resten (ikoner, Tailwind)
  // for rask lasting og offline-bruk.
  //
  // config.js MÅ være network-first: den bærer kundeoppsettet, og cache-first
  // uten versjonering ville låst en kunde til det oppsettet hen lastet første
  // gang — en påslått modul eller ny delt e-post ville aldri nådd fram.
  const url = e.request.url;
  const isMainPage = url.endsWith('index.html') || url.endsWith('/') || url.endsWith('config.js');
  if (isMainPage) {
    e.respondWith(
      fetch(e.request)
        .then(res => { caches.open(CACHE).then(c => c.put(e.request, res.clone())); return res; })
        .catch(() => caches.match(e.request))
    );
  } else {
    e.respondWith(
      caches.match(e.request).then(cached => cached || fetch(e.request)
        .then(res => { caches.open(CACHE).then(c => c.put(e.request, res.clone())); return res; })
      )
    );
  }
});
