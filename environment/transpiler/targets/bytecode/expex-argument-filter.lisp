;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(defun bc-expex-argument-filter (x)
  (? (& (atom x)
	    (funinfo-global-variable? *funinfo* x))
     `(symbol-value (%quote ,x))
	 x))
