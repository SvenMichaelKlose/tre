;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(defvar *memorized-numbers* (make-hash-table :test #'==))

(defun memorized-number (x)
  (cache (href *memorized-numbers* x) x))
