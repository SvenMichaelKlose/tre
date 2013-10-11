;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defun c-argument-filter (x)
  (?
    (global-literal-function? x)            `(symbol-function ,(c-compiled-symbol .x.))
	(cons? x)                               x
    (character? x)                          (c-compiled-char x)
    (number? x)                             (c-compiled-number x)
    (string? x)                             (c-compiled-string x)
	(funinfo-find *funinfo* x)              x
	x))
