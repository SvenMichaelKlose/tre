;; Targets to include in environment:
;; :cl     Common Lisp (sbcl)
;; :js     JavaScript/ECMAScript (browser + node.js)
;; :php    PHP
(%defvar *targets* '(:cl :js :php))

;; Enable run-time type checks,
(%defvar *assert?* t)

;; Developer mode with various effects.
(%defvar *development?* nil)

;; Verbosity
(%defvar *print-definitions?* t)
(%defvar *print-notes?*       *development?*)
(%defvar *print-status?*      *development?*)

(%defvar *have-compiler?* nil) ; TODO: Remove.
