;;;; TRE tree processor environment
;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de?
;;;;
;;;; Assertions

(defvar *assert* t)

(defmacro assert (x &optional (txt nil) &rest args)
  (when *assert*
    `(unless ,x
	   (error (+ "assertion failed: " ,txt) ,@args))))
