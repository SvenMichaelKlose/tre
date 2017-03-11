(%defvar *development?*       nil)
(%defvar *assert?*            nil)
(%defvar *print-definitions?* t)

;; Optional environment sections.

(%defvar *tre-has-math*  t)   ; Mathematical functions.
(%defvar *tre-has-class* t)   ; Have CLASS.

;; Transpiler

;;; Targets to include in environment:
;;; :cl     Common Lisp (sbcl)
;;; :js     JavaScript/ECMAScript (browser + node.js)
;;; :php    PHP
(%defvar *targets*                 '(:js :php))

(%defvar *print-notes?*            t)
(%defvar *print-status?*           t)
(%defvar *have-environment-tests*  nil)
(%defvar *have-compiler?*          nil)
