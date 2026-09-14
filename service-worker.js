// service-worker.js
// Bump this on every deploy so old caches get cleared out.
const CACHE_NAME = "vku-survey-cache-v4";

// Everything needed to run the app with zero network connectivity.
const APP_SHELL = [
  "./",
  "./index.html",
  "./style.css",
  "./app.js",
  "./manifest.json",
  "./icons/icon-192.png",
  "./icons/icon-512.png"
];

// Install: pre-cache the app shell.
self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(APP_SHELL))
  );
  self.skipWaiting();
});

// Activate: drop old cache versions.
self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys
          .filter((key) => key !== CACHE_NAME)
          .map((key) => caches.delete(key))
      )
    )
  );
  self.clients.claim();
});

// Fetch: cache-first for app shell assets, falling back to network,
// and falling back to the offline page shell for navigations.
self.addEventListener("fetch", (event) => {
  const { request } = event;

  // Only handle GET requests; let everything else pass through.
  if (request.method !== "GET") return;

  // Only handle same-origin http(s) requests. Ignores requests injected by
  // browser extensions (chrome-extension://, moz-extension://, etc.) which
  // cannot be cached and would otherwise throw an unhandled error.
  if (!request.url.startsWith(self.location.origin)) return;

  event.respondWith(
    caches.match(request).then((cached) => {
      if (cached) return cached;

      return fetch(request)
        .then((response) => {
          // Cache a copy of successfully fetched assets for next time.
          if (response && response.status === 200 && response.type === "basic") {
            const clone = response.clone();
            caches.open(CACHE_NAME).then((cache) => cache.put(request, clone)).catch(() => {});
          }
          return response;
        })
        .catch(() => {
          // Fully offline and not cached: for page navigations, serve the shell.
          if (request.mode === "navigate") {
            return caches.match("./index.html");
          }
        });
    })
  );
});