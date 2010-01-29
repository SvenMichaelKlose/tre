;;;;; TRE transpiler
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun expex-funinfo-defined-variable? (x)
  (or (funinfo-in-env? *expex-funinfo* x)
      (expex-global-variable? x)))
