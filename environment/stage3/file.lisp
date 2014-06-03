;;;;; tré – Copyright (c) 2012–2014 Sven Michael Klose <pixel@copei.de>

(defun fetch-file (path)
  (with-input-file in path
    (with-queue q
      (while (not (end-of-file? in))
             (list-string (queue-list q))
        (enqueue q (read-char in))))))

(defun fetch-all-lines (path)
  (with-input-file in path
    (read-all-lines in)))

(defun put-file (path data)
  (with-output-file out path
    (princ data out)))

(defun print-file (path data)
  (with-output-file out path
    (late-print data out)))
