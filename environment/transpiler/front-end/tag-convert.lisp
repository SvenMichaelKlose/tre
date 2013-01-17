;;;;; tré – Copyright (c) 2006–2013 Sven Michael Klose <pixel@copei.de>

(defun distinguish-var-from-tag (x)
  (? (& (atom x)
        (not (number? x)))
     `(identity ,x)
     x))

(define-filter distinguish-vars-from-tags #'distinguish-var-from-tag)
