;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defun expex-set-global-variable-value (x)
  (list
    (alet (%setq-place x)
      (? (expex-global-variable? !)
	     `(%setq-atom-value (%quote ,!) ,(%setq-value x))
	     x))))
