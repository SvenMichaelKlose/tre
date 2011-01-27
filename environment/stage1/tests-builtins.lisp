;;;;; TRE environment
;;;;; Copyright (C) 2006,2009,2011 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Early built-in function tests

(define-test "CAR accepts NIL"
  ((car nil))
  nil)

(define-test "CDR accepts NIL"
  ((car nil))
  nil)

(define-test "RPLACA returns cons"
  ((rplaca (cons nil nil) 42))
  (cons 42 nil))

(define-test "RPLACD returns cons"
  ((rplacd (cons nil nil) 42))
  (cons nil 42))

(define-test "ATOM recognizes atoms"
  ((atom nil))
  t)

(define-test "ATOM fails on conses"
  ((atom (cons 23 42)))
  nil)

(define-test "CONSP"
  ((consp (cons 1 1)))
  t)

(define-test "CONSP fails on atoms"
  ((consp 'a))
  nil)

(define-test "CONSP fails on numbers"
  ((consp 1))
  nil)

(define-test "CONSP fails on characters"
  ((consp #\1))
  nil)

(define-test "CONSP fails on strings"
  ((consp "1"))
  nil)

(define-test "CONSP fails on arrays"
  ((consp (make-array 1)))
  nil)

(define-test "SYMBOLP"
  ((symbolp 'a))
  t)

(define-test "SYMBOLP fails on cells"
  ((symbolp (list 'a)))
  nil)

(define-test "SYMBOLP fails on numbers"
  ((symbolp 1))
  nil)

(define-test "SYMBOLP fails on characters"
  ((symbolp #\1))
  nil)

(define-test "SYMBOLP fails on strings"
  ((symbolp "1"))
  nil)

(define-test "SYMBOLP fails on arrays"
  ((symbolp (make-array 1)))
  nil)

(define-test "NUMBERP recognizes numbers"
  ((number? 42))
  t)

(define-test "NUMBERP recognizes characters"
  ((number? #\a))
  t)

(define-test "NUMBERP fails on arrays"
  ((number? (make-array 1)))
  nil)

(define-test "NUMBERP fails on symbols"
  ((number? 'a))
  nil)

(define-test "CHARACTERP recognizes characters"
  ((characterp #\a))
  t)

(define-test "CHARACTERP fails on symbols"
  ((characterp 'a))
  nil)

(define-test "CHARACTERP fails on cells"
  ((characterp (list 1)))
  nil)

(define-test "CHARACTERP fails on numbers"
  ((characterp 1))
  nil)

(define-test "CHARACTERP fails on arrays"
  ((characterp (make-array 1)))
  nil)

(define-test "CHARACTERP fails on strings"
  ((characterp "1"))
  nil)

(define-test "EQL wants same type of numbers"
  ((eql 65 #\A))
  nil)

(define-test "FUNCTIONP recognizes functions"
  ((functionp #'%backquote))
  t)

(define-test "FUNCTIONP recognizes built-in functions"
  ((functionp #'car))
  t)

;(define-test "FUNCTIONP doesn't recognize built-in special forms"
;  ((functionp #'block))
;  nil)

(define-test "STRINGP recognizes strings"
  ((string? "some string"))
  t)

(define-test "STRINGP fails on numbers"
  ((string? 1))
  nil)

(define-test "STRINGP fails on symbols"
  ((string? 'a))
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

(define-test "IDENTITY"
  ((identity t))
  t)

(define-test "LAST works"
  ((last '(1 2 3)))
  '(3))

(define-test "LAST return NIL for empty list"
  ((last nil))
  nil)

(define-test "= works with floats"
  ((= 1 1))
  t)

(define-test "= works with characters"
  ((= #\A #\A))
  t)

(define-test "if 0 is a boolean 'true'"
  ((if 0 t))
  t)

(define-test "ELT returns CHARACTER of STRING"
  ((characterp (elt "fnord" 0)))
  t)

; + - * / MOD
; LOGXOR
; MAKE-SYMBOL ATOM SYMBOL-VALUE %TYPE-ID
; SYMBOL-FUNCTION SYMBOL-PACKAGE
; BOUNDP FBOUNDP
; MACROP STRINGP
; = < >
; BIT-OR BIT-AND
; << >>
