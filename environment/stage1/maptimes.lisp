; tré – Copyright (c) 2015 Sven Michael Klose <pixel@hugbox.org>

(defun maptimes (fun num)
  (with-queue q
    (dotimes (i num (queue-list q))
      (enqueue q (funcall fun i)))))
