;;;;; tré – Copyright (c) 2012–2013 Sven Michael Klose <pixel@copei.de>

(defun load-bytecode-function (x)
  (= (symbol-function x.) (list-array `(,.x. ,(function-body (symbol-function x.)) ,@..x))))

(defun load-bytecode-functions (x)
  (dolist (i x)
    (load-bytecode-function i)))
