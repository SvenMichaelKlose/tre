;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

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
											,(first _) "</br>"))
				       (unless (equal ,(third _) ,(second _))
				         (document.writeln (+ "Test '"
											  ,(first _)
											  "' failed</br>"))
						 (js-print ,(second _))
						 (document.writeln "</br>")))))
		    	*tests*))
	`(,@funs
	    (defun environment-tests ()
		  ,@(mapcar #'list (reverse names))))))
