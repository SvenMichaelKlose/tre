;;;;; Tré transpiler
;;;;; Copyright (c) 2008-2009,2011 Sven Klose <pixel@copei.de>

(defun make-environment-tests ()
  (with (names nil
		 num 0
  		 funs (mapcar
				(fn
				  (setf num (1+ num))
				  (let n ($ 'test- num)
					(setf names (push n names))
				    `(defun ,n ()
				       (document.writeln (+ "Test " (string ,num) ": "
											,(car _) "</br>"))
				       (unless (equal ,(caddr _) ,(cadr _))
				         (document.writeln (+ "Test '"
											  ,(car _)
											  "' failed</br>"))
						 (js-print ,(cadr _) document)
						 (document.writeln "</br>")))))
		    	*tests*))
	`(,@funs
	    (defun environment-tests ()
		  ,@(mapcar #'list (reverse names))))))
