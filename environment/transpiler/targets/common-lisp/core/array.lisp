;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defun make-array (dimensions)  (cl:make-array dimensions))
(defun =-aref (v x i)           (cl:setf (cl:aref x i) v))
