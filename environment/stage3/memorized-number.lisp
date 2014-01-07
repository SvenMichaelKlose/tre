;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(defvar *memorized-numbers* (make-hash-table :test #'==))

(defun memorized-number (x)
  (cache x (href *memorized-numbers* x)))
