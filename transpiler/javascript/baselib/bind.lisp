;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

;; Bind function to an object.
;; See also macro BIND in 'expand.lisp'.
(defun %bind (obj fun)
  (assert (functionp fun) "BIND requires a function")
  #'(()
      (fun.apply obj arguments)))
