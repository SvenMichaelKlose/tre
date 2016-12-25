(defun make-assertion (x &optional (txt "") (args nil))
  (& *assert?*
     `(unless ,x
	    (error (+ "Assertion failed: " ,txt) ,@args))))
