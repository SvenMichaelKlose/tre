;:::: tré - Copyright (c) 2011 Sven Klose <pixel@copei.de>

(defun min (&rest x)
  (when x
    (? .x
       (? (< x. .x.)
          (apply #'min x. ..x)
          (apply #'min .x))
       x.)))
