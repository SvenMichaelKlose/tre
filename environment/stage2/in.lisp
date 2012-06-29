;;;;; tré – Copyright (c) 2006–2008,2012 Sven Michael Klose <pixel@copei.de>

(defmacro in? (obj &rest lst)
  `(| ,@(filter #'((x) `(eq ,obj ,x)) lst)))

(defmacro in=? (obj &rest lst)
  `(| ,@(filter #'((x) `(== ,obj ,x)) lst)))
