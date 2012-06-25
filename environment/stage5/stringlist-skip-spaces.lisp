;;;;; tré – Copyright (c) 2010,2012 Sven Michael Klose <pixel@copei.de>

(defun stringlist-skip-spaces (x)
  (when x
    (? (== #\  x.)
       (stringlist-skip-spaces .x)
       x)))
