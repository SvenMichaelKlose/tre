; tré – Copyright (c) 2012,2014–2015 Sven Michael Klose <pixel@copei.de>

; XXX Make this a function.
(defmacro t? (&rest x)
  `(& ,@(@ [`(eq t ,_)] x)))
