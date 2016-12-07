; tré – Copyright (c) 2008,2016 Sven Michael Klose <pixel@copei.de?

(defun make-assertion (x &optional (txt "") (args nil))
  (& *assert?*
     `(unless ,x
	    (error (+ "Assertion failed: " ,txt) ,@args))))
