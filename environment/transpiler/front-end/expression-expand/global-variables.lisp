;;;;; tré – Copyright (c) 2009–2012 Sven Michael Klose <pixel@copei.de>

(defun expex-set-global-variable-value (x)
  (list
    (let place (%setq-place x)
      (? (expex-global-variable? place)
	     `(%setq-atom-value (%quote ,place) ,(%setq-value x))
	     x))))

(defun expex-collect-wanted-variable (x)
  (when (expex-global-variable? (cadr x))
    (transpiler-add-wanted-variable *current-transpiler* (cadr x)))
  (list x))

(defun expex-%setq-collect-wanted-global-variable (x)
  (? (atom x)
     (? (expex-global-variable? x)
	     (transpiler-add-wanted-variable *current-transpiler* x)
	     x)
	 (transpiler-import-from-expex x)))
