;;;;; tré – Copyright (c) 2012–2013 Sven Michael Klose <pixel@copei.de>

(defun bytecode-arrays (x)
  (filter [cons _. (list-array `(,._. nil ,@.._))] x))

(defun load-bytecode (x &key (temporary? nil))
  (adolist x
    (unless (symbol-function !.)
      (= (symbol-function !.) (make-function))
      (unless temporary?
        (push !. *defined-functions*))))
  (adolist ((bytecode-arrays x))
    (= (function-bytecode (symbol-function !.)) .!)))
