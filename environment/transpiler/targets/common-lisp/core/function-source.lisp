;;;;; tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>

(defvar *function-atom-sources* (cl:make-hash-table :test #'eq))

(defun function-source (x)
  (| (cl:functionp x)
     (cl:error "Not a function."))
  (cl:gethash x *function-atom-sources*))

(defun =-function-source (v x)
  (cl:setf (cl:gethash x *function-atom-sources*) v))
