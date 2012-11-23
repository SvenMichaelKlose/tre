;;;;; tré – Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(defun read-binary-file (path)
  (with-open-file in (open path :direction 'input)
    (with-queue q
      (while (not (end-of-file in))
             (queue-list q)
        (enqueue q (integer (read-char in)))))))
