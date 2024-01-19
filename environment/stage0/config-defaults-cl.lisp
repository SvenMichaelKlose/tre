(%defvar *development?*       t)
(%defvar *assert?*            t)
(%defvar *print-definitions?* t)

;; Optional environment sections.

(%defvar *tre-has-math*  t) ; Mathematical functions.
(%defvar *tre-has-class* t) ; STRUCT CLASS.

(%defvar *modules-path* "/usr/local/lib/tre/modules/")

;; Transpiler

;;; Targets to include in environment:
;;; :cl     Common Lisp (sbcl)
;;; :js     JavaScript/ECMAScript (browser + node.js)
;;; :php    PHP
(%defvar *targets*                 '(:cl :js :php))

(%defvar *print-notes?*            t)
(%defvar *print-status?*           t)
(%defvar *have-compiler?*          nil)
