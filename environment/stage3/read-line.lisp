;;;; TRE environment
;;;; Copyright (c) 2007 Sven Klose <pixel@copei.de>

(defun read-line (&optional (str *standard-input*))
  "Read line from string."
  (with-default-stream nstr str
    (with-queue q
       (do ((c (read-char nstr) (read-char nstr)))
           ((or (= c 10) (= c 13) (end-of-file nstr))
            (return-from read-line (list-string (queue-list q))))
         (enqueue q c)))))
