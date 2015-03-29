; tré – Copyright (c) 2006–2013,2015 Sven Michael Klose <pixel@copei.de>

(defun wrap-atom (x)
  (? (& (atom x)
        (not (number? x)))
     `(identity ,x)
     x))

(define-filter wrap-atoms #'wrap-atom)
