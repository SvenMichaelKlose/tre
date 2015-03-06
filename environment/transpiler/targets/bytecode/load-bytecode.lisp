; tré – Copyright (c) 2012–2015 Sven Michael Klose <pixel@hugbox.org>

(defun bytecode-arrays (x)
  (@ [cons _. (list-array `(,._. nil ,@.._))] x))

(defun load-bytecode (x &key (temporary? nil))
  (adolist x
    (unless (symbol-function !.)
      (= (symbol-function !.) (make-function))
      (unless temporary?
        (push ! *functions*))))
  (adolist ((bytecode-arrays x))
    (= (function-bytecode (symbol-function !.)) .!)))
