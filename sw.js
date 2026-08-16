const CACHE = 'fordeling-v1';
const ASSETS = [
  './index.html',
  './config.js',
  './manifest.json',
  './icon-192.png',
  './icon-512.png',
  'https://cdn.tailwindcss.com'
];

self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE).then(c => c.addAll(ASSETS)).then(() => self.skipWaiting())
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
