---
---

self.addEventListener('install', (e) => {
  const CACHE_NAME = '{{site.github.project_title}}-{{ site.data.config.cache_version }}'

  caches.keys()
    .then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if(cacheName != CACHE_NAME) {
            return caches.delete(cacheName)
          }
        })
      )
    })

  e.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        return cache.addAll([
          '{{ site.baseurl }}/',
          '{{ site.baseurl }}/?homescreen=1',
          '{{ "/index.html" | absolute_url }}',
          '{{ "/index.html" | absolute_url }}?homescreen=1',
          '{{ "/css/main.css" | absolute_url }}',
          '{{ "/css/syntax.css" | absolute_url }}',
          '{{ "/images/typo.png" | absolute_url }}',
          '{{ "/images/logo.png" | absolute_url }}',
          '{{ "/js/app.js" | absolute_url }}',
          '{{ "/js/jquery.min.js" | absolute_url }}',
          '{{ "/js/bootstrap.min.js" | absolute_url }}',
          '{{ "/manifest.json" | absolute_url }}',
          '{{ "/fonts/glyphs/winjs-symbols.ttf" | absolute_url }}',
          '{{ "/fonts/selawk.ttf" | absolute_url }}',
          '{{ "/fonts/selawkl.ttf" | absolute_url }}',
          '{{ "/fonts/selawksl.ttf" | absolute_url }}'
        ])
      })
  )
})

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then((response) => {
        return response || fetch(event.request)
      })
  )
})
