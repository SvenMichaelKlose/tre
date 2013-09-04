;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(defun expanded-lambda-args (x)
  (argument-expand-names (lambda-name x) (lambda-args x)))
