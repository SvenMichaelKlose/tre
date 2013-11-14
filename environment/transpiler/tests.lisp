;;;;; tré – Copyright (c) 2008–2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(defun make-environment-tests ()
  (with (names  nil
		 num    0
  		 funs   (mapcar [(++! num)
				         (let n ($ 'test- num)
					       (push n names)
				           `(defun ,n ()
				              (print ,(+ "Test " (string num) ", " _.))
                              (with (result    ,.._.
                                     expected  ',._.)
				                (unless (equal result expected)
				                  (print " FAILED")
				                  (print " Expected:")
                                  (print expected)
				                  (print " Result:")
						          (print result)))
                              (print "</br>")))]
                        *tests*))
	`(,@funs
      (defun environment-tests ()
	    ,@(mapcar #'list (reverse names))))))
