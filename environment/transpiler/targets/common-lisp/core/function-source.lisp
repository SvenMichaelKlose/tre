;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(in-package :tre-core)

(defvar *function-atom-sources* (make-hash-table :test #'eq))

(defun function-source (x)
  (or (functionp x)
      (error "Not a function."))
  (gethash x *function-atom-sources*))

(defun =-function-source (v x) (setf (gethash x *function-atom-sources*) v))
