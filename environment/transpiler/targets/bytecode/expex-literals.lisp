;;;;; tré – Copyright (c) 2009–2012 Sven Michael Klose <pixel@copei.de>

(defun bc-add-literal (x)
  (funinfo-add-literal *expex-funinfo* x))

(defun bc-expex-argument-filter (x)
  (?
	(cons? x) (aprog1
                (transpiler-import-from-expex x)
                (| (funinfo-in-this-or-parent-env? *expex-funinfo* !.)
                   (bc-add-literal !.)))
    (| (character? x) (number? x) (string? x) (keyword? x)) `(%quote ,(bc-add-literal x))
	(expex-funinfo-defined-variable? x) `(symbol-value (%quote ,(bc-add-literal x)))
	x))

(defun bc-expex-filter (x)
  (transpiler-import-from-expex x))
