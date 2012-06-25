;;;;; tré – Copyright (c) 2006–2008 Sven Michael Klose <pixel@copei.de>

(defmacro in? (obj &rest lst)
  `(or ,@(mapcar #'((x) `(eq ,obj ,x)) lst)))

(defmacro in=? (obj &rest lst)
  `(or ,@(mapcar #'((x) `(== ,obj ,x)) lst)))
