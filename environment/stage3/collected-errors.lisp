;;;; nix operating system project
;;;; tree processor environment
;;;; Copyright (C) 2008 Sven Klose <pixel@copei.de>

(defvar *collected-errors* nil)

(defun collect-error (format-string &rest args)
  "Collect error message. See als ISSUE-COLLECTED-ERRORS."
  (push (apply #'format nil format-string args) *collected-errors*))

(defun issue-collected-errors ()
  "Issue error messages collected with COLLECT-ERROR."
  (when *collected-errors*
	(with (errors (apply #'string-concat (mapcar #'((x)
						       						  (string-concat x "~%"))
												 *collected-errors*)))
	  (setf *collected-errors* nil)
	  (%error (format nil errors)))))
