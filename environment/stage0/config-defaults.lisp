;;;; tré – Copyright (c) 2005–2014 Sven Michael Klose <pixel@copei.de>

(? (eq *assert* '*assert*)
   (setq *assert* t))
(? (eq *targets* '*targets*)
   (setq *targets* '(c js php)))

(%defvar *tre-has-math*    t)
(%defvar *tre-has-alien*   t)
(%defvar *tre-has-class*   t)

(%defvar *show-definitions?*          t)
(%defvar *have-environment-tests*     nil)
(%defvar *development?*               t)
(%defvar *print-circularities?*       nil)
(%defvar *have-compiler?*             nil)
(%defvar *have-c-compiler?*           t)
(%defvar *show-transpiler-progress?*  t)
