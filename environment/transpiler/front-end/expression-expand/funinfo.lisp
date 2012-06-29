;;;;; tré – Copyright (c) 2009,2012 Sven Michael Klose <pixel@copei.de>

(defun expex-funinfo-defined-variable? (x)
  (| (funinfo-in-env? *expex-funinfo* x)
     (expex-global-variable? x)))
