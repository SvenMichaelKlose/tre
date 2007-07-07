;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2006 Sven Klose <pixel@copei.de>

(defvar *tests* nil)

(%defun punchcard-equal (x y)
  (cond
    ((atom x)	 (eql x y))
    ((atom y)	 (eql x y))
    ((punchcard-equal (car x) (car y))
      		 (punchcard-equal (cdr x) (cdr y)))))

(%defun do-test (test)
  (cond
    ((punchcard-equal 	(eval (car (cdr test)))
                      	(eval (car (cdr (cdr test))))))
                  (t    (print (car test))
			(print 'FAILED-RESULT)
			(print (eval (car (cdr test))))
			(print 'WANTED-RESULT)
			(print (eval (car (cdr (cdr test)))))
			(invoke-debugger))))

(%defun do-tests (tests)
  (cond
    ((not tests))
    (t			(do-test (car tests))
			(do-tests (cdr tests)))))

;; Add test to global list.
(%defspecial define-test (description expr result)
  (setq *tests* (cons (cons description
		            (cons (cons (quote block)
				        (cons (quote nil)
                                              expr))
				  (cons result nil)))
                        *tests*))
  (do-test (car *tests*)))
