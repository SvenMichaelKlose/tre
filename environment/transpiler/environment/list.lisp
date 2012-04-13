;;;;; tré - Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

(defun list (&rest x) x)

(defun list-length (x)
  (let len 0
    (while (cons? x)
           len
      (setf x .x)
      (1+! len))))
