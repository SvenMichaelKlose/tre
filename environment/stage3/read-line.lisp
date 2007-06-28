;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (c) 2007 Sven Klose <pixel@copei.de>

(defun read-line (&optional (str *standard-input*))
  "Read line from string."
  (with-default-stream str
    (with-queue q
       (do ((c (read-char str) (read-char str)))
           ((or (= c 10) (= c 13) (end-of-file str))
            (return-from read-line (list-string (queue-list q))))
         (enqueue q c)))))
