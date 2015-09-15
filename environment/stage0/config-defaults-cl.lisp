; tré – Copyright (c) 2005–2015 Sven Michael Klose <pixel@copei.de>

(%defvar *development?*       t)
(%defvar *assert*             t)
(%defvar *print-definitions?* t)

;; Optional environment sections.

(%defvar *tre-has-math*  t) ; Mathematical functions.
(%defvar *tre-has-alien* t) ; C function interface. (C core only)
(%defvar *tre-has-class* t) ; STRUCT CLASS.

;; Transpiler

;;; Targets to include in environment:
;;; :cl     Common Lisp (sbcl)
;;; :js     JavaScript/ECMAScript (browser + node.js)
;;; :php    PHP
;;; :bc     bytecode (defunct)
;;; :c      C (defunct)
(%defvar *targets*                 '(:cl :js :php))
(%defvar *defunct-targets*         '(:c :bc))

(%defvar *print-notes?*            t)
(%defvar *print-status?*           t)
(%defvar *have-environment-tests*  nil)
(%defvar *have-compiler?*          nil)
(%defvar *have-c-compiler?*        t)