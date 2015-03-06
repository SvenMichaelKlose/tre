; tré – Copyright (c) 2006–2008,2012,2015 Sven Michael Klose <pixel@copei.de>

(defmacro in? (obj &rest lst)
  `(| ,@(@ [`(eq ,obj ,_)] lst)))

(defmacro in=? (obj &rest lst)
  `(| ,@(@ [`(== ,obj ,_)] lst)))
