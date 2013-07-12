;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(defun bc-expex-argument-filter (x)
  (?
	(cons? x)                  (transpiler-import-from-expex x)
	(expex-global-variable? x) `(%symbol-value (%quote ,x))
	x))
