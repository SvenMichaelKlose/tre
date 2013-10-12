;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defun expex-set-global-variable-value (x)
  (list
    (alet (%=-place x)
      (? (funinfo-global-variable? *funinfo* !)
	     `(=-symbol-value ,(%=-value x) (%quote ,!))
	     x))))
