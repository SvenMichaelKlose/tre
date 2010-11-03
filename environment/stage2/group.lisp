;;;;; TRE environment
;;;;; Copyright (c) 2007 Sven Klose <pixel@copei.de>

(defun group (l size)
  (let result (make-queue)
    (while l nil
      (enqueue result (subseq l 0 size))
      (setf l (subseq l size)))
    (queue-list result)))
