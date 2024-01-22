;; Targets to include in environment:
;; :cl     Common Lisp (sbcl)
;; :js     JavaScript/ECMAScript (browser + node.js)
;; :php    PHP
(%defvar *targets* '(:cl :js :php))

;; Enable run-time type checks,
(%defvar *assert?* (| (getenv "TRE_ASSERT_CL")
                      (getenv "TRE_ASSERT")))

;; Developer mode with various effects.
(%defvar *development?* (getenv "TRE_DEVELOPMENT"))

;; Verbosity
(%defvar *print-definitions?* t)
(%defvar *print-notes?*       *development?*)
(%defvar *print-status?*      *development?*)

(%defvar *have-compiler?* nil) ; TODO: Remove.
