(defvar *memorized-numbers* (make-hash-table :test #'==))

(defun memorized-number (x)
  (cache x (href *memorized-numbers* x)))
