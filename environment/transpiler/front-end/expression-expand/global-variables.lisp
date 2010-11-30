;;;;; TRE transpiler
;;;;; Copyright (c) 2009-2010 Sven Klose <pixel@copei.de>

(defun expex-set-global-variable-value (x)
  (list
    (let place (%setq-place x)
      (if (expex-global-variable? place)
	      `(%setq-atom ,place ,(%setq-value x))
	      x))))

(defun expex-collect-wanted-variable (x)
  (when (expex-global-variable? (second x))
    (transpiler-add-wanted-variable *current-transpiler* (second x)))
  (list x))

(defun expex-%setq-collect-wanted-global-variable (x)
  (if
    (atom x)
      (if (expex-global-variable? x)
	      (transpiler-add-wanted-variable *current-transpiler* x)
	      x)
	(transpiler-import-from-expex x)))
