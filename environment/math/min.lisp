;:::: tré – Copyright (c) 2011,2013 Sven Michael Klose <pixel@copei.de>

(defun min (&rest x)
  (& x
     (? .x
        (? (< x. .x.)
           (apply #'min x. ..x)
           (apply #'min .x))
        x.)))
