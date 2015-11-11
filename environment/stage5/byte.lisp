; tré – Copyright (c) 2015 Sven Michael Klose <pixel@copei.de>

(defun byte (x)
  (? (< x 0)
     (+ 256 x)
     x))
