(defun %bind (obj fun)
  (assert (function? fun) "BIND requires a function")
  #'(()
      (fun.apply obj arguments)))
