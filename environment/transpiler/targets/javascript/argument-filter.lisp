;;;;; tré – Copyright (c) 2009–2014 Sven Michael Klose <pixel@copei.de>

(defun js-argument-filter (x)
  (? (global-literal-function? x)
     .x.
     x))
