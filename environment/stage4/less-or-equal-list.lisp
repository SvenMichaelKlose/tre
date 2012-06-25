;;;;; tré - Copyright (c) 2009,2011 Sven Klose <pixel@copei.de>

(defun list<= (a b)
  (?
	(or (not a b)
	    (and (not a) b))  t
	(and a (not b))       nil
	(== a. b.)             (list<= .a .b)
	(< a. b.)))

(define-test "<=-LIST: first list is less"
  ((list<= '(1 2) '(2 2)))
  t)

(define-test "<=-LIST: equal"
  ((list<= '(2 2) '(2 2)))
  t)

(define-test "<=-LIST: first list is greater"
  ((list<= '(3 2) '(2 2)))
  nil)
