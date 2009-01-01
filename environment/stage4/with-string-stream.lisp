;;;; TRE environment
;;;; Copyright (C) 2005-2008 Sven Klose <pixel@copei.de>

(defmacro with-string-stream (x &rest body)
  `(let ,x (make-string-stream)
	 (progn
	   ,@body)
	 (get-stream-string ,x)))
