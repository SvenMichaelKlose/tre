(fn window-url ()
  (unescape window.location.href))

(fn window-directory-path ()
  (+ "/" (path-parent (url-path (window-url)))))

(fn window-directory-url ()
  (path-append (url-without-path (window-url))
               (window-directory-path)))
