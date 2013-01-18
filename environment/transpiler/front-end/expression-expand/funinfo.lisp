;;;;; tré – Copyright (c) 2009,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun expex-funinfo-defined-variable? (x)
  (| (funinfo-var? *expex-funinfo* x)
     (expex-global-variable? x)))
