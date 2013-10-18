;;;;; tré – Copyright (c) 2011–2013 Sven Michael Klose <pixel@copei.de>

(defun read-binary-file (name)
  (let data (make-queue)
    (with-input-file in name
      (while (not (end-of-file? in))
             (queue-list data)
        (enqueue data (integer (read-char in)))))))
