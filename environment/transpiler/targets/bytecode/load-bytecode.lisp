;;;;; tré – Copyright (c) 2012–2013 Sven Michael Klose <pixel@copei.de>

(defun load-bytecode (x)
  (dolist (i (filter [cons _. (list-array `(,._. ,(function-body (symbol-function _.)) ,@.._))]
                     x))
    (= (symbol-function i.) .i)))
