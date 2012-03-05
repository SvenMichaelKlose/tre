;;;;; tré - Copyright (c) 2008-2009,2011-2012 Sven Michael Klose <pixel@copei.de>

(defun make-environment-tests ()
  (with (names nil
		 num 0
  		 funs (mapcar
				(fn
				  (setf num (1+ num))
				  (let n ($ 'test- num)
					(setf names (push n names))
				    `(defun ,n ()
				       (%%%log (+ "Test " (string ,num) ": " ,(car _) "</br>"))
				       (unless (equal ,(caddr _) ,(cadr _))
				         (%%%log (+ "Test '" ,(car _) "' failed</br>"))
						 (print ,(cadr _) document)
						 (%%%log "</br>")))))
		    	*tests*))
	`(,@funs
	    (defun environment-tests ()
		  ,@(mapcar #'list (reverse names))))))
