;;;;; tré – Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(defun fetch-file (path)
  (with-open-file f (open path :direction 'input)
    (apply #'+ (read-all-lines f))))

(defun fetch-all-lines (path)
  (with-open-file f (open path :direction 'input)
    (read-all-lines f)))

(defun put-file (path data)
  (with-open-file f (open path :direction 'output)
    (princ data f)))
