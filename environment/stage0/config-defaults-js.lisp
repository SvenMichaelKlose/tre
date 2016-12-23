; tré – Copyright (c) 2005–2016 Sven Michael Klose <pixel@copei.de>

(%defvar *development?*       nil)
(%defvar *assert?*            nil)
(%defvar *print-definitions?* t)

;; Optional environment sections.

(%defvar *tre-has-math*  t)   ; Mathematical functions.
(%defvar *tre-has-alien* nil) ; C function interface. (C core only)
(%defvar *tre-has-class* t)   ; Have CLASS.

;; Transpiler

;;; Targets to include in environment:
;;; :cl     Common Lisp (sbcl)
;;; :js     JavaScript/ECMAScript (browser + node.js)
;;; :php    PHP
;;; :bc     bytecode (defunct)
;;; :c      C (defunct)
(%defvar *targets*                 '(:js :php))
(%defvar *defunct-targets*         '(:c :bc))

(%defvar *print-notes?*            t)
(%defvar *print-status?*           t)
(%defvar *have-environment-tests*  nil)
(%defvar *have-compiler?*          nil)
(%defvar *have-c-compiler?*        nil)
