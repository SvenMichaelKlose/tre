;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defun make-array (&optional (dimensions 1))
  (cl:make-array dimensions))

(defun =-aref (v x i)
  (cl:setf (cl:aref x i) v))
