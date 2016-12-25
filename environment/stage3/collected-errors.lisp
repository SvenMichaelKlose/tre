(defvar *collected-errors* nil)

(defun collect-error (format-string &rest args)
  (push (apply #'format nil format-string args) *collected-errors*))

(defun issue-collected-errors ()
  (when *collected-errors*
	(alet (apply #'+ (@ [+ _ "~%"] *collected-errors*))
	  (= *collected-errors* nil)
	  (error (format nil !)))))
