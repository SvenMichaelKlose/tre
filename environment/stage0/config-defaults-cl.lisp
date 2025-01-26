;; Targets to include in environment:
;; :cl     Common Lisp (sbcl)
;; :js     JavaScript/ECMAScript (browser + node.js)
;; :php    PHP
(%defvar *targets* '(:cl :js :php))

;; Developer mode with various effects.
(%defvar *development?* (getenv "TRE_DEVELOPMENT"))

;; Enable run-time type checks,
(%defvar *assert?* (| (getenv "TRE_ASSERT_CL")
                      (getenv "TRE_ASSERT")
                      *development?*))

;; Verbosity
(%defvar *print-status?*      t)
(%defvar *print-definitions?* *development?*)
(%defvar *print-notes?*       *development?*)

; TODO: Remove.
; From the old times where the compiler was runnin on JS target
; for doing EVALs.  Sections should be prepared before calling
; COMPILE and that's it.  Cannot remember what was the issue
; back then.
(%defvar *have-compiler?* nil)
