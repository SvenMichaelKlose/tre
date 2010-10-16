;;;;; TRE environment
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defun stringlist-skip-spaces (x)
  (when x
    (if (= #\  x.)
        (stringlist-skip-spaces .x)
        x)))
