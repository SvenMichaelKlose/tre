;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defun expex-collect-wanted-variable (x)
  (when (expex-global-variable? .x.)
    (transpiler-add-wanted-variable *transpiler* .x.))
  (list x))

(defun expex-%setq-collect-wanted-global-variable (x)
  (? (atom x)
     (? (expex-global-variable? x)
        (transpiler-add-wanted-variable *transpiler* x)
        x)
	 (transpiler-import-from-expex x)))
