; tré – Copyright (c) 2010,2012–2013,2015 Sven Michael Klose <pixel@copei.de>

(defun merge (&rest x)
  (alet nil
    (@ (x (apply #'append x) !)
	  (adjoin! x !))))

(defmacro merge! (&rest x)
  `(= ,x. (merge ,@x)))
