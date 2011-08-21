;;;;; TRE - Copyright (c) 2011 Sven Klose <pixel@copei.de>

(defun read-binary-file (name)
  (let data (make-queue)
    (with-open-file in (open name :direction 'input)
      (while (not (end-of-file in))
             (queue-list data)
        (enqueue data (read-char in))))))
