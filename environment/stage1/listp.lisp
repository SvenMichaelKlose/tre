; tré – Copyright (c) 2005,2008–2009,2011–2014,2016 Sven Michael Klose <pixel@copei.de>

(functional list?)

(%defun list? (x)
  (? (cons? x)
     t
     (not x)))

(define-test "LIST? for cell"
  ((list? '(1)))
  t)

(define-test "LIST? for NIL"
  ((list? nil))
  t)

(define-test "LIST? fails with number"
  ((list? 1))
  nil)

(define-test "LIST? fails with symbol"
  ((list? 'a))
  nil)
