; tré – Copyright (c) 2005–2014 Sven Michael Klose <pixel@copei.de>

(%defvar *development?*       nil)
(%defvar *assert*             t)
(%defvar *print-definitions?* t)

;; Optional environment sections.

(%defvar *tre-has-math*  t) ; Mathematical functions.
(%defvar *tre-has-alien* t) ; C function interface. (C core only)
(%defvar *tre-has-class* t) ; STRUCT CLASS.

;; transpiler

(%defvar *targets*                 '(:cl :js :php :bc :c))
(%defvar *print-notes?*            t)
(%defvar *print-status?*           t)
(%defvar *have-environment-tests*  nil)
(%defvar *have-compiler?*          nil)
(%defvar *have-c-compiler?*        t)
