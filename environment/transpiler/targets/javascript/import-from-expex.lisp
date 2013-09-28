;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defun js-argument-filter (x)
  (? (global-literal-function? x)
     `(symbol-function (%quote ,.x.))
     x))
