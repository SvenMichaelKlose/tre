;;;;; tré – Copyright (c) 2008–2009,2012–2014 Sven Michael Klose <pixel@copei.de>

(defvar *tests* nil)

(%defun test-equal (x y)
  (?
    (atom x)	(eql x y)
    (atom y)	(eql x y)
    (test-equal (car x) (car y))
      		    (test-equal (cdr x) (cdr y))))

(%defun do-test (test)
  (print (car test))
  (? (test-equal (eval (macroexpand (car (cdr test))))
                 (eval (macroexpand (car (cdr (cdr test))))))
	 (print 'OK)
     (progn
	   (print 'FAILED-RESULT)
	   (print (eval (macroexpand (car (cdr test)))))
	   (print 'WANTED-RESULT)
	   (print (eval (macroexpand (car (cdr (cdr test))))))
	   (invoke-debugger))))

(%defun do-tests (&optional (tests *tests*))
  (? (not tests)
     nil
     (progn
	   (do-test (car tests))
	   (do-tests (cdr tests)))))

;; Add test to global list.
(defmacro define-test (description expr result)
  (print-definition (list 'define-test description))
  (setq *tests* (cons (cons description
		    				(cons (cons (quote block)
								        (cons nil
                                              expr))
				    		      (cons result
                                        nil)))
                      *tests*))
  (do-test (car *tests*))
  nil)

(define-test "APPLY one argument"
  ((apply #'list '(1 2 3)))
  '(1 2 3))

(define-test "APPLY many arguments"
  ((apply #'list 1 '(2 3)))
  '(1 2 3))

(define-test "APPLY many arguments"
  ((apply #'list 1 2 '(3)))
  '(1 2 3))

(define-test "EQ with symbols"
  ((eq 'x 'x))
  t)

;(define-test "EQ with three symbols"
;  ((eq 'x 'x 'x))
;  t)

(define-test "EQL with symbols"
  ((eql 'x 'x))
  t)

;(define-test "EQL with three symbols"
;  ((eql 'x 'x 'x))
;  t)

(define-test "EQL with numbers"
  ((eql 1 1))
  t)

(define-test "BACKQUOTE"
  (`(1 2 3))
  `(1 2 3))

(define-test "QUASIQUOTE"
  (`(1 ,2 ,,3 ,,4))
  '(1 2 ,3 ,4))

(define-test "QUASIQUOTE-SPLICE"
  (`(1 ,@'(2) ,,@3 ,,@4))
  '(1 2 ,@3 ,@4))
