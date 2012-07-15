;;;;; tré – Copyright (c) 2009–2012 Sven Michael Klose <pixel@copei.de>

(defun bc-expex-argument-filter (x)
  (?
	(cons? x) (transpiler-import-from-expex x)
    (| (character? x) (number? x) (string? x)) `(%quote ,x)
	(funinfo-in-this-or-parent-env? *expex-funinfo* x) x
	(expex-funinfo-defined-variable? x) `(treatom_get_value (%quote ,x))
	x))

(defun bc-expex-filter (x)
  (transpiler-import-from-expex x))
