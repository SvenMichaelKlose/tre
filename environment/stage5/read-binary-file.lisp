;;;;; tré – Copyright (c) 2011–2012 Sven Michael Klose <pixel@copei.de>

(defun read-binary-file (name)
  (let data (make-queue)
    (with-open-file in (open name :direction 'input)
      (while (not (end-of-file in))
             (queue-list data)
        (enqueue data (integer (read-char in)))))))
