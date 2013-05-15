;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defun expex-set-global-variable-value (x)
  (list
    (let place (%setq-place x)
      (? (expex-global-variable? place)
	     `(%setq-atom-value (%quote ,place) ,(%setq-value x))
	     x))))
