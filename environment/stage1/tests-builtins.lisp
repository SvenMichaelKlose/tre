;;;;; TRE environment
;;;;; Copyright (C) 2006,2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Early built-in function tests

(define-test "CAR accepts NIL"
  ((car nil))
  nil)

(define-test "CDR accepts NIL"
  ((car nil))
  nil)

(define-test "ATOM recognizes atoms"
  ((atom nil))
  t)

(define-test "ATOM fails on conses"
  ((atom (cons 23 42)))
  nil)

(define-test "CHARACTERP recognizes characters"
  ((characterp #\a))
  t)

(define-test "FUNCTIONP recognizes functions"
  ((functionp #'%backquote))
  t)

(define-test "FUNCTIONP recognizes built-in functions"
  ((functionp #'car))
  t)

;(define-test "FUNCTIONP doesn't recognize built-in special forms"
;  ((functionp #'block))
;  nil)

(define-test "NUMBERP recognizes numbers"
  ((numberp 42))
  t)

(define-test "NUMBERP recognizes characters"
  ((numberp #\a))
  t)

(define-test "STRINGP recognizes strings"
  ((stringp "some string"))
  t)

(define-test "EQL wants same type of numbers"
  ((eql 65 #\A))
  nil)

(define-test "CODE-CHAR converts number to char"
  ((code-char 65))
  #\A)

(define-test "CHAR-CODE converts char to number"
  ((code-char 65))
  #\A)

(define-test "SETQ returns the last value set"
  ((#'((a b c)
	 (setq a 23 b 5 c 42)) nil nil nil))
  42)

(define-test "RPLACA returns cons"
  ((rplaca (cons nil nil) 42))
  (cons 42 nil))

(define-test "RPLACD returns cons"
  ((rplacd (cons nil nil) 42))
  (cons nil 42))

(define-test "LAST works"
  ((last '(1 2 3)))
  '(3))

(define-test "LAST return NIL for empty list"
  ((last nil))
  nil)
