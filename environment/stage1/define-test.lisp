;;;; TRE environment
;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defvar *tests* nil)

(%defun test-equal (x y)
  (cond
    ((atom x)	 (eql x y))
    ((atom y)	 (eql x y))
    ((test-equal (car x) (car y))
      		 (test-equal (cdr x) (cdr y)))))

(%defun do-test (test)
  (cond
    ((test-equal 	(eval (car (cdr test)))
                  	(eval (car (cdr (cdr test))))))
     (t     (print (car test))
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

(define-test "BACKQUOTE"
  (`(1 2 3))
  '(1 2 3))

(define-test "QUASIQUOTE"
  (`(1 ,2 ,,3 ,,4))
  '(1 2 ,3 ,4))

(define-test "QUASIQUOTE-SPLICE"
  (`(1 ,@'(2) ,,@3 ,,@4))
  '(1 2 ,@3 ,@4))
