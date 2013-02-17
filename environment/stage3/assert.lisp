;;;; tré – Copyright (c) 2008 Sven Michael Klose <pixel@copei.de?

(defun make-assertion (x &optional (txt "") (args nil))
  `(unless ,x
	 (error (+ "assertion failed: " ,txt) ,@args)))
