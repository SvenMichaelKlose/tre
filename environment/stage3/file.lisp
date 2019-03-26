; tré – Copyright (c) 2012–2014,2016 Sven Michael Klose <pixel@hugbox.org>

(defun fetch-file (path)
  (with-input-file in path
    (= (stream-track-input-location? in) nil)
    (with-queue q
      (awhile (read-char in)
              (list-string (queue-list q))
        (enqueue q !)))))

(defun fetch-all-lines (path)
  (with-input-file in path
    (= (stream-track-input-location? in) nil)
    (read-all-lines in)))

(defun put-file (path data)
  (with-output-file out path
    (princ data out)))

(defun print-file (path data)
  (with-output-file out path
    (late-print data out)))
