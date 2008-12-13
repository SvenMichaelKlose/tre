;;;; TRE processor environment
;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defvar *dl-libs* (make-hash-table :test #'string=))

(defun alien-import-lib (name)
  (or (href name *dl-libs*)
	  (setf (href name *dl-libs*)
	        (or (alien-dlopen (string-concat name))))))
