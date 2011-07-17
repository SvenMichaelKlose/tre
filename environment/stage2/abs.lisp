;;;; TRE environment
;;;; Copyright (c) 2005,2008,2011 Sven Klose <pixel@copei.de>

(functional abs)

(defun abs (x)
  (? (< x 0)
     (- x)
     x))
