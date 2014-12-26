; tré – Copyright (c) 2013–2014 Sven Michael Klose <pixel@copei.de>

(define-tree-filter cpr-count-0 (x h)
  t (? (atom x)
       x
       (progn
         (cache t (href h (cpr x)))
         (cpr-count-0 x. h)
         (cpr-count-0 .x h)
         x)))

(defun cpr-count (x name)
  (? (cpr-count?)
     (alet (make-hash-table :test #'eq)
       (cpr-count-0 x !)
       (format t "~A debugger positions after ~A~%" (length (hashkeys !)) name)))
  x)
