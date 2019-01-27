(var *tests* nil)

(%defun test-equal (x y)
  (?
    (atom x)	(eql x y)
    (atom y)	(eql x y)
    (test-equal x. y.)
      		    (test-equal .x .y)))

(%defun do-test (test)
  (? *print-definitions?*
     (print test.))
  (? (not (test-equal (eval (macroexpand .test.))
                      (eval (macroexpand ..test.))))
     (progn
       (print test.)
       (print 'FAILED-RESULT)
       (print (eval (macroexpand .test.)))
       (print 'WANTED-RESULT)
       (print (eval (macroexpand ..test.)))
       (invoke-debugger))))

(%defun do-tests (&optional (tests *tests*))
  (? (not tests)
     nil
     (progn
	   (do-test tests.)
	   (do-tests .tests))))

;; Add test to global list.
(defmacro define-test (description expr result)
  (print-definition (list 'define-test description))
  (setq *tests* (. (. description
                      (. (. 'block (. nil expr))
                         (. result nil)))
                   *tests*))
  (do-test *tests*.)
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

(define-test "EQL with symbols"
  ((eql 'x 'x))
  t)

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
