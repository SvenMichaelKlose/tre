(defun fnord ()
  ,@(reverse (symbols-function-exprs *universe-functions*)))
