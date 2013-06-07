;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(define-tree-filter cpr-count-0 (x h)
  t (? (atom x)
       x
       (progn
         (cache t (href h (cpr x)))
         (cpr-count-0 x. h)
         (cpr-count-0 .x h)
         x)))

(defun cpr-count (x name)
  (? (transpiler-cpr-count? *transpiler*)
     (alet (make-hash-table :test #'eq)
       (cpr-count-0 x !)
       (format t "~A debugger positions after ~A~%" (length (hashkeys !)) name)))
  x)
