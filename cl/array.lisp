;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(in-package :tre-core)

(defun %make-array (dimensions) (make-array dimensions))
(defun =-aref (v x i) (setf (aref x i) v))
