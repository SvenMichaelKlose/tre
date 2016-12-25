(defmacro in? (obj &rest lst)
  `(| ,@(@ [`(eq ,obj ,_)] lst)))

(defmacro in=? (obj &rest lst)
  `(| ,@(@ [`(== ,obj ,_)] lst)))

(defmacro in-chars? (obj &rest lst)
  `(| ,@(@ [`(character== ,obj ,_)] lst)))
