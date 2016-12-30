(defmacro in? (obj &rest lst)
  `(| ,@(@ [`(eql ,obj ,_)] lst)))
