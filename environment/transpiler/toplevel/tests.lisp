;;;;; tré – Copyright (c) 2008-2009,2011-2012 Sven Michael Klose <pixel@copei.de>

(defun make-environment-tests ()
  (with (names nil
		 num 0
  		 funs (mapcar
				(fn
				  (= num (1+ num))
				  (let n ($ 'test- num)
					(= names (push n names))
				    `(defun ,n ()
				       (%%%log (+ "Test " (string ,num) ": " ,_. "</br>"))
				       (unless (equal ,.._. ,._.)
				         (%%%log (+ "Test '" ,_. "' failed</br>"))
						 (print ,._.)
						 (%%%log "</br>")))))
		    	*tests*))
	`(,@funs
	    (defun environment-tests ()
		  ,@(mapcar #'list (reverse names))))))
