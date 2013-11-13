;;;;; tré – Copyright (c) 2008–2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(defun make-environment-tests ()
  (with (names  nil
		 num    0
  		 funs   (mapcar [(++! num)
				         (let n ($ 'test- num)
					       (push n names)
				           `(defun ,n ()
				              (print (+ "Test " ,num ", " ,_.))
				              (unless (equal ,.._. ,._.)
				                (print " FAILED")
						        (print ',._.))
                              (print "</br>")))]
                        *tests*))
	`(,@funs
      (defun environment-tests ()
	    ,@(mapcar #'list (reverse names))))))
