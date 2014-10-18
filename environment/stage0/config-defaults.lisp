;;;; tré – Copyright (c) 2005–2014 Sven Michael Klose <pixel@copei.de>

(? (eq *assert* '*assert*)
   (setq *assert* t))

(defvar *tre-has-math*    t)
(defvar *tre-has-alien*   t)
(defvar *tre-has-class*   t)
(defvar *tre-has-editor*  nil)

(defvar *print-circularities?*      nil)
(defvar *have-compiler?*            nil)
(defvar *have-c-compiler?*          t)
(defvar *show-transpiler-progress?* t)
