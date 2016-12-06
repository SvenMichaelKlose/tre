; tré – Copyright (c) 2013–2014,2016 Sven Michael Klose <pixel@copei.de>

(define-tree-filter cpr-count-0 (x h)
  t
    (? (atom x)
       x
       {(cache t (href h (cpr x)))
        (cpr-count-0 x. h)
        (cpr-count-0 .x h)
        x}))

(defun cpr-count (x name)
  (alet (make-hash-table :test #'eq)
    (cpr-count-0 x !)
    (format t "~A debugger positions after ~A~%" (length (hashkeys !)) name)))
