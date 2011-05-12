;;;;; TRE environment
;;;;; Copyright (c) 2011 Sven Klose <pixel@copei.de>

(defun array-list (x)
  (let result (make-queue)
    (dotimes (i (length x) (queue-list result))
      (enqueue result (aref x i)))))
