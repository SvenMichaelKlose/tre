; tré – Copyright (c) 2006–2008,2012,2015–2016 Sven Michael Klose <pixel@hugbox.org>

(defmacro in? (obj &rest lst)
  `(| ,@(@ [`(eq ,obj ,_)] lst)))

(defmacro in=? (obj &rest lst)
  `(| ,@(@ [`(== ,obj ,_)] lst)))

(defmacro in-chars? (obj &rest lst)
  `(| ,@(@ [`(character== ,obj ,_)] lst)))
