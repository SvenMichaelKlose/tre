;;;;; tré – Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(defun make-upcase-symbol (x)
  (make-symbol (string-upcase x)))

(defun make-upcase-symbols (x)
  (filter #'make-upcase-symbol x))
