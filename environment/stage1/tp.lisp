;;;;; tré – Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(defmacro t? (&rest x)
  `(& ,@(filter ^(eq t ,_) x)))
