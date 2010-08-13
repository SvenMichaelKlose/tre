;;;; TRE tree processor environment
;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de?
;;;;
;;;; Assertions

(defun make-assertion (x &optional (txt "") (args nil))
  `(unless ,x
	 (error (+ "assertion failed: " ,txt) ,@args)))

(defmacro assert (x &optional (txt "") &rest args)
  (when *assert*
	(make-assertion x txt args)))
