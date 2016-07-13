; tré – Copyright (c) 2011–2013,2016 Sven Michael Klose <pixel@copei.de>

(defun window-url ()
  (unescape window.location.href))

(defun window-directory-path ()
  (+ "/" (path-parent (url-path (window-url)))))

(defun window-directory-url ()
  (path-append (url-without-path (window-url))
               (window-directory-path)))
