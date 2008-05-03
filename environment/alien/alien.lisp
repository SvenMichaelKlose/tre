;;;; TRE processor environment
;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defvar *dl-libs* (make-hash-table :test #'string=))

(defun alien-import-lib (name)
  (or (gethash name *dl-libs*)
	  (setf (gethash name *dl-libs*)
	        (or (alien-dlopen (string-concat name))))))
