;;;; TRE environment
;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defun pad (seq p)
  (when seq
    (if (< 1 (length seq))
        (cons (car seq) (cons p (pad (cdr seq) p)))
        (list (car seq)))))
