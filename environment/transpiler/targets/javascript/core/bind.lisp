;;;;; tré – Copyright (c) 2008–2010,2012–2014 Sven Michael Klose <pixel@copei.de>

(defun %bind (obj fun)
  (assert (function? fun) "BIND requires a function")
  #'(()
      (fun.apply obj arguments)))
