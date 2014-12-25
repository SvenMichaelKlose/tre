; tré – Copyright (c) 2005–2014 Sven Michael Klose <pixel@copei.de>

(? (eq *assert* '*assert*)
   (setq *assert* t))
(? (eq *targets* '*targets*)
   (setq *targets* '(:c :cl :js :php)))

(%defvar *tre-has-math*    t)
(%defvar *tre-has-alien*   t)
(%defvar *tre-has-class*   t)

(%defvar *print-definitions?*         t)
(%defvar *print-notes?*               t)
(%defvar *print-status?*              t)
(%defvar *have-environment-tests*     nil)
(%defvar *development?*               t)
(%defvar *have-compiler?*             nil)
(%defvar *have-c-compiler?*           t)
