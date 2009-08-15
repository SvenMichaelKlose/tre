(defun fnord ()
  ,@(reverse (symbols-function-exprs *functions-after-math*))
  #'c-transpile
  #'js-transpile)
