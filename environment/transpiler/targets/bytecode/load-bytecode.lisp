;;;;; tré – Copyright (c) 2012–2013 Sven Michael Klose <pixel@copei.de>

(defun load-bytecode (x)
  (adolist ((filter [cons _. (list-array `(,._. ,(function-body (symbol-function _.)) ,@.._))]
                    x))
    (= (function-bytecode (symbol-function !.)) .!)))
