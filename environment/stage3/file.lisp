;;;;; tré – Copyright (c) 2012–2013 Sven Michael Klose <pixel@copei.de>

(defun read-file (path)
  (with-input-file f path
    (read-all f)))

(defun fetch-file (path)
  (with-input-file f path
    (apply #'+ (read-all-lines f))))

(defun fetch-all-lines (path)
  (with-input-file f path
    (read-all-lines f)))

(defun put-file (path data)
  (with-output-file f path
    (princ data f)))

(defun print-file (path data)
  (with-output-file f path
    (late-print data f)))
