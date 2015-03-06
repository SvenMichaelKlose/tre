; tré – Copyright (c) 2008–2009,2011–2015 Sven Michael Klose <pixel@copei.de>

(defun make-environment-tests ()
  (with (names  nil
		 num    0)
	`(,@(@ [(++! num)
            (alet ($ 'test- num)
              (push ! names)
              `(defun ,! ()
                 (%princ ,(+ "Test " (string num) ", " _.))
                 (with (result    ,._.
                        expected  ,.._.)
                   (unless (equal result expected)
                     (%princ " FAILED")
                     (%princ " Expected:")
                     (%princ expected)
                     (%princ " Result:")
                     (%princ result)))
                     (%princ "<br>
")))]
           *tests*)
      (defun environment-tests ()
	    ,@(@ #'list (reverse names))))))
